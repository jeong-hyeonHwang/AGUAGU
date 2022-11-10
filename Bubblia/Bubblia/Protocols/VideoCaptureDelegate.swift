//
//  VideoCaptureDelegate.swift
//  Bubblia
//
//  Created by 황정현 on 2022/11/09.
//

import UIKit
import Combine
import AVFoundation

protocol VideoCaptureDelegate: AnyObject {
    func videoCapture(_ videoCapture: VideoCapture,
                      didCreate framePublisher: AnyPublisher<CMSampleBuffer, Never>)
}
