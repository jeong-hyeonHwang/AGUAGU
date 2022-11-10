//
//  VideoCapture.swift
//  Bubblia
//
//  Created by 황정현 on 2022/09/08.
//

import UIKit
import Combine
import AVFoundation

class VideoCapture: NSObject {
    weak var delegate: VideoCaptureDelegate! {
        didSet { createVideoFramePublisher() }
    }
    
    var isEnabled = true {
        didSet { isEnabled ? enableCaptureSession() : disableCaptureSession() }
    }
    
    private var cameraPosition = AVCaptureDevice.Position.front {
        didSet { createVideoFramePublisher() }
    }
    
    private var orientation = AVCaptureVideoOrientation.portrait {
        didSet { createVideoFramePublisher() }
    }
    
    private let captureSession = AVCaptureSession()
    
    private var framePublisher: PassthroughSubject<CMSampleBuffer, Never>?
    
    private let videoCaptureQueue = DispatchQueue(label: "Video Capture Queue",
                                                  qos: .userInitiated)
    
    private var videoStabilizationEnabled = false
    
    private func enableCaptureSession() {
        if !captureSession.isRunning { captureSession.startRunning() }
    }
    
    private func disableCaptureSession() {
        if captureSession.isRunning { captureSession.stopRunning() }
    }
    
    func cameraPermissionCheck(vc: ViewController) {
        videoCaptureQueue.async {
            switch vc.isCameraSessionAuth {
            case .success:
                break
                // 카메라 접근 권한이 없는 경우에는 카메라 접근이 불가능하다는 Alert를 띄워줍니다
            case .notAuthorized:
                DispatchQueue.main.async {
                    let message = NSLocalizedString("Permissions are required to use the camera for hand detection. You can set permissions in [Settings] > [Privacy] > [Camera].",
                                                    comment: "Alert message when the user has denied access to the camera")
                    let actions = [
                        UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                      style: .cancel,
                                      handler: nil),
                        UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"),
                                      style: .`default`,
                                      handler: { _ in
                                          UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                                                    options: [:],
                                                                    completionHandler: nil)
                                      })
                    ]
                    
                    vc.alert(title: "AGUAGU", message: message, actions: actions)
                }
            case .configurationFailed:
                DispatchQueue.main.async {
                    
                    let message = NSLocalizedString("Can't use camera.",
                                                    comment: "Alert message when something goes wrong during capture session configuration")
                    
                    vc.alert(title: "AGUAGU",
                             message: message,
                             actions: [UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                     style: .cancel,
                                                     handler: nil)])
                }
            case .none:
                return
            }
        }
    }
}

extension VideoCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput frame: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
        framePublisher?.send(frame)
    }
}

extension VideoCapture {
    private func createVideoFramePublisher() {
        guard let videoDataOutput = configureCaptureSession() else { return }
        
        let passthroughSubject = PassthroughSubject<CMSampleBuffer, Never>()
        
        framePublisher = passthroughSubject
        
        videoDataOutput.setSampleBufferDelegate(self, queue: videoCaptureQueue)
        
        let genericFramePublisher = passthroughSubject.eraseToAnyPublisher()
        
        delegate.videoCapture(self, didCreate: genericFramePublisher)
    }
    
    private func configureCaptureSession() -> AVCaptureVideoDataOutput? {
        disableCaptureSession()
        
        guard isEnabled else {
            return nil
        }
        
        defer { enableCaptureSession() }
        
        captureSession.beginConfiguration()
        
        defer { captureSession.commitConfiguration() }
        
        let modelFrameRate = 30
        
        let input = AVCaptureDeviceInput.createCameraInput(frameRate: Double(modelFrameRate))
        let output = AVCaptureVideoDataOutput.withPixelFormatType(kCVPixelFormatType_32BGRA)
        
        let success = configureCaptureConnection(input, output)
        return success ? output : nil
    }
    
    private func configureCaptureConnection(_ input: AVCaptureDeviceInput?,
                                            _ output: AVCaptureVideoDataOutput?) -> Bool {
        
        guard let input = input else { return false }
        guard let output = output else { return false }
        
        captureSession.inputs.forEach(captureSession.removeInput)
        captureSession.outputs.forEach(captureSession.removeOutput)
        
        guard captureSession.canAddInput(input) else {
            print("The camera input isn't compatible with the capture session.")
            return false
        }
        
        guard captureSession.canAddOutput(output) else {
            print("The video output isn't compatible with the capture session.")
            return false
        }
        
        captureSession.addInput(input)
        captureSession.addOutput(output)
        
        guard captureSession.connections.count == 1 else {
            let count = captureSession.connections.count
            print("The capture session has \(count) connections instead of 1.")
            return false
        }
        
        guard let connection = captureSession.connections.first else {
            print("Getting the first/only capture-session connection shouldn't fail.")
            return false
        }
        
        if connection.isVideoOrientationSupported {
            connection.videoOrientation = orientation
        }
        
        if connection.isVideoMirroringSupported {
            connection.isVideoMirrored = true
        }
        
        if connection.isVideoStabilizationSupported {
            if videoStabilizationEnabled {
                connection.preferredVideoStabilizationMode = .standard
            } else {
                connection.preferredVideoStabilizationMode = .off
            }
        }
        
        output.alwaysDiscardsLateVideoFrames = true
        
        return true
    }
}
