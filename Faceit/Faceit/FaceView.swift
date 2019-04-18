//
//  FaceView.swift
//  Faceit
//
//  Created by peizhang on 2019/4/18.
//  Copyright © 2019 peizhang. All rights reserved.
//

import UIKit

@IBDesignable
class FaceView: UIView {
    
    @IBInspectable
    var isEyeOpen: Bool = true
	
    @IBInspectable
    var scale: CGFloat = 0.9 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var mouthCurvature: Double = 1.0	// 1.0 is full smile and -1.0 is full frown
	
    @IBInspectable
    var lineWidth: CGFloat = 5.0
    
    @IBInspectable
    var color: UIColor = UIColor.orange
    
    private var skullRadius: CGFloat {
        return min(bounds.width, bounds.height) / 2 * scale
    }
    
    private var skullCenter: CGPoint {
        return convert(center, from: superview)
    }
    
    private func pathForSkull() -> UIBezierPath {
        let bezier = UIBezierPath(arcCenter: skullCenter, radius: skullRadius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
    	bezier.lineWidth = lineWidth
    	return bezier
    }
    
    private func pathForMouth() -> UIBezierPath {
        let mouthWidth = skullRadius / Ratios.skullRadiusToMouthWidth
        let mouthHeight = skullRadius / Ratios.skullRadiusToMouthHeight
        let mouthOffset = skullRadius / Ratios.skullRadiusToMouthOffset
    	
        let mouthRect = CGRect(x: skullCenter.x - mouthWidth / 2, y: skullCenter.y + mouthOffset, width: mouthWidth, height: mouthHeight)
    	let path = UIBezierPath()
        
        let smileOffset = CGFloat(max(-1, min(mouthCurvature, 1))) * mouthRect.height
        let start = CGPoint(x: mouthRect.minX, y: mouthRect.midY)
        let end = CGPoint(x: mouthRect.maxX, y: mouthRect.midY)
        let cp1 = CGPoint(x: start.x + mouthRect.width / 3, y: start.y + smileOffset)
        let cp2 = CGPoint(x: end.x - mouthRect.width / 3, y:start.y + smileOffset)
        path.move(to: start)
        path.addCurve(to: end, controlPoint1: cp1, controlPoint2: cp2)
        path.lineWidth = lineWidth
        return path
    }
    
    private enum Eye {
        case left
        case right
    }
    
    private func pathForEye(_ eye: Eye) -> UIBezierPath {
        func centerOfEye(_ eye: Eye) -> CGPoint {
            let eyeOffset = skullRadius / Ratios.skullRadiusToEyeOffset
            var eyeCenter = skullCenter
            eyeCenter.y -= eyeOffset
            eyeCenter.x += ((eye == .left) ? -1 : 1) * eyeOffset
            return eyeCenter
        }
        
        let eyeRadius = skullRadius / Ratios.skullRadiusToEyeRadius
        let eyeCenter = centerOfEye(eye)
        let path : UIBezierPath
        if isEyeOpen {
        	path = UIBezierPath(arcCenter: eyeCenter, radius: eyeRadius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)

        } else {
            path = UIBezierPath()
            path.move(to: CGPoint(x: eyeCenter.x - eyeRadius, y: eyeCenter.y))
        	path.addLine(to: CGPoint(x: eyeCenter.x + eyeRadius, y: eyeCenter.y))
        }
        
        path.lineWidth = lineWidth
        return path
    }
    
    override func draw(_ rect: CGRect) {

        
        color.setStroke()
        
        pathForSkull().stroke()
        
        pathForEye(.left).stroke()
        
        pathForEye(.right).stroke()
        
        pathForMouth().stroke()
    }
    
    private struct Ratios {
        static let skullRadiusToEyeOffset: CGFloat = 3
        static let skullRadiusToEyeRadius: CGFloat = 10
        static let skullRadiusToMouthWidth: CGFloat = 1
        static let skullRadiusToMouthHeight: CGFloat = 3
        static let skullRadiusToMouthOffset: CGFloat = 3
    }

    @objc func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        switch pinchRecognizer.state {
        case .changed, .ended:
            scale *= pinchRecognizer.scale
        	pinchRecognizer.scale = 1.0
        default:
            break
        }
    }
    
}
