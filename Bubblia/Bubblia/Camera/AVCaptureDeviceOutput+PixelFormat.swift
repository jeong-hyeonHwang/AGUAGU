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
            var errorMessage = "`AVCaptureVideoDataOutput` doesn't support "
            errorMessage += "pixel format type: \(pixelFormatType)\n"
            errorMessage += "Please use one of these instead:\n"

            for (index, pixelType) in validPixelTypes.enumerated() {
                var subscriptString = " availableVideoPixelFormatTypes"
                subscriptString += "[\(index)]"
                subscriptString += String(format: " (0x%08x)\n", pixelType)

                errorMessage += subscriptString
            }

            fatalError(errorMessage)
        }

        let pixelTypeKey = String(kCVPixelBufferPixelFormatTypeKey)
        videoDataOutput.videoSettings = [pixelTypeKey: pixelFormatType]

        return videoDataOutput
    }
    
}

