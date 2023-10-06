//
//  AVCameraService.swift
//  Summer-practice
//
//  Created by work on 21.09.2023.
//

import AVFoundation
import AVKit

protocol CameraServiceProtocol {
    func getLayerForCameraPreview() -> CALayer
    func getLayerForCameraBackground() -> CALayer
    func takePhoto(handler: @escaping (UIImage) -> Void)
    func takeHighQualityPhoto(handler: @escaping (UIImage) -> Void)

    var isFlashOn: Bool { get set }
}

class AVCameraService: NSObject, CameraServiceProtocol {
    func getLayerForCameraPreview() -> CALayer {
        sampleBufferDisplayLayerForPreview
    }

    func getLayerForCameraBackground() -> CALayer {
        sampleBufferDisplayLayerForBackground
    }

    func takePhoto(handler: @escaping (UIImage) -> Void) {
        needTakePhotoFromSampleBuffer = true
        takePhotoHandler = handler
    }

    func takeHighQualityPhoto(handler: @escaping (UIImage) -> Void) {
        capturePhoto()
    }

    var isFlashOn = false
    private var needTakePhotoFromSampleBuffer = false
    private var takePhotoHandler: ((UIImage) -> Void)?
    private var takeHighQualityPhotoHandler: ((UIImage) -> Void)?
    private let session = AVCaptureSession()
    private var captureOutput: AVCapturePhotoOutput?
    private var videoDataOutput: AVCaptureVideoDataOutput!
    private let userInteractiveQueue = DispatchQueue(label: "com.masnumberone.Summer-practice.cameraQueue", qos: .userInteractive)

    var sampleBufferDisplayLayerForBackground: AVSampleBufferDisplayLayer = {
        let layer = AVSampleBufferDisplayLayer()
        layer.videoGravity = .resize
        layer.transform = CATransform3DMakeRotation( .pi / 2, 0, 0, 1)

        layer.preventsCapture = false

        return layer
    }()

    var sampleBufferDisplayLayerForPreview: AVSampleBufferDisplayLayer = {
        let layer = AVSampleBufferDisplayLayer()
        layer.videoGravity = .resizeAspectFill
        layer.transform = CATransform3DMakeRotation( .pi / 2, 0, 0, 1)

        layer.preventsCapture = false

        return layer
    }()

    override init() {
        super.init()
        configureSession()
    }

    private func configureSession() {
        guard let device = AVCaptureDevice.default(for: .video) else {
            print("No video capture device available")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            session.addInput(input)

            captureOutput = AVCapturePhotoOutput()
            session.sessionPreset = AVCaptureSession.Preset.hd1920x1080
            session.addOutput(captureOutput!)

            videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.setSampleBufferDelegate(self, queue: userInteractiveQueue)
            session.addOutput(videoDataOutput)

            userInteractiveQueue.async { [weak self] in
                self?.session.startRunning()
            }

        } catch {
            print("Error setting up video input: \(error.localizedDescription)")
        }
    }

    private lazy var capturePhoto = { [weak self] in
        guard let self,
              let captureOutput = self.captureOutput else { return }

        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                                       kCVPixelBufferWidthKey as String: 160,
                                       kCVPixelBufferHeightKey as String: 160]
        captureOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension AVCameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        DispatchQueue.main.sync {
            guard let imageData = photo.fileDataRepresentation(),
                  let image = UIImage(data: imageData) else { return }
            let croppedImage = image.cropToSquare()
            takeHighQualityPhotoHandler?(croppedImage)
        }

        takeHighQualityPhotoHandler = nil
    }
}

extension AVCameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if sampleBufferDisplayLayerForPreview.status == .failed {
            sampleBufferDisplayLayerForPreview.flush()
        }       

        if sampleBufferDisplayLayerForBackground.status == .failed {
            sampleBufferDisplayLayerForBackground.flush()
        }


        sampleBufferDisplayLayerForPreview.enqueue(sampleBuffer)
        sampleBufferDisplayLayerForBackground.enqueue(sampleBuffer)

        if needTakePhotoFromSampleBuffer {
            DispatchQueue.main.sync {
                guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

                let rotateTransform = CGAffineTransform(rotationAngle: -(.pi / 2))
                let ciImage = CIImage(cvPixelBuffer: imageBuffer).transformed(by: rotateTransform)
                let context = CIContext()
                guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
                let image = UIImage(cgImage: cgImage)

                takePhotoHandler?(image)
            }
            takePhotoHandler = nil
            needTakePhotoFromSampleBuffer = false
        }
    }

}





