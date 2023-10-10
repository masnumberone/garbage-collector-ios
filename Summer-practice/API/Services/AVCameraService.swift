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
    func takePhoto(completion: @escaping (UIImage) -> Void)
    func takeHighQualityPhoto(completion: @escaping (UIImage) -> Void)

    var isFlashOn: Bool { get set }
}

class AVCameraService: NSObject, CameraServiceProtocol {
    func getLayerForCameraPreview() -> CALayer {
        sampleBufferDisplayLayerForPreview
    }

    func getLayerForCameraBackground() -> CALayer {
        sampleBufferDisplayLayerForBackground
    }

    func takePhoto(completion: @escaping (UIImage) -> Void) {
        guard !isFlashOn else {
            takeHighQualityPhoto(completion: completion)
            return
        }
        needTakePhotoFromSampleBuffer = true
        takePhotoCompletion = completion
    }

    func takeHighQualityPhoto(completion: @escaping (UIImage) -> Void) {
        takeHighQualityPhotoCompletion = completion
        captureQualityPhoto()
    }

    var isFlashOn = false
    private var needTakePhotoFromSampleBuffer = false
    private var takePhotoCompletion: ((UIImage) -> Void)?
    private var takeHighQualityPhotoCompletion: ((UIImage) -> Void)?
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

    private func captureQualityPhoto() {
        guard let captureOutput = captureOutput else { return }

        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                                       kCVPixelBufferWidthKey as String: 160,
                                       kCVPixelBufferHeightKey as String: 160]
        settings.flashMode = isFlashOn ? .on : .off
        captureOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension AVCameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let ciImage = CIImage(data: imageData) else { return }
        let transformedCiImage = ciImage.transformed(by: .init(rotationAngle: -(.pi / 2)))
        guard let cgImage = CIContext().createCGImage(transformedCiImage, from: transformedCiImage.extent) else { return }
        let image = UIImage(cgImage: cgImage)

        takeHighQualityPhotoCompletion?(image)
        takeHighQualityPhotoCompletion = nil
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

                let ciImage = CIImage(cvPixelBuffer: imageBuffer).transformed(by: .init(rotationAngle: -(.pi / 2)))
                let context = CIContext()
                guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
                let image = UIImage(cgImage: cgImage)

                takePhotoCompletion?(image)
            }
            takePhotoCompletion = nil
            needTakePhotoFromSampleBuffer = false
        }
    }

}





