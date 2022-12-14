//
//  CGPoint+.swift
//  Bubblia
//
//  Created by 황정현 on 2022/09/08.
//

import UIKit

extension CGPoint {
    static func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }
    
    func distance(from point: CGPoint) -> CGFloat {
        return hypot(point.x - x, point.y - y)
    }
    
    func CGPointDistanceSquared(to: CGPoint) -> CGFloat {
        return (self.x - to.x) * (self.x - to.x) + (self.y - to.y) * (self.y - to.y)
    }

    func CGPointDistance(to: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(to: to))
    }
}
