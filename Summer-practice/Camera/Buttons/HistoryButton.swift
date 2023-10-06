//
//  HistoryButton.swift
//  Summer-practice
//
//  Created by work on 01.10.2023.
//

import UIKit

class HistoryButton: AnimatedButton {
    lazy var roundedImageView: UIImageView = {
        let view = UIImageView(frame: .init(x: 0, y: 0, width: 34, height: 34))
        view.clipsToBounds = true
        view.layer.cornerRadius = 10

        view.isUserInteractionEnabled = false
        return view
    }()

    lazy var historyLabel: UILabel = {
        let view = UILabel(frame: .init(x: 46, y: 6, width: 75, height: 22))

        view.isUserInteractionEnabled = false
        return view
    }()

    lazy var arrowImageView: UIImageView = {
        let view = UIImageView(frame: .init(x: 43, y: 50, width: 35, height: 10))

        view.isUserInteractionEnabled = false
        return view
    }()


    init(primaryAction action: UIAction) {
        super.init(frame: .zero, primaryAction: action)

        isEnableWithScroll = true

        historyLabel.attributedText = NSAttributedString(string: "History", attributes: [.font : UIFont.rounded(ofSize: 20, weight: .bold), .kern : 0.2])
//        historyLabel.contentMode = .scaleAspectFill

        let imageConf = UIImage.SymbolConfiguration(font: .rounded(ofSize: 30, weight: .semibold))
        let image = UIImage(systemName: "chevron.compact.down", withConfiguration: imageConf)!
        arrowImageView.image = image
        arrowImageView.contentMode = .scaleAspectFill

        tintColor = .white.withAlphaComponent(0.9)
        historyLabel.textColor = tintColor


        addSubview(roundedImageView)
        addSubview(historyLabel)
        addSubview(arrowImageView)

        setAnimation { view, button in
            UIView.animate(withDuration: 0.3,
                           delay: .zero,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0,
                           options: [.beginFromCurrentState, .allowUserInteraction, .curveEaseInOut]) {
                view.transform = button.isHighlighted ? .init(scaleX: 0.9, y: 0.9) : .identity
                view.alpha = button.isHighlighted ? 0.9 : 1
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with image: UIImage) {
        roundedImageView.image = image
    }
}
