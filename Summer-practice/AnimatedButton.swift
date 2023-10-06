//
//  AnimatedButton.swift
//  Summer-practice
//
//  Created by work on 15.09.2023.
//

import UIKit

class AnimatedButton: UIButton, UIGestureRecognizerDelegate {
    override var isHighlighted: Bool {
        didSet {
            guard !isHighlightLock else { return }
            let animatedView = self.animatedView ?? self
            animation(animatedView, self)
        }
    }

    private var isHighlightLock = false
    private var animatedView: UIView?
    private var animation: (UIView, AnimatedButton) -> () = { view, button in
        UIView.animate(withDuration: 0.3,
                       delay: .zero,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0,
                       options: [.beginFromCurrentState, .allowUserInteraction, .curveEaseInOut]) {
            view.transform = button.isHighlighted ? .init(scaleX: 0.8, y: 0.8) : .identity
            button.imageView?.tintColor = button.isHighlighted ? .white.withAlphaComponent(0.7) : .white.withAlphaComponent(0.9)
        }
    }

    private func setIsHighlitedTrueAndDisableChanges() {
        guard !isHighlightLock else { return }
        isHighlighted = true
        isHighlightLock = true
    }

    private func setIsHighlitedFalseAndEnableChanges() {
        isHighlightLock = false
        isHighlighted = false
    }

    func setAnimatedView(_ view: UIView) {
        guard subviews.contains(view) else { return }
        self.animatedView = view
    }

    func setAnimation(_ animation: @escaping (UIView, AnimatedButton) -> ()) {
        self.animation = animation
    }

    var isEnableWithScroll = false
    var isAnimatedOutsideBounds = true
    var primaryAction: UIAction

    init(frame: CGRect, primaryAction action: UIAction) {
        self.primaryAction = action
        super.init(frame: frame)
    }

    convenience init(primaryAction action: UIAction) {
        self.init(frame: .zero, primaryAction: action)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHighlighted = true
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isAnimatedOutsideBounds else { return }
        touches.forEach { touch in
            if !touchInsideBoundsWithInset(touch) { isHighlighted = false }
        }

        super.touchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isHighlighted = false

        for touch in touches {
            if touchInsideBoundsWithInset(touch) {
                sendAction(primaryAction)
                break
            }
        }
    }

    private func touchInsideBoundsWithInset(_ touch: UITouch) -> Bool {
        let touchPoint = touch.location(in: self)
        let insetBounds = UIEdgeInsets(top: -15, left: -15, bottom: -15, right: -15)

        return bounds.inset(by: insetBounds).contains(touchPoint)
    }

    

    func configure(withImage systemName: String, roundedFontSize fontSize: CGFloat, tintColor color: UIColor) {
        let symbolConfiguration = UIImage.SymbolConfiguration(font: .rounded(ofSize: fontSize, weight: .semibold), scale: .medium)

        var buttonImage = UIImage(systemName: systemName) ?? UIImage(systemName: "questionmark")!
        buttonImage = buttonImage.withConfiguration(symbolConfiguration)

        var buttonConfiguration = UIButton.Configuration.plain()
        buttonConfiguration.image = buttonImage
        
        configuration = buttonConfiguration
        tintColor = color
    }
}
