//
//  CameraView.swift
//  Bubblia
//
//  Created by 황정현 on 2022/08/29.
//

import UIKit
import AVFoundation

class CameraView: UIImageView {

    private var backgroundLayer = CAShapeLayer()
    private var overlayLayer = CAShapeLayer()
    private var pointsPath = UIBezierPath()

    var previewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupOverlay()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupOverlay()
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        let temp = UIBezierPath()
        temp.addArc(withCenter: CGPoint(x: 0, y: 0), radius: 1800, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        if layer == previewLayer {
            overlayLayer.frame = layer.bounds
            backgroundLayer.frame = layer.bounds
            backgroundLayer.path = temp.cgPath
            backgroundLayer.fillColor = UIColor.black.cgColor
        }
    }

    private func setupOverlay() {
        previewLayer.addSublayer(backgroundLayer)
        previewLayer.addSublayer(overlayLayer)
    }
    
    // MARK: SHOW POINTS
    func showPoints(_ points: [CGPoint], color: UIColor) {
        pointsPath.removeAllPoints()
        for idx in 0..<points.count {
            let point = points[idx]
            pointsPath.move(to: CGPoint(x: point.x, y: point.y))
//            pointsPath.addLine(to: CGPoint(x: point.x+10, y: point.y))
//            pointsPath.addArc(withCenter: point, radius: 10, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            
            if (idx+1) % 2 == 0 {
                pointsPath.move(to: CGPoint(x: point.x-40, y: point.y))
                let leftEyeCenter = CGPoint(x: point.x-20, y: point.y - 20)
                let rightEyeCenter = CGPoint(x: point.x+20, y: point.y - 20)
                            pointsPath.addArc(withCenter: leftEyeCenter, radius: 8, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
                pointsPath.move(to: rightEyeCenter)
                            pointsPath.addArc(withCenter: rightEyeCenter, radius: 8, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
                pointsPath.move(to: CGPoint(x: point.x-40, y: point.y))
//                pointsPath.addLine(to: CGPoint(x: point.x-40, y: point.y))
                pointsPath.addLine(to: CGPoint(x: point.x-30, y: point.y + 10))
                pointsPath.addLine(to: CGPoint(x: point.x-20, y: point.y))
                pointsPath.addLine(to: CGPoint(x: point.x-10, y: point.y + 10))
                pointsPath.addLine(to: CGPoint(x: point.x, y: point.y))
                pointsPath.addLine(to: CGPoint(x: point.x+10, y: point.y + 10))
                pointsPath.addLine(to: CGPoint(x: point.x+20, y: point.y))
                pointsPath.addLine(to: CGPoint(x: point.x+30, y: point.y + 10))
                pointsPath.addLine(to: CGPoint(x: point.x+40, y: point.y))
                pointsPath.addLine(to: CGPoint(x: point.x+40, y: point.y-5))
                pointsPath.addLine(to: CGPoint(x: point.x-40, y: point.y-5))
            } else {
                pointsPath.move(to: CGPoint(x: point.x-40, y: point.y+5))
                pointsPath.addLine(to: CGPoint(x: point.x-40, y: point.y - 10))
                pointsPath.addLine(to: CGPoint(x: point.x-30, y: point.y))
                pointsPath.addLine(to: CGPoint(x: point.x-20, y: point.y - 10))
                pointsPath.addLine(to: CGPoint(x: point.x-10, y: point.y))
                pointsPath.addLine(to: CGPoint(x: point.x, y: point.y - 10))
                pointsPath.addLine(to: CGPoint(x: point.x+10, y: point.y))
                pointsPath.addLine(to: CGPoint(x: point.x+20, y: point.y - 10))
                pointsPath.addLine(to: CGPoint(x: point.x+30, y: point.y))
                pointsPath.addLine(to: CGPoint(x: point.x+40, y: point.y - 10))
                pointsPath.addLine(to: CGPoint(x: point.x+40, y: point.y+5))
                pointsPath.addLine(to: CGPoint(x: point.x-40, y: point.y+5))
            }
        }
        overlayLayer.fillColor = color.cgColor
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        overlayLayer.path = pointsPath.cgPath
        CATransaction.commit()
    }
}
