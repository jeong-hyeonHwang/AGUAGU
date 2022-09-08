//
//  AVCaptureDeviceInput+Camera.swift
//  Bubblia
//
//  Created by 황정현 on 2022/09/08.
//

import AVFoundation

extension AVCaptureDeviceInput {
    static func createCameraInput(frameRate: Double) -> AVCaptureDeviceInput? {
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: AVMediaType.video,
                                                   position: .front) else {
            return nil
        }

        guard camera.configureFrameRate(frameRate) else { return nil }

        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)

            return cameraInput
        } catch {
            print("Unable to create an input from the camera: \(error)")
            return nil
        }
    }
}
