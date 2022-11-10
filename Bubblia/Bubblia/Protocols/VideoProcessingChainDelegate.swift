//
//  VideoProcessingChainDelegate.swift
//  Bubblia
//
//  Created by 황정현 on 2022/11/09.
//

import Foundation
import CoreImage

protocol VideoProcessingChainDelegate: AnyObject {
    func videoProcessingChain(_ chain: VideoProcessingChain,
                              didDetect poses: [HandPose]?,
                              in frame: CGImage)
}
