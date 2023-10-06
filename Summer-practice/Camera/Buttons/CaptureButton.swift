//
//  CaptureButton.swift
//  Summer-practice
//
//  Created by work on 17.09.2023.
//

import UIKit

class CaptureButton: AnimatedButton {
    private lazy var whiteCenterView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .white

        view.isUserInteractionEnabled = false
        return view
    }()

    enum Appeareance {
        case cameraButton
        case galleryButton
    }

    init(primaryAction action: UIAction, for appeareance: Appeareance) {
        super.init(frame: .zero, primaryAction: action)

        let border: CGFloat
        switch appeareance {
        case .cameraButton:
            frame = .init(x: 0, y: 0, width: 90, height: 90)
            border = 4
        case .galleryButton:
            frame = .init(x: 0, y: 0, width: 52, height: 52)
            whiteCenterView.backgroundColor = .white.withAlphaComponent(0.9)
            border = 3
        }

        configureWhiteCenterView(with: .init(x: border * 2,
                                             y: border * 2,
                                             width: frame.width - border * 4,
                                             height: frame.height - border * 4))

        layer.borderWidth = border
        layer.borderColor = #colorLiteral(red: 1, green: 0.7215477228, blue: 0.0005452816258, alpha: 1).cgColor
        layer.cornerRadius = frame.height / 2
        addSubview(whiteCenterView)
        
        configureAnimation(for: appeareance)
    }

    private func configureWhiteCenterView(with frame: CGRect) {
        whiteCenterView.frame = frame
        whiteCenterView.layer.cornerRadius = frame.height / 2
    }

    private func configureAnimation(for appearance: Appeareance) {
        isEnableWithScroll = true
        isAnimatedOutsideBounds = false

        switch appearance {
        case .cameraButton:
            setAnimation { view, button in
                UIView.animate(withDuration: 0.3,
                               delay: .zero,
                               usingSpringWithDamping: 0.7,
                               initialSpringVelocity: 0,
                               options: [.beginFromCurrentState, .allowUserInteraction, .curveEaseInOut]) {
                    view.transform = button.isHighlighted ? .init(scaleX: 0.7, y: 0.7) : .identity
                    view.backgroundColor = button.isHighlighted ? .white.withAlphaComponent(0.2) : .white
                }
            }
            setAnimatedView(whiteCenterView)
        case .galleryButton:
            setAnimation { view, button in
                UIView.animate(withDuration: 0.3,
                               delay: .zero,
                               usingSpringWithDamping: 0.7,
                               initialSpringVelocity: 0,
                               options: [.beginFromCurrentState, .allowUserInteraction, .curveEaseInOut]) {
                    view.transform = button.isHighlighted ? .init(scaleX: 0.9, y: 0.9) : .identity
                    view.layer.borderColor = button.isHighlighted ? #colorLiteral(red: 1, green: 0.7215477228, blue: 0.0005452816258, alpha: 1).withAlphaComponent(0.7).cgColor : #colorLiteral(red: 1, green: 0.7215477228, blue: 0.0005452816258, alpha: 1).cgColor
                    view.subviews[0].backgroundColor = button.isHighlighted ? .white.withAlphaComponent(0.6) : .white.withAlphaComponent(0.9)
                }
            }
        }
    }

    func getCurrentFrame() -> CGRect {
        return  whiteCenterView.layer.presentation()!.frame
    }

    override var intrinsicContentSize: CGSize {
        frame.size
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

