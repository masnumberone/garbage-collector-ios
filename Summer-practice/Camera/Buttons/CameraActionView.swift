//
//  CameraActionView.swift
//  Summer-practice
//
//  Created by work on 18.09.2023.
//

import UIKit

class CameraActionView: UIView {
    private var onFlashButtonTap: (() -> ())?
    private var onCaptureButtonTap: (() -> ())?
    private var onPickPhotoButtonTap: (() -> ())?
    private var onDisapproveButtonTap: (() -> ())?
    private var onApproveButtonTap: (() -> ())?

    func applyCameraPreviewAppearance() {
        flashButton.alpha = 1
        captureButton.alpha = 1
        pickPhotoButton.alpha = 1

        disapproveButton.alpha = 0
        approveButton.alpha = 0
    }

    func applyCapturePreviewAppearance() {
        let scale = captureButton.getCurrentFrame().width / 90

        approveButton.transform = .init(scaleX: scale, y: scale)
        approveButton.alpha = 0.5

        UIView.animate(withDuration: 0.1) {
            self.approveButton.transform = .identity        
            self.flashButton.alpha = 0
            self.captureButton.alpha = 0
            self.pickPhotoButton.alpha = 0

            self.disapproveButton.alpha = 1
            self.approveButton.alpha = 1
        }

    }

    private lazy var flashButton: AnimatedButton = {
        let action = UIAction { _ in
            self.onFlashButtonTap?()
        }
        let button = AnimatedButton(primaryAction: action)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnableWithScroll = true

        return button
    }()

    private lazy var captureButton: CaptureButton = {
        let action = UIAction { _ in
            self.onCaptureButtonTap?()
        }

        let button = CaptureButton(primaryAction: action, for: .cameraButton)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    private lazy var pickPhotoButton: AnimatedButton = {
        let action = UIAction { _ in
            self.onPickPhotoButtonTap?()
        }
        let button = AnimatedButton(primaryAction: action)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnableWithScroll = true

        return button
    }()

    private lazy var disapproveButton: AnimatedButton = {
        let action = UIAction { _ in
            self.onDisapproveButtonTap?()
        }
        let button = AnimatedButton(primaryAction: action)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnableWithScroll = true

        return button
    }()

    private lazy var approveButton: AnimatedButton = {
        let action = UIAction { _ in
            self.onApproveButtonTap?()
        }
        let button = ApproveCaptureButton(primaryAction: action)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnableWithScroll = true

        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        confugureButtons()
        configureConstraints()

        applyCameraPreviewAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        addSubview(flashButton)
        addSubview(captureButton)
        addSubview(pickPhotoButton)
        addSubview(disapproveButton)
        addSubview(approveButton)
    }

    private func confugureButtons() {
        flashButton.configure(withImage: "bolt", roundedFontSize: 32, tintColor: .white.withAlphaComponent(0.9))
        pickPhotoButton.configure(withImage: "photo.on.rectangle", roundedFontSize: 32, tintColor: .white.withAlphaComponent(0.9))
        disapproveButton.configure(withImage: "xmark", roundedFontSize: 32, tintColor: .white.withAlphaComponent(0.9))
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            captureButton.topAnchor.constraint(equalTo: topAnchor),

            flashButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),
            flashButton.centerXAnchor.constraint(equalTo: captureButton.leftAnchor, constant: -80),

            pickPhotoButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),
            pickPhotoButton.centerXAnchor.constraint(equalTo: captureButton.rightAnchor, constant: 80),

            disapproveButton.centerXAnchor.constraint(equalTo: flashButton.centerXAnchor),
            disapproveButton.centerYAnchor.constraint(equalTo: flashButton.centerYAnchor),

            approveButton.centerXAnchor.constraint(equalTo: captureButton.centerXAnchor),
            approveButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor)

        ])
    }

    func configureFlashButton(with handler: @escaping () -> ()) {
        onFlashButtonTap = handler
    }

    func configureCaptureButton(with handler: @escaping () -> ()) {
        onCaptureButtonTap = handler
    }

    func configurePickPhotoButton(with handler: @escaping () -> ()) {
        onPickPhotoButtonTap = handler
    }

    func configureDisapproveCaptureButton(with handler: @escaping () -> ()) {
        onDisapproveButtonTap = handler
    }

    func configureApproveCaptureButton(with handler: @escaping () -> ()) {
        onApproveButtonTap = handler
    }
}
