//
//  CameraPreviewView.swift
//  Summer-practice
//
//  Created by work on 15.09.2023.
//

import UIKit

class CameraPreviewView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        clipsToBounds = true
        layer.cornerRadius = 60
        layer.cornerCurve = .continuous
        translatesAutoresizingMaskIntoConstraints = false

        captureView.alpha = 0
        addSubview(captureView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var cameraLayer: CALayer?
    private var captureView = UIImageView()

    func configureWith(previewLayer newLayer: CALayer) {
        cameraLayer?.removeFromSuperlayer()
        cameraLayer = newLayer
        cameraLayer!.bounds = bounds
        layer.addSublayer(cameraLayer!)

        captureView.removeFromSuperview()
        addSubview(captureView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cameraLayer?.frame = bounds
        captureView.frame = bounds
    }

    func applyCapturePreviewAppearance(with image: UIImage) {
        captureView.image = image
        captureView.alpha = 1
    }

    func applyCameraPreviewAppearance() {
        captureView.alpha = 0
    }
}

