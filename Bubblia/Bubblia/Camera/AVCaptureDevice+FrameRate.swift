//
//  AVCaptureDevice+FrameRate.swift
//  Bubblia
//
//  Created by 황정현 on 2022/09/08.
//

import AVFoundation

extension AVCaptureDevice {
    func configureFrameRate(_ frameRate: Double) -> Bool {
        do { try lockForConfiguration() } catch {
            print("`AVCaptureDevice` wasn't unable to lock: \(error)")
            return false
        }
        
        defer { unlockForConfiguration() }

        let sortedRanges = activeFormat.videoSupportedFrameRateRanges.sorted {
            $0.maxFrameRate > $1.maxFrameRate
        }

        guard let range = sortedRanges.first else {
            return false
        }

        guard frameRate >= range.minFrameRate else {
            return false
        }

        let duration = CMTime(value: 1, timescale: CMTimeScale(frameRate))

        let inRange = frameRate <= range.maxFrameRate
        activeVideoMinFrameDuration = inRange ? duration : range.minFrameDuration
        activeVideoMaxFrameDuration = range.maxFrameDuration

        return true
    }
}

