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
    

    
    func setLayer(_ newLayer: CALayer, withAnimation animationFlag: Bool) {
        
//        UIView.animate(withDuration: 1) {
//            self.layer.addSublayer(layer)
//        } completion: { a in
//            print(a)
//        }
        
//        backrgoundLayer?.removeFromSuperlayer()
//        backrgoundLayer = layer
//        backrgoundLayer!.frame = frame
//
//        self.layer.insertSublayer(backrgoundLayer!, at: 0)
        
        
        
        
        
//        let animation = CATransition();
//
//        //Set transition properties
//        animation.type = .fade;
//        animation.subtype = .fromTop;
//        animation.duration = 2.0;
//        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut);
//
////        backrgoundLayer?.removeFromSuperlayer()
//        animation.delegate = self
//
//        newLayer.frame = bounds
//        transitionLayer = newLayer
//
//        if let backrgoundLayer = backrgoundLayer {
//            self.layer.addSublayer(newLayer)
////            self.layer.insertSublayer(newLayer, above: backrgoundLayer)
//        } else {
//            self.layer.insertSublayer(newLayer, at: 1)
//        }
//
//        visualEffectView.setNeedsLayout()
//
//
////        self.layer.addSublayer(backrgoundLayer!)
////        self.layer.insertSublayer(backrgoundLayer!, at: 0)
//
//        //Add transition to imageView, so that the entire view does not refresh
//        self.layer.add(animation, forKey: "animation")


//        self.layer.insertSublayer(backrgoundLayer!, at: 0)
        
        
//        backrgoundLayer = layer

        
//        // попробовать переделать на транзакцию
//
//        layer.frame = bounds
//        layer.opacity = 0.0
//
//        // Добавление нового слоя
//        if let backrgoundLayer = backrgoundLayer {
//            self.layer.insertSublayer(layer, above: backrgoundLayer)
//        } else {
//            self.layer.insertSublayer(layer, at: 0)
//        }
//
//        // Анимация появления слоя
//        let animation = CABasicAnimation(keyPath: "opacity")
//        animation.fromValue = 0.0
//        animation.toValue = 1.0
//        animation.duration = 0.2
//
//        layer.opacity = 1.0
//        layer.add(animation, forKey: "opacityAnimation")
//
//
//        DispatchQueue.main.asyncAfter(wallDeadline: .now() + animation.duration) {
//            self.backrgoundLayer?.removeFromSuperlayer()
//            self.backrgoundLayer = layer
//
//        }
        
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
        
        
        
//        if let backrgoundLayer = backrgoundLayer {
//            newLayer.frame = bounds
//            layer.insertSublayer(newLayer, above: backrgoundLayer)
//            transitionLayer = newLayer
//
//
//
//        } else {
//            newLayer.frame = bounds
//            layer.insertSublayer(newLayer, at: 0)
//            transitionLayer = newLayer
//        }
//
//        let animation = CABasicAnimation()
//        animation.keyPath = "opacity"
//        animation.fromValue = 0
//        animation.toValue = 1
//        animation.duration = 2.0
//
//        animation.delegate = self
//
//        newLayer.add(animation, forKey: "opacityAnimation")
        

//
//        newLayer.frame = bounds
//        layer.insertSublayer(newLayer, at: 0)
//        transitionLayer = newLayer
////        backrgoundLayer?.opacity = 1.0
////
////        let animation = CABasicAnimation()
////        animation.keyPath = "opacity"
////        animation.duration = 2.0
////        animation.fromValue = 1.0
////        animation.toValue = 0.0
////
////        animation.delegate = self
////
////        backrgoundLayer?.opacity = 0.0
////        backrgoundLayer?.add(animation, forKey: "fade")
//
//        animation = CABasicAnimation()
//        animation!.keyPath = "opacity"
//        animation!.fromValue = 1
//        animation!.toValue = 0
//        animation!.duration = 2.0
//
//        animation!.delegate = self
//
//        newLayer.add(animation!, forKey: "opacityAnimation")

    }
    
    var transitionLayer: CALayer!
//    var animation: CABasicAnimation!
    
//    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//        if flag {
//            backrgoundLayer?.removeFromSuperlayer()
//            backrgoundLayer = transitionLayer
//            print("true")
//        } else {
////            transitionLayer?.removeFromSuperlayer()
////            backrgoundLayer =
////            anim.isRemovedOnCompletion = true
////            anim
//            print("false")
//        }
//    }
    
    
    
    
    

    
    func configureDarkBlur() {
        if let vfxSubView = visualEffectView.subviews.first(where: {
//            String(describing: type(of: $0)) == "_UIVisualEffectSubview"
            String(describing: type(of: $0)) == "_UIVisualEffectBackdropView"
            
        }) {
            vfxSubView.layer.filters?.remove(at: 0)
            vfxSubView.layer.filters?.remove(at: 0)
                    
            let gaussianBlur = vfxSubView.layer.filters![0] as! NSObject
            gaussianBlur.setValue(80, forKey: "inputRadius")
        }
        
        let darkBlur = UIView(frame: bounds)
        darkBlur.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)
        
        insertSubview(darkBlur, aboveSubview: visualEffectView)
    }
    
    override func layoutSubviews() {
        subviews.forEach { $0.frame = self.frame }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



