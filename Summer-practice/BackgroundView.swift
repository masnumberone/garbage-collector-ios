//
//  BackgroundView.swift
//  Summer-practice
//
//  Created by work on 15.06.2023.
//

import Foundation
import UIKit

class BackgroundView: UIView, CAAnimationDelegate {
    var backrgoundLayer: CALayer?
    var visualEffectView: UIVisualEffectView!
    
    var overlayView: UIView!
    
    init(blurStyle: UIBlurEffect.Style) {
        super.init(frame: .zero)
        
        let blurEffect = UIBlurEffect(style: blurStyle)
        visualEffectView = UIVisualEffectView(effect: blurEffect)
        
        addSubview(visualEffectView)
    }
    
    func setBackgroundImage(_ newImage: UIImage, withAnimation animationFlag: Bool) {
        let layer = CALayer()
        layer.contents = newImage.cgImage
        setBackgroundLayer(layer, withAnimation: animationFlag)
    }

    func setBackgroundLayer(_ newLayer: CALayer, withAnimation animationFlag: Bool) {
        if (animationFlag) {
            
            layer.insertSublayer(newLayer, at: 0)
            newLayer.frame = bounds
            
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.2)
            
            CATransaction.setCompletionBlock {
                self.backrgoundLayer?.removeFromSuperlayer()
                self.backrgoundLayer = newLayer
            }
            
            let animation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
            animation.fromValue = 1.0
            animation.toValue = 0.0
            
            backrgoundLayer?.opacity = 0.0
            backrgoundLayer?.add(animation, forKey: #keyPath(CALayer.opacity))
            
            CATransaction.commit()
            
        } else {
            backrgoundLayer?.removeFromSuperlayer()
            backrgoundLayer = newLayer

            backrgoundLayer!.frame = bounds
            layer.insertSublayer(backrgoundLayer!, at: 0)
        }
    }
    
    var transitionLayer: CALayer!

    func configureDarkBlur(withAlpha alpha: CGFloat) {
        if let vfxSubView = visualEffectView.subviews.first(where: {
            String(describing: type(of: $0)) == "_UIVisualEffectBackdropView"
            
        }) {
            vfxSubView.layer.filters?.remove(at: 0)
            vfxSubView.layer.filters?.remove(at: 0)
                    
            let gaussianBlur = vfxSubView.layer.filters![0] as! NSObject
            gaussianBlur.setValue(100, forKey: "inputRadius")
        }

        let darkBlur = UIView(frame: bounds)
        darkBlur.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: alpha)
        darkBlur.alpha = 1.0

        insertSubview(darkBlur, aboveSubview: visualEffectView)
    }

    override func layoutSubviews() {
        subviews.forEach { $0.frame = self.bounds }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



