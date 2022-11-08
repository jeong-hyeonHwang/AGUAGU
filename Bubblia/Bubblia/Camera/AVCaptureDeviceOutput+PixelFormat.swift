//
//  AVCaptureDeviceOutput+PixelFormat.swift
//  Bubblia
//
//  Created by 황정현 on 2022/09/08.
//

import AVFoundation

extension AVCaptureVideoDataOutput {
    static func withPixelFormatType(_ pixelFormatType: OSType) -> AVCaptureVideoDataOutput {
        let videoDataOutput = AVCaptureVideoDataOutput()
        let validPixelTypes = videoDataOutput.availableVideoPixelFormatTypes

        guard validPixelTypes.contains(pixelFormatType) else {
            fatalError("`AVCaptureVideoDataOutput` doesn't support ")
        }

        let pixelTypeKey = String(kCVPixelBufferPixelFormatTypeKey)
        videoDataOutput.videoSettings = [pixelTypeKey: pixelFormatType]

        return videoDataOutput
    }
}

