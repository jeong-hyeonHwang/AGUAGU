//
//  HandGestureProcessor.swift
//  Bubblia
//
//  Created by 황정현 on 2022/08/29.
//

import CoreGraphics

class HandGestureProcessor {
    enum State {
        case possiblePinch
        case pinched
        case possibleApart
        case apart
        case unknown
    }
    
    typealias PointsPair = (thumbTip: CGPoint, middleTip: CGPoint)
    
    private var state = State.unknown {
        didSet {
            didChangeStateClosure?(state)
        }
    }
    private var pinchEvidenceCounter = 0
    private var apartEvidenceCounter = 0
    private let pinchMaxDistance: CGFloat
    private let evidenceCounterStateTrigger: Int
    
    var didChangeStateClosure: ((State) -> Void)?
    private (set) var lastProcessedPointsPair = PointsPair(.zero, .zero)
    
    init(pinchMaxDistance: CGFloat = 40, evidenceCounterStateTrigger: Int = 3) {
        self.pinchMaxDistance = pinchMaxDistance
        self.evidenceCounterStateTrigger = evidenceCounterStateTrigger
    }
    
    func reset() {
        state = .unknown
        pinchEvidenceCounter = 0
        apartEvidenceCounter = 0
    }
    
    func processPointsPair(_ pointsPair: PointsPair) {
        lastProcessedPointsPair = pointsPair
        let distance = pointsPair.middleTip.distance(from: pointsPair.thumbTip)
        if distance < pinchMaxDistance {
            // Keep accumulating evidence for pinch state.
            pinchEvidenceCounter += 1
            apartEvidenceCounter = 0
            // Set new state based on evidence amount.
            state = (pinchEvidenceCounter >= evidenceCounterStateTrigger) ? .pinched : .possiblePinch
        } else {
            // Keep accumulating evidence for apart state.
            apartEvidenceCounter += 1
            pinchEvidenceCounter = 0
            // Set new state based on evidence amount.
            state = (apartEvidenceCounter >= evidenceCounterStateTrigger) ? .apart : .possibleApart
        }
    }
}

// MARK: - CGPoint helpers

extension CGPoint {

    static func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }
    
    func distance(from point: CGPoint) -> CGFloat {
        return hypot(point.x - x, point.y - y)
    }
}
