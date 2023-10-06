//
//  GalleryStateView.swift
//  Summer-practice
//
//  Created by work on 10.09.2023.
//

import Foundation
import UIKit

class GalleryStateView: UIView {
    enum State {
        case fail
        case noFound
        case found(Int)
    }

    var state: State = .fail {
        willSet {
            switch newValue {
            case .fail:
                stateLabel.text = "Fail send photo"
                stateLabel.textColor = #colorLiteral(red: 1, green: 0.4932563305, blue: 0.4739957452, alpha: 1)
            case .noFound:
                stateLabel.text = "Theare no trash bins"
                stateLabel.textColor = .white
            case .found(let count):
                stateLabel.text = "Found \(count) bins"
                stateLabel.textColor = .white
            }
        }
    }

    var onTapDeleteButton: (() -> Void)?
    var onTapUpdateButton: (() -> Void)?

    private lazy var backgroundView: BackgroundView = {
        var view = BackgroundView(blurStyle: .systemThinMaterialLight)
        view.configureDarkBlur(withAlpha: 0.1)
        view.clipsToBounds = true
        view.layer.cornerRadius = 26
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerCurve = .continuous

        return view
    }()

    private lazy var stateLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .left
        label.text = "Trash is ok"
        label.textColor = .white
        label.numberOfLines = 1
        label.font = .rounded(ofSize: 17, weight: .semibold)

        return label
    }()
    
    private lazy var deleteButton: UIButton = {
        let action = UIAction { _ in
            self.onTapDeleteButton?()
        }
        var button = AnimatedButton(primaryAction: action)
        button.configure(withImage: "trash", roundedFontSize: 24, tintColor: .systemGray)

        return button
    }()


    private lazy var updateButton: UIButton = {
        let action = UIAction { _ in
            self.onTapUpdateButton?()
        }
        var button = AnimatedButton(primaryAction: action)
        button.configure(withImage: "arrow.clockwise", roundedFontSize: 24, tintColor: .systemGray)

        return button
    }()

    private lazy var hstack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [stateLabel, updateButton, deleteButton])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.layoutMargins = .init(top: 0, left: 18, bottom: 0, right: 10)
        stackView.insetsLayoutMarginsFromSafeArea = false
        stackView.isLayoutMarginsRelativeArrangement = true

        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    func configure(onTapDeleteButton: @escaping () -> Void, onTapUpdateButton: @escaping () -> Void) {
        addSubviews()
        configureConstraints()
        self.onTapDeleteButton = onTapDeleteButton
        self.onTapUpdateButton = onTapUpdateButton
    }

    private func addSubviews() {
        addSubview(backgroundView)
        addSubview(hstack)
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),

            hstack.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
            hstack.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            hstack.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            hstack.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),

            updateButton.widthAnchor.constraint(lessThanOrEqualToConstant: 42),
            updateButton.heightAnchor.constraint(lessThanOrEqualToConstant: 42),

            deleteButton.widthAnchor.constraint(lessThanOrEqualToConstant: 42),
            deleteButton.heightAnchor.constraint(lessThanOrEqualToConstant: 42)
        ])
    }
}
