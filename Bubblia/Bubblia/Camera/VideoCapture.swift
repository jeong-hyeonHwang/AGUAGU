//
//  VideoCapture.swift
//  Bubblia
//
//  Created by 황정현 on 2022/09/08.
//

import Foundation
import AVFoundation
import Combine

typealias Frame = CMSampleBuffer
typealias FramePublisher = AnyPublisher<Frame, Never>

protocol VideoCaptureDelegate: AnyObject {
    func videoCapture(_ videoCapture: VideoCapture,
                      didCreate framePublisher: FramePublisher)
}

class VideoCapture: NSObject {
    weak var delegate: VideoCaptureDelegate!
}
