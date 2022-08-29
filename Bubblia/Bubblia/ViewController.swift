//
//  ViewController.swift
//  Bubblia
//
//  Created by 황정현 on 2022/08/29.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController {
    
    private var cameraView: CameraView { view as! CameraView }
    
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInteractive)
    private var cameraFeedSession: AVCaptureSession?
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    
    private var lastObservationTimestamp = Date()
    
    private var lastDrawPoint: CGPoint?
    private var isTouched = false
    
    private var gestureProcessor = HandGestureProcessor()
    
    private var layer = CAShapeLayer()
    private var drawPath = UIBezierPath()
    
    private var width: CGFloat = 0
    private var height: CGFloat = 0
    
    private var nameLabel = UILabel()
    private var scoreLabel = UILabel()
    private var gameOverLabel = UILabel()
    
    private var scoreInt: Int = 0
    
    private var gameStart = false
    private var gameOver = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        width = view.bounds.maxX
        height = view.bounds.maxY
        
        handPoseRequest.maximumHandCount = 1
        // Add state change handler to hand gesture processor.
        gestureProcessor.didChangeStateClosure = { [weak self] state in
            self?.handleGestureStateChange(state: state)
        }
        
        drawPath.addArc(withCenter: CGPoint(x: width/2, y: height/2), radius: 30, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        layer.path = drawPath.cgPath
        layer.fillColor = UIColor.yellow.cgColor
        view.layer.addSublayer(layer)
        
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            nameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            nameLabel.heightAnchor.constraint(equalToConstant: 80),
            nameLabel.widthAnchor.constraint(equalToConstant: width)
        ])
        
        nameLabel.text = "B◎BBLIA"
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: 36, weight: .semibold)
        nameLabel.textColor = .yellow
        
        view.addSubview(scoreLabel)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            scoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
//            scoreLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
//
//            scoreLabel.heightAnchor.constraint(equalToConstant: 80),
//            scoreLabel.widthAnchor.constraint(equalToConstant: width)
//        ])
        NSLayoutConstraint.activate([
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scoreLabel.heightAnchor.constraint(equalToConstant: 150),
            scoreLabel.widthAnchor.constraint(equalToConstant: width)
        ])
        
        scoreLabel.text = "\(scoreInt)"
        scoreLabel.textAlignment = .center
        //scoreLabel.font = UIFont.systemFont(ofSize: 36, weight: .regular)
        scoreLabel.font = UIFont.systemFont(ofSize: 60, weight: .regular)
        scoreLabel.textColor = .yellow
//        scoreLabel.textColor = .white.withAlphaComponent(0.5)
        scoreLabel.alpha = 0
        
        view.addSubview(gameOverLabel)
        gameOverLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gameOverLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gameOverLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40),
            gameOverLabel.heightAnchor.constraint(equalToConstant: 80),
            gameOverLabel.widthAnchor.constraint(equalToConstant: width)
        ])
        
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.textAlignment = .center
        gameOverLabel.font = UIFont.systemFont(ofSize: 36, weight: .semibold)
        gameOverLabel.textColor = .yellow
        gameOverLabel.alpha = 0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            if cameraFeedSession == nil {
                cameraView.previewLayer.videoGravity = .resizeAspectFill
                try setupAVSession()
                cameraView.previewLayer.session = cameraFeedSession
            }
            cameraFeedSession?.startRunning()
        } catch {
            AppError.display(error, inViewController: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        cameraFeedSession?.stopRunning()
        super.viewWillDisappear(animated)
    }
    
    func setupAVSession() throws {
        // Select a front facing camera, make an input.
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            throw AppError.captureSessionSetup(reason: "Could not find a front facing camera.")
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            throw AppError.captureSessionSetup(reason: "Could not create video device input.")
        }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        
        // Add a video input.
        guard session.canAddInput(deviceInput) else {
            throw AppError.captureSessionSetup(reason: "Could not add video device input to the session")
        }
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            // Add a video data output.
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            throw AppError.captureSessionSetup(reason: "Could not add video data output to the session")
        }
        session.commitConfiguration()
        cameraFeedSession = session
    }
    
    func processPoints(thumbTip: CGPoint?, indexTip: CGPoint?) {
        // Check that we have both points.
        guard let thumbPoint = thumbTip, let indexPoint = indexTip else {
            // If there were no observations for more than 2 seconds reset gesture processor.
            if Date().timeIntervalSince(lastObservationTimestamp) > 2 {
                gestureProcessor.reset()
            }
            cameraView.showPoints([], color: .clear)
            return
        }
        
        // Convert points from AVFoundation coordinates to UIKit coordinates.
        let previewLayer = cameraView.previewLayer
        let thumbPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: thumbPoint)
        let indexPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: indexPoint)
        
        // Process new points
        gestureProcessor.processPointsPair((thumbPointConverted, indexPointConverted))
    }
    
    private func handleGestureStateChange(state: HandGestureProcessor.State) {
        let pointsPair = gestureProcessor.lastProcessedPointsPair
        var tipsColor: UIColor
        switch state {
        case .possiblePinch, .possibleApart:
            tipsColor = .orange
        case .pinched:
            if gameStart == false {
                UIView.transition(with: nameLabel,
                                  duration: 0.25,
                               options: .transitionCrossDissolve,
                            animations: { [weak self] in
                                self?.nameLabel.alpha = 0
                         }, completion: nil)
                UIView.transition(with: scoreLabel,
                                  duration: 0.25,
                               options: .transitionCrossDissolve,
                            animations: { [weak self] in
                                self?.scoreLabel.alpha = 1
                         }, completion: nil)
                gameStart = true
            }
            if isTouched == false && gameOver == false {
                print(":::PINCH:::")
                print("(x:\(pointsPair.thumbTip.x), y:\(pointsPair.thumbTip.y))")
                if drawPath.bounds.contains(CGPoint(x: pointsPair.thumbTip.x, y: pointsPair.thumbTip.y)) {
                    layer.fillColor = UIColor.blue.cgColor
                    changePosition(layer: layer, path: drawPath)
                    addOpacityChagneAnimation(duration: CGFloat.random(in: 3...5))
                    updateScore()
                }
                isTouched = true
            }
            tipsColor = .green
        case .apart, .unknown:
            if isTouched == true {
                print(":::APART:::")
                isTouched = false
            }
            tipsColor = .red
        }
        cameraView.showPoints([pointsPair.thumbTip, pointsPair.indexTip], color: tipsColor)
    }
    
    func changePosition(layer: CAShapeLayer, path: UIBezierPath) {
        layer.opacity = 0
        
        let randomX = CGFloat.random(in: 100...width-100)
        let randomY = CGFloat.random(in: 100...height-100)
        
        path.removeAllPoints()
        path.addArc(withCenter: CGPoint(x: randomX, y: randomY), radius: 30, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        
        layer.path = path.cgPath
        layer.fillColor = UIColor.yellow.cgColor
        layer.opacity = 1
    }
    
    func addOpacityChagneAnimation(duration: CGFloat) {
        // https://ios-development.tistory.com/937
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            // https://stackoverflow.com/questions/20244933/get-current-caanimation-transform-value
            let currentOpacity = self.layer.presentation()?.value(forKeyPath: "opacity") ?? 0.0
            print(currentOpacity as! Double)
            if (currentOpacity as! Double) <= 0.0001 {
                print("-----GAME OVER-----")
                UIView.transition(with: self.scoreLabel,
                                  duration: 0.25,
                               options: .transitionCrossDissolve,
                            animations: { [weak self] in
                    self?.scoreLabel.layer.position = CGPoint(x: (self?.scoreLabel.frame.midX)!, y: (self?.scoreLabel.frame.midY)! - 30)
                         }, completion: nil)
                UIView.transition(with: self.gameOverLabel,
                                  duration: 0.25,
                               options: .transitionCrossDissolve,
                            animations: { [weak self] in
                                self?.gameOverLabel.alpha = 1
                         }, completion: nil)
                self.layer.isHidden = true
                self.gameOver = true
            } else {
                print(">>> GOGOGO!!! <<<")
            }
        })
        
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = layer.opacity
        animation.toValue = 0
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        layer.add(animation, forKey: "changeOpacity")
        
        CATransaction.commit()
    }
    
    func updateScore() {
        scoreInt += 1
        UIView.transition(with: scoreLabel,
                          duration: 0.15,
                          options: .transitionFlipFromLeft,
                          animations: {
            self.scoreLabel.text = "\(self.scoreInt)"
        }, completion: nil)
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        var thumbTip: CGPoint?
        var indexTip: CGPoint?
        
        defer {
            DispatchQueue.main.sync {
                self.processPoints(thumbTip: thumbTip, indexTip: indexTip)
                
            }
        }
        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            // Perform VNDetectHumanHandPoseRequest
            try handler.perform([handPoseRequest])
            // Continue only when a hand was detected in the frame.
            // Since we set the maximumHandCount property of the request to 1, there will be at most one observation.
            guard let observation = handPoseRequest.results?.first else {
                return
            }
            // Get points for thumb and index finger.
            let thumbPoints = try observation.recognizedPoints(.thumb)
            let indexFingerPoints = try observation.recognizedPoints(.indexFinger)
            // Look for tip points.
            guard let thumbTipPoint = thumbPoints[.thumbTip], let indexTipPoint = indexFingerPoints[.indexTip] else {
                return
            }
            // Ignore low confidence points.
            guard thumbTipPoint.confidence > 0.3 && indexTipPoint.confidence > 0.3 else {
                return
            }
            // Convert points from Vision coordinates to AVFoundation coordinates.
            thumbTip = CGPoint(x: thumbTipPoint.location.x, y: 1 - thumbTipPoint.location.y)
            indexTip = CGPoint(x: indexTipPoint.location.x, y: 1 - indexTipPoint.location.y)
        } catch {
            cameraFeedSession?.stopRunning()
            let error = AppError.visionError(error: error)
            DispatchQueue.main.async {
                error.displayInViewController(self)
            }
        }
    }
}
