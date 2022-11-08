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

    let area: CGFloat

    static func fromObservations(_ observations: [Observation]?) -> [HandPose]? {
        observations?.compactMap { observation in HandPose(observation) }
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

        area = HandPose.areaEstimateOfLandmarks(landmarks)

    }
    
    func drawWireframeToContext(_ context: CGContext,
                                applying transform: CGAffineTransform? = nil, point: CGPoint, pastStatus: HandPoseStatus) -> HandPoseStatus {
        var returnValue: HandPoseStatus = HandPoseStatus.possible
        
        let scale = drawingScale

        if landmarks.count == 2 {
            let thumbPoint = landmarks[0].location
            let middlePoint = landmarks[1].location
            let distance = thumbPoint.CGPointDistance(to: middlePoint)
            
            
            let thumbMiddleCenterPoint = CGPoint.midPoint(p1: thumbPoint, p2: middlePoint)

            let centerCGPoint = CGPoint(x: thumbMiddleCenterPoint.x, y: 1 - thumbMiddleCenterPoint.y)
            
            let width = UIScreen.main.bounds.width
            let height = UIScreen.main.bounds.height
            
            let centerLayerPoint = CGPoint(x: width * centerCGPoint.x, y: height * centerCGPoint.y)
            
            if distance < 0.06 {
                context.setFillColor(UIColor.green.cgColor)
                context.setStrokeColor(UIColor.green.cgColor)
                if centerLayerPoint.distance(from: point) < 45 && pastStatus == .possible
                {
                    returnValue = .pinched
                } else {
                    returnValue = .invalid
                }
            } else {
                context.setFillColor(UIColor.red.cgColor)
                context.setStrokeColor(UIColor.red.cgColor)
                if distance > 0.15 {
                    returnValue = .possible
                }
            }
        }
        // Draw the landmarks on top of the lines' endpoints.
        for idx in 0...landmarks.count - 1 {
            landmarks[idx].drawToContext(context,
                                   applying: transform,
                                   at: scale, landmarkIndex: idx)
        }
        
        return returnValue
    }

    private var drawingScale: CGFloat {
        
        let typicalLargePoseArea: CGFloat = 0.35
        
        let max: CGFloat = 1.0
        let min: CGFloat = 0.6

        let ratio = area / typicalLargePoseArea

        let scale = ratio >= max ? max : (ratio * (max - min)) + min
        return scale
    }
    
    static func areaEstimateOfLandmarks(_ landmarks: [Landmark]) -> CGFloat {
        let xCoordinates = landmarks.map { $0.location.x }
        let yCoordinates = landmarks.map { $0.location.y }

        guard let minX = xCoordinates.min() else { return 0.0 }
        guard let maxX = xCoordinates.max() else { return 0.0 }

        guard let minY = yCoordinates.min() else { return 0.0 }
        guard let maxY = yCoordinates.max() else { return 0.0 }

        let deltaX = maxX - minX
        let deltaY = maxY - minY

        return deltaX * deltaY
    }
}
