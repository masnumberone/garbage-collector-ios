//
//  BottomStateView.swift
//  Summer-practice
//
//  Created by work on 10.09.2023.
//

import Foundation
import UIKit

class BottomStateView: UIView {

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

    private lazy var backgroundView: UIVisualEffectView = {
        var view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
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
        label.font = .rounded(ofSize: 17, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    private lazy var deleteButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(font: .rounded(ofSize: 22, weight: .semibold), scale: .default),
                                               forImageIn: .normal)

        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false

        button.addTarget(self, action: #selector(deleteCurrentPhoto), for: .touchUpInside)

        return button
    }()


    private lazy var updateButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(font: .rounded(ofSize: 22, weight: .semibold), scale: .default),
                                               forImageIn: .normal)

        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(updateCurrentPhoto), for: .touchUpInside)

        return button
    }()

    func configure(onTapDeleteButton: @escaping () -> Void, onTapUpdateButton: @escaping () -> Void) {
        addSubviews()
        configureConstraints()
        self.onTapDeleteButton = onTapDeleteButton
        self.onTapUpdateButton = onTapUpdateButton
    }

    private func addSubviews() {
        addSubview(backgroundView)
        addSubview(stateLabel)
        addSubview(deleteButton)
        addSubview(updateButton)
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),

            stateLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 19),
            stateLabel.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            stateLabel.trailingAnchor.constraint(lessThanOrEqualTo: backgroundView.trailingAnchor, constant: -19),

            deleteButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),
            deleteButton.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),

            updateButton.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -16),
            updateButton.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor)
        ])
    }


    @objc
    private func deleteCurrentPhoto() {
        onTapDeleteButton?()
    }

    @objc
    private func updateCurrentPhoto() {
        onTapUpdateButton?()
    }
}
