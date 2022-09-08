//
//  HandPose.swift
//  Bubblia
//
//  Created by 황정현 on 2022/09/08.
//

import UIKit
import Vision
import AVFoundation

typealias Observation = VNHumanHandPoseObservation

struct HandPose {
    private let landmarks: [Landmark]
    
    static func fromObservations(_ observations: [Observation]) -> [HandPose] {
        observations.compactMap { observation in HandPose(observation) }
    }
    
    init?(_ observation: Observation) {
        
        landmarks = observation.availableJointNames.compactMap { jointName in

            guard let point = try?
                    observation.recognizedPoint(jointName) else {
                return nil
            }

            if !((jointName.rawValue == VNHumanHandPoseObservation.JointName.thumbTip.rawValue) || (jointName.rawValue == VNHumanHandPoseObservation.JointName.middleTip.rawValue)) {
                return nil
            }
            
            return Landmark(point)
        }

        guard !landmarks.isEmpty else { return nil }
    }
}
