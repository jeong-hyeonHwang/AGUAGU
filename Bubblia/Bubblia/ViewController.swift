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
    private var highScoreLabel = UILabel()
    private var gameOverLabel = UILabel()
    
    private var scoreInt: Int = 0
    
    private var gameStart = false
    private var gameOver = false
    
    private var highScore: Int = 0
    
    private let accentColor: UIColor = .accentColor
    ?? .yellow
    private let activeColor: UIColor = .activeColor ?? .green
    private let middleColor: UIColor = .activeColor ?? .orange
    private let disactiveColor: UIColor = .disactiveColor ?? .red
    
//    private var duration: CGFloat = 3
//    private var patienceCount: Int = 0
//    private let durationMinusValue: CGFloat = 0.025
//    private let durationMinLimitNum: CGFloat = 0.75
//    private let durationMaxLimitNum: CGFloat = 3
//    private var patientLimitNum = 10
//    private let patientPlusValue: Int = 10
    
    private let highScoreNoticeLabel = UILabel()
    
    private var duration: CGFloat = 3
    private var patienceCount: Int = 0
    private let durationMinusValue: CGFloat = 0.5
    private let durationMinLimitNum: CGFloat = 1.5
    private let durationMaxLimitNum: CGFloat = 3
    private var patientLimitNum = 10
    private let patientPlusValue: Int = 10
    
    private var circleRadius: CGFloat = 60
    
    private let sfxSequence: [String] = ["E", "A", "B", "D", "C", "A", "C", "F"]
    
    private var sequenceInt: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //https://stackoverflow.com/questions/66037782/swiftui-how-do-i-lock-a-particular-view-in-portrait-mode-whilst-allowing-others
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                AppDelegate.orientationLock = .portrait
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        width = view.bounds.maxX
        height = view.bounds.maxY
        
        circleRadius = height * 30 / 844
        
        handPoseRequest.maximumHandCount = 1
        // Add state change handler to hand gesture processor.
        gestureProcessor.didChangeStateClosure = { [weak self] state in
            self?.handleGestureStateChange(state: state)
        }
        
        drawPath.addArc(withCenter: CGPoint(x: width/2, y: height * 0.38), radius: circleRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        layer.path = drawPath.cgPath
        layer.fillColor = accentColor.cgColor
        view.layer.addSublayer(layer)
        
        view.addSubview(highScoreNoticeLabel)
        highScoreNoticeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            highScoreNoticeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            highScoreNoticeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            highScoreNoticeLabel.heightAnchor.constraint(equalToConstant: 80),
            highScoreNoticeLabel.widthAnchor.constraint(equalToConstant: width)
        ])
        
        highScoreNoticeLabel.text = "HIGHSCORE"
        highScoreNoticeLabel.textAlignment = .center
        highScoreNoticeLabel.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        highScoreNoticeLabel.textColor = accentColor
        highScoreNoticeLabel.alpha = 0
        
        view.addSubview(scoreLabel)
        scoreLabel.frame = CGRect(x: 0, y: height/2 - 75, width: width, height: 150)
        scoreLabel.center = CGPoint(x: width/2, y: height/2)
        
        highScore = getHighScore()
        print("Recorded High Score is \(highScore)")
        scoreLabel.text = highScore == 0 ? "" : "\(highScore)"
        scoreLabel.textAlignment = .center
        scoreLabel.font = UIFont.systemFont(ofSize: 60, weight: .regular)
        scoreLabel.textColor = accentColor
        scoreLabel.alpha = 0
        
        view.addSubview(highScoreLabel)
        highScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            highScoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            highScoreLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -height * 0.12),
            highScoreLabel.heightAnchor.constraint(equalToConstant: 36),
            highScoreLabel.widthAnchor.constraint(equalToConstant: width)
        ])

        highScoreLabel.text = highScore == 0 ? "" : "\(highScore)"
        highScoreLabel.textAlignment = .center
        highScoreLabel.font = UIFont.systemFont(ofSize: 48, weight: .medium)
        highScoreLabel.textColor = accentColor
        
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            nameLabel.bottomAnchor.constraint(equalTo: highScoreLabel.topAnchor, constant: 0),
            nameLabel.heightAnchor.constraint(equalToConstant: 88),
            nameLabel.widthAnchor.constraint(equalToConstant: width)
        ])
        
        nameLabel.text = "KR◎KR◎N" //"KR◎◎RK"//"B◎BBLIA"
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: 64, weight: .bold)
        nameLabel.textColor = accentColor
        
        view.addSubview(gameOverLabel)
        gameOverLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gameOverLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gameOverLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 60),
            gameOverLabel.heightAnchor.constraint(equalToConstant: 80),
            gameOverLabel.widthAnchor.constraint(equalToConstant: width)
        ])
        
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.textAlignment = .center
        gameOverLabel.font = UIFont.systemFont(ofSize: 36, weight: .semibold)
        gameOverLabel.textColor = accentColor
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
            tipsColor = middleColor
        case .pinched:
            if gameOver == true {
                gameRestart()
            } else if drawPath.bounds.contains(CGPoint(x: pointsPair.thumbTip.x, y: pointsPair.thumbTip.y)) {
                if gameStart == false {
                    labelOpacityAnimation(target: nameLabel, duration: 0.25, targetOpacity: 0, completion: { _ in })
                    labelOpacityAnimation(target: highScoreLabel, duration: 0.25, targetOpacity: 0, completion: { _ in })
                    labelOpacityAnimation(target: scoreLabel, duration: 0.25, targetOpacity: 1, completion: { _ in })
                    changePosition(layer: layer, path: drawPath)
                    addOpacityChagneAnimation(duration: duration)
                    updateScore()
                    updateDuration()
                    gameStart = true
                } else if isTouched == false && gameOver == false {
                    print(":::PINCH:::")
                    if drawPath.bounds.contains(CGPoint(x: pointsPair.thumbTip.x, y: pointsPair.thumbTip.y)) {
                        changePosition(layer: layer, path: drawPath)
                        addOpacityChagneAnimation(duration: duration)
                        updateScore()
                        updateDuration()
//                        playSound(tone: sfxSequence[sequenceInt])
//                        if sequenceInt < sfxSequence.count-1 {
//                            sequenceInt += 1
//                        } else {
//                            sequenceInt = 0
//                        }
                    }
                    isTouched = true
                }
            }
            tipsColor = activeColor
        case .apart, .unknown:
            if isTouched == true {
                print(":::APART:::")
                isTouched = false
            }
            tipsColor = disactiveColor
        }
        cameraView.showPoints([pointsPair.thumbTip, pointsPair.indexTip], color: tipsColor)
    }
    
    func changePosition(layer: CAShapeLayer, path: UIBezierPath) {
        layer.opacity = 0
        
        let randomX = CGFloat.random(in: 100...width-100)
        let randomY = CGFloat.random(in: 200...height-200)
        
        path.removeAllPoints()
        path.addArc(withCenter: CGPoint(x: randomX, y: randomY), radius: circleRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        
        layer.path = path.cgPath
        layer.fillColor = accentColor.cgColor
        layer.opacity = 1
    }
    
    func addOpacityChagneAnimation(duration: CGFloat) {
        // https://ios-development.tistory.com/937
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            // https://stackoverflow.com/questions/20244933/get-current-caanimation-transform-value
            let currentOpacity = self.layer.presentation()?.value(forKeyPath: "opacity") ?? 0.0
            if (currentOpacity as! Double) <= 0.01 {
                print("-----GAME OVER-----")
                self.layer.isHidden = true
                
                self.labelOpacityAnimation(target: self.gameOverLabel, duration: 0.25, targetOpacity: 1, completion: { _ in
                    
                    if self.highScore < self.scoreInt {
                        self.labelOpacityAnimation(target: self.highScoreNoticeLabel, duration: 0.25, targetOpacity: 1, completion: { _ in})
                    }
                    
                    self.drawPath.removeAllPoints()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.gameOver = true
                    })
                })
                
                self.checkHighScore()
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
//        scoreLabel.textColor = .yellow
        scoreInt += 1
        scoreLabelTextAnimation()
    }
    
    func returnToDefaultScore() {
        scoreInt = 1
        scoreLabelTextAnimation()
    }
    
    func updateDuration() {
        if duration != durationMinLimitNum {
            duration -= durationMinusValue
            print("CURRENT DURATION IS \(duration)")
        } else {
            patienceCount += 1
            print("BE PATIENT \(patienceCount)")
            if patienceCount == patientLimitNum {
                patienceCount = 0
                if patientLimitNum != 50 {
                    patientLimitNum += patientPlusValue
                }
                duration = durationMaxLimitNum
                print("PATIENT IS OVER")
            }
        }
    }
    
    func returnToDefaultDuration() {
        duration = durationMaxLimitNum
        patienceCount = 0
        patientLimitNum = patientPlusValue
    }
    
    func scoreLabelTextAnimation() {
        UIView.transition(with: scoreLabel,
                          duration: 0.15,
                          options: .transitionFlipFromLeft,
                          animations: {
            self.scoreLabel.text = "\(self.scoreInt)"
        }, completion: nil)
    }
    
    func labelOpacityAnimation(target: UILabel, duration: CGFloat, targetOpacity: CGFloat, completion: @escaping (Bool) -> Void) {
        UIView.transition(with: target,
                          duration: duration,
                          options: .transitionCrossDissolve,
                          animations: {
            target.alpha = targetOpacity
        }, completion: completion)
    }
    
    func checkHighScore() {
        if highScore < scoreInt {
            setHighScore(value: scoreInt)
            highScore = scoreInt
            print("### HIGHSCORE \(highScore) ###")
        } else {
            print(">>> SAME HIGHSCORE <<<")
        }
    }
    
    func gameRestart() {
        labelOpacityAnimation(target: gameOverLabel, duration: 0.25, targetOpacity: 0, completion: { _ in })
        labelOpacityAnimation(target: highScoreNoticeLabel, duration: 0.25, targetOpacity: 0, completion: { _ in })
        returnToDefaultScore()
        returnToDefaultDuration()
        changePosition(layer: layer, path: drawPath)
        addOpacityChagneAnimation(duration: duration)
        
        layer.isHidden = false
        gameOver = false
        isTouched = false
        sequenceInt = 0
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
            let indexFingerPoints = try observation.recognizedPoints(.middleFinger)
            // Look for tip points.
            guard let thumbTipPoint = thumbPoints[.thumbTip], let indexTipPoint = indexFingerPoints[.middleTip] else {
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
