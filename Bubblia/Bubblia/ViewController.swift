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
    
    private var layers: [CAShapeLayer] = []
    private var drawPaths: [UIBezierPath] = [UIBezierPath()]
//    private var drawPaths: [UIBezierPath] = [UIBezierPath(), UIBezierPath(), UIBezierPath(), UIBezierPath(), UIBezierPath(), UIBezierPath(), UIBezierPath(), UIBezierPath(), UIBezierPath(), UIBezierPath(), UIBezierPath(), UIBezierPath(), UIBezierPath(), UIBezierPath(), UIBezierPath(), UIBezierPath(), UIBezierPath(), UIBezierPath(), UIBezierPath(), UIBezierPath(), UIBezierPath()]
    
    private var width: CGFloat = 0
    private var height: CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        width = view.bounds.maxX
        height = view.bounds.maxY
        
        handPoseRequest.maximumHandCount = 1
        // Add state change handler to hand gesture processor.
        gestureProcessor.didChangeStateClosure = { [weak self] state in
            self?.handleGestureStateChange(state: state)
        }
        
        for i in 0..<drawPaths.count {
            let sampleNum = i % 3 == 2 ? 3 : (i+1)%3
            let x = sampleNum * 100
            let y = ((i/3) + 1) * 100
            print("X: \(x) Y:\(y)")
            drawPaths[i].addArc(withCenter: CGPoint(x: x, y: y), radius: 30, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            layers.append(CAShapeLayer())
            layers[i].path = drawPaths[i].cgPath
            layers[i].fillColor = UIColor.yellow.cgColor
            view.layer.addSublayer(layers[i])
            
//            let animation = CABasicAnimation(keyPath: "position")
//            animation.fromValue = layers[i].position
//            animation.toValue = CGPoint(x: layers[i].position.x, y: layers[i].position.y + 50)
//            animation.duration = 5
//            animation.fillMode = .forwards
//            animation.isRemovedOnCompletion = false
//            layers[i].add(animation, forKey: "simple position animation")
        }
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
            if isTouched == false {
                print("PINCH")
                print("x:\(pointsPair.thumbTip.x), y:\(pointsPair.thumbTip.y)")
                for i in 0..<drawPaths.count {
                    print("HERE")
                    if drawPaths[i].bounds.contains(CGPoint(x: pointsPair.thumbTip.x, y: pointsPair.thumbTip.y)) {
                        print("IN!!!")
                        layers[i].fillColor = UIColor.blue.cgColor
                        changePosition(layer: layers[i], path: drawPaths[i])
                    }
                }
                isTouched = true
            }
            tipsColor = .green
        case .apart, .unknown:
            if isTouched == true {
                print("APART")
                isTouched = false
                for i in 0..<drawPaths.count {
                    if drawPaths[i].bounds.contains(CGPoint(x: pointsPair.thumbTip.x, y: pointsPair.thumbTip.y)) {
                        layers[i].fillColor = UIColor.yellow.cgColor
                    }
                }
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
        
        //layer.position = CGPoint(x: randomX, y: randomY)
        layer.path = path.cgPath
        layer.fillColor = UIColor.yellow.cgColor
        layer.opacity = 1
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
