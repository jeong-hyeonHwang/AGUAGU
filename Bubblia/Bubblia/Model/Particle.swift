//
//  Particle.swift
//  Bubblia
//
//  Created by 황정현 on 2022/11/09.
//

import Foundation

struct Particle {
    var startDistancePoint: CGPoint {
        get { return CGPoint(x: 55, y: 18) }
    }
    var calculateXYValue: CGPoint {
        get { return CGPoint(x: 12, y: 5) }
    }
    var radius: CGFloat {
        get { return 3 }
    }
    
    func threeParticleCenterPoints(centerPoint: CGPoint, distance: CGPoint) -> [CGPoint] {
        var points: [CGPoint] = []
        points.append(CGPoint(x: centerPoint.x - distance.x, y: centerPoint.y - distance.y))
        points.append(CGPoint(x: centerPoint.x - distance.x, y: centerPoint.y))
        points.append(CGPoint(x: centerPoint.x - distance.x, y: centerPoint.y + distance.y))
        return points
    }
}
