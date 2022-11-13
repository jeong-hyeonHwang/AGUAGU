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
        private static let threshold: Float = 0.2

        private static let radius: CGFloat = 14.0

        let name: JointName
        
        let location: CGPoint

        let num4: CGFloat = 120
        let num3: CGFloat = 90
        let num2: CGFloat = 60
        let num1: CGFloat = 30
        
        let radius: CGFloat = 20
        let diameter = radius * 2
        
        init?(_ point: VNRecognizedPoint) {
            guard point.confidence >= HandPose.Landmark.threshold else {
                return nil
            }

            name = JointName(rawValue: point.identifier)
            location = point.location
        }
        
        func drawToContext(_ context: CGContext,
                           applying transform: CGAffineTransform? = nil,
                           at scale: CGFloat = 1.0, landmarkIndex: Int) {
            
            let origin = location.applying(transform ?? .identity)
            
            context.move(to: CGPoint(x: origin.x, y: origin.y))
            
            if landmarkIndex == 0 {
                let leftEyeCenter = CGPoint(x: origin.x-num2, y: origin.y + num2)
                let rightEyeCenter = CGPoint(x: origin.x+num2, y: origin.y + num2)
                let rectangle = CGRect(x: leftEyeCenter.x - radius,
                                       y: leftEyeCenter.y - radius,
                                                  width: diameter,
                                                  height: diameter)
                context.addEllipse(in: rectangle)
                let rectangle2 = CGRect(x: rightEyeCenter.x - radius,
                                       y: rightEyeCenter.y - radius,
                                                  width: diameter,
                                                  height: diameter)
                context.addEllipse(in: rectangle2)
                
                context.move(to: CGPoint(x: origin.x-num4, y: origin.y+5))
                context.addLine(to: CGPoint(x: origin.x-num4, y: origin.y - num1))
                context.addLine(to: CGPoint(x: origin.x-num3, y: origin.y))
                context.addLine(to: CGPoint(x: origin.x-num2, y: origin.y - num1))
                context.addLine(to: CGPoint(x: origin.x-num1, y: origin.y))
                context.addLine(to: CGPoint(x: origin.x, y: origin.y - num1))
                context.addLine(to: CGPoint(x: origin.x+num1, y: origin.y))
                context.addLine(to: CGPoint(x: origin.x+num2, y: origin.y - num1))
                context.addLine(to: CGPoint(x: origin.x+num3, y: origin.y))
                context.addLine(to: CGPoint(x: origin.x+num4, y: origin.y - num1))
                context.addLine(to: CGPoint(x: origin.x+num4, y: origin.y+10))
                context.addLine(to: CGPoint(x: origin.x-num4, y: origin.y+10))

                
            } else {
                context.move(to: CGPoint(x: origin.x-num4, y: origin.y))
                context.addLine(to: CGPoint(x: origin.x-num3, y: origin.y + num1))
                context.addLine(to: CGPoint(x: origin.x-num2, y: origin.y))
                context.addLine(to: CGPoint(x: origin.x-num1, y: origin.y + num1))
                context.addLine(to: CGPoint(x: origin.x, y: origin.y))
                context.addLine(to: CGPoint(x: origin.x+num1, y: origin.y + num1))
                context.addLine(to: CGPoint(x: origin.x+num2, y: origin.y))
                context.addLine(to: CGPoint(x: origin.x+num3, y: origin.y + num1))
                context.addLine(to: CGPoint(x: origin.x+num4, y: origin.y))
                context.addLine(to: CGPoint(x: origin.x+num4, y: origin.y-10))
                context.addLine(to: CGPoint(x: origin.x-num4, y: origin.y-10))
            }
            context.drawPath(using: CGPathDrawingMode.fillStroke)
        }
    }
}
