//
//  TitleView.swift
//  Summer-practice
//
//  Created by work on 15.09.2023.
//

import UIKit

class TitleView: UIView {
    enum State {
        case cameraPreview
        case capturePreview
        case gallery
    }

    var onTapSettingsButton: (() -> Void)?

    var state: State = .cameraPreview {
        willSet {
            switch newValue {
            case .cameraPreview:
                titleLabel.text = "Take photo to detect bin"
                settingsButton.isHidden = false
            case .capturePreview:
                titleLabel.text = "Check photo C:"
                settingsButton.isHidden = true
            case .gallery:
                titleLabel.text = "History"
                settingsButton.isHidden = true
            }
        }
    }

    private lazy var backgroundView: BackgroundView = {
        var view = BackgroundView(blurStyle: .systemThinMaterialLight)
        view.configureDarkBlur(withAlpha: 0.1)
        view.clipsToBounds = true
        view.layer.cornerRadius = 22
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerCurve = .continuous

        return view
    }()

    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 1
        label.font = .rounded(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var settingsButton: UIButton = {
        let action = UIAction { _ in
            self.onTapSettingsButton?()
        }
        var button = AnimatedButton(primaryAction: action)
        button.configure(withImage: "gear", roundedFontSize: 22, tintColor: .white)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubviews()
        configureConstraints()
    }

    override func tintColorDidChange() {
        switch tintAdjustmentMode {
        case .dimmed:
            titleLabel.textColor = .white.withAlphaComponent(0.1)
            break
        case .normal:
            titleLabel.textColor = .white
        default:
            break
        }
    }

    private func addSubviews() {
        addSubview(backgroundView)
        addSubview(titleLabel)
        addSubview(settingsButton)
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            backgroundView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -22),
            backgroundView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 22),
            backgroundView.heightAnchor.constraint(equalTo: heightAnchor),

            settingsButton.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
            settingsButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    override func layoutSubviews() {
        subviews.forEach { $0.frame = self.frame }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if settingsButton.point(inside: convert(point, to: settingsButton), with: event) {
            return super.hitTest(point, with: event)
        }

        return nil
    }
}
