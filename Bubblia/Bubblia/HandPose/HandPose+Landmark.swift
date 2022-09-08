//
//  HandPose+Landmark.swift
//  Bubblia
//
//  Created by 황정현 on 2022/09/08.
//

import UIKit
import Vision

extension HandPose {
    typealias JointName = VNHumanHandPoseObservation.JointName
    
    struct Landmark {
        let name: JointName
        
        init?(_ point: VNRecognizedPoint) {
            name = JointName(rawValue: point.identifier)
        }
    }
}
