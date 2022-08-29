//
//  CameraView.swift
//  Bubblia
//
//  Created by 황정현 on 2022/08/29.
//

import UIKit
import AVFoundation

class CameraView: UIView {

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
        for point in points {
            pointsPath.move(to: point)
            pointsPath.addArc(withCenter: point, radius: 5, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        }
        overlayLayer.fillColor = color.cgColor
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        overlayLayer.path = pointsPath.cgPath
        CATransaction.commit()
    }
}
