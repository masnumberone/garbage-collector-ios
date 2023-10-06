//
//  CameraViewController.swift
//  Summer-practice
//
//  Created by work on 03.06.2023.
//

import Foundation
import UIKit

class CameraViewController: UIViewController {
    private let backgroundCaptureView: BackgroundView = {
        let view = BackgroundView(blurStyle: .systemThinMaterialDark)
        view.configureDarkBlur(withAlpha: 0.75)
        view.isHidden = true

        return view
    }()

    private let previewView: CameraPreviewView = {
        let view = CameraPreviewView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let actionButtonsView: CameraActionView = {
        var view = CameraActionView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var historyButton: HistoryButton = {
        let action = UIAction { _ in
            self.historyButtonTapped?()
        }
        let button = HistoryButton(primaryAction: action)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    private let model: BinPhotoServiceProtocol
    private var cameraService: CameraServiceProtocol?
    var capturePreviewDidAppear: (() -> Void)?
    var capturePreviewDidDisappear: (() -> Void)?
    var historyButtonTapped: (() -> Void)?

    init(with model: BinPhotoServiceProtocol, _ cameraService: CameraServiceProtocol) {
        self.model = model
        self.cameraService = cameraService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private enum State {
        case cameraPreview
        case capturePreview(UIImage)
    }

    private var state: State = .cameraPreview {
        didSet {
            switch state {
            case .cameraPreview:
                backgroundCaptureView.isHidden = true
                previewView.applyCameraPreviewAppearance()
                actionButtonsView.applyCameraPreviewAppearance()
                capturePreviewDidDisappear?()
            case .capturePreview(let image):
                backgroundCaptureView.isHidden = false
                backgroundCaptureView.setBackgroundImage(image, withAnimation: false)
                previewView.applyCapturePreviewAppearance(with: image.cropToSquare())
                actionButtonsView.applyCapturePreviewAppearance()
                capturePreviewDidAppear?()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(backgroundCaptureView)
        view.addSubview(previewView)
        view.addSubview(actionButtonsView)
        view.addSubview(historyButton)

        configureConstraints()
        configurePreviewView()
        configureButtons()
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: view.topAnchor, constant: 137),
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewView.heightAnchor.constraint(equalTo: previewView.widthAnchor),

            actionButtonsView.topAnchor.constraint(equalTo: previewView.bottomAnchor, constant: 48),
            actionButtonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            actionButtonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            actionButtonsView.heightAnchor.constraint(equalToConstant: 90),

            historyButton.topAnchor.constraint(equalTo: actionButtonsView.bottomAnchor, constant: 46),
            historyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            historyButton.widthAnchor.constraint(equalToConstant: 120),
            historyButton.heightAnchor.constraint(equalToConstant: 66)
        ])
    }    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        backgroundCaptureView.frame = view.bounds
    }

    private func configurePreviewView() {
        let cameraPreviewLayer = cameraService!.getLayerForCameraPreview()
        previewView.configureWith(previewLayer: cameraPreviewLayer)
    }

    private func configureButtons() {
        actionButtonsView.configureCaptureButton(with: onCaptureButtonTapped)
        actionButtonsView.configureFlashButton(with: onFlashButtonTapped)
        actionButtonsView.configurePickPhotoButton(with: onPickButtonTapped)
        actionButtonsView.configureApproveCaptureButton(with: onApproveButtonTapped)
        actionButtonsView.configureDisapproveCaptureButton(with: onDisapproveButtonTapped)

        let randomImage = UIImage(data: model.getPhotos().randomElement()!.data!)!
        historyButton.configure(with: randomImage)

        
    }

    private lazy var onCaptureButtonTapped = { [weak self] in
        guard let self else { return }
        self.cameraService!.takePhoto { image in
            self.state = .capturePreview(image)
        }
    }

    private lazy var onApproveButtonTapped = { [weak self] in
        guard let self,
              case let .capturePreview(capturedImage) = state else { return }
        state = .cameraPreview

        DispatchQueue.global(qos: .default).async {
            let croppedImage = capturedImage.cropToSquare()
            let photo = BinPhoto()
            photo.date = Date.now
            photo.data = croppedImage.jpegData(compressionQuality: 1.0)
            self.model.saveAndProcessPhoto(photo)
        }
    }

    private lazy var onDisapproveButtonTapped = { [weak self] in
        guard let self else { return }
        state = .cameraPreview
    }

    private lazy var onFlashButtonTapped = { [weak self] in
        guard let self else { return }
        // TODO: Camera flash
        cameraService!.isFlashOn.toggle()
    }

    private lazy var onPickButtonTapped = { [weak self] in
        // TODO: Pick photo
    }
}
