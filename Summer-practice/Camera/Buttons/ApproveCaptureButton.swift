//
//  ApproveCaptureButton.swift
//  Summer-practice
//
//  Created by work on 19.09.2023.
//

import UIKit

class ApproveCaptureButton: AnimatedButton {
    init(primaryAction action: UIAction) {
        super.init(frame: .init(x: 0, y: 0, width: 90, height: 90), primaryAction: action)

        backgroundColor = #colorLiteral(red: 0.2823526859, green: 0.2823531032, blue: 0.2901956141, alpha: 1)
        layer.cornerRadius = 45

        isEnableWithScroll = true
        isAnimatedOutsideBounds = false

        configureButton(withImage: "checkmark")
    }

    private func configureButton(withImage systemName: String) {
        let symbolConfiguration = UIImage.SymbolConfiguration(font: .rounded(ofSize: 32, weight: .semibold), scale: .medium)
        
        var buttonImage = UIImage(systemName: systemName) ?? UIImage(systemName: "questionmark")!
        buttonImage = buttonImage.withConfiguration(symbolConfiguration)
        
        var buttonConfiguration = UIButton.Configuration.plain()
        buttonConfiguration.image = buttonImage
        configuration = buttonConfiguration
        tintColor = .white.withAlphaComponent(0.9)
        
        setAnimatedView(imageView!)
//        setAnimation { _, _ in }
    }

    override var intrinsicContentSize: CGSize {
        .init(width: 90, height: 90)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


