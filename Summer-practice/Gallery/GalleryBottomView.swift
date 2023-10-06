//
//  GalleryBottomView.swift
//  Summer-practice
//
//  Created by work on 03.10.2023.
//

import UIKit

class GalleryBottomView: UIView {
    private var onGridButtonTap: (() -> ())?
    private var onCameraButtonTap: (() -> ())?
    private var onShareButtonTap: (() -> ())?

    private lazy var gridButton: AnimatedButton = {
        let action = UIAction { _ in
            self.onGridButtonTap?()
        }
        let button = AnimatedButton(primaryAction: action)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnableWithScroll = true

        return button
    }()

    private lazy var cameraButton: CaptureButton = {
        let action = UIAction { _ in
            self.onCameraButtonTap?()
        }
        let button = CaptureButton(primaryAction: action, for: .galleryButton)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnableWithScroll = true

        return button
    }()

    private lazy var shareButton: AnimatedButton = {
        let action = UIAction { _ in
            self.onShareButtonTap?()
        }
        let button = AnimatedButton(primaryAction: action)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnableWithScroll = true

        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        confugureButtons()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        addSubview(gridButton)
        addSubview(cameraButton)
        addSubview(shareButton)
    }

    private func confugureButtons() {
        gridButton.configure(withImage: "square.grid.2x2", roundedFontSize: 30, tintColor: .white.withAlphaComponent(0.9))
        shareButton.configure(withImage: "square.and.arrow.up", roundedFontSize: 30, tintColor: .white.withAlphaComponent(0.9))
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            cameraButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            cameraButton.topAnchor.constraint(equalTo: topAnchor),

            gridButton.centerYAnchor.constraint(equalTo: cameraButton.centerYAnchor),
            gridButton.centerXAnchor.constraint(equalTo: cameraButton.leftAnchor, constant: -90),

            shareButton.centerYAnchor.constraint(equalTo: cameraButton.centerYAnchor),
            shareButton.centerXAnchor.constraint(equalTo: cameraButton.rightAnchor, constant: 90)

        ])
    }

    func configureGridButton(with handler: @escaping () -> ()) {
        onGridButtonTap = handler
    }

    func configureCameraButton(with handler: @escaping () -> ()) {
        onCameraButtonTap = handler
    }

    func configureShareButton(with handler: @escaping () -> ()) {
        onShareButtonTap = handler
    }
}
