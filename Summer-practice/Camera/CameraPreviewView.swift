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

        layer.addSublayer(captureLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var cameraLayer: CALayer?
    private var captureLayer = CALayer()

    func configureWith(previewLayer newLayer: CALayer) {
        cameraLayer?.removeFromSuperlayer()
        cameraLayer = newLayer
        cameraLayer!.bounds = bounds
        layer.addSublayer(cameraLayer!)

        captureLayer.removeFromSuperlayer()
        layer.addSublayer(captureLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cameraLayer?.frame = bounds
        captureLayer.frame = bounds
    }

    func applyCapturePreviewAppearance(with image: UIImage) {
        let cgImage = image.cgImage
        captureLayer.contents = cgImage
    }

    func applyCameraPreviewAppearance() {
        captureLayer.contents = nil
    }
}

