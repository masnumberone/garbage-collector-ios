//
//  CameraViewController.swift
//  Summer-practice
//
//  Created by work on 03.06.2023.
//

import Foundation
import UIKit
import AVFoundation
import AVKit

class CameraViewController: UIViewController {
    private let session = AVCaptureSession()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var captureOutput: AVCapturePhotoOutput?
    private var videoDataOutput: AVCaptureVideoDataOutput!
    
    private var needShoot = false
    weak private var backgroundView: BackgroundView!
    weak private var delegate: ViewControllerDelegateProtocol!
    
    private let previewView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let captureButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = #colorLiteral(red: 1, green: 0.8, blue: 0, alpha: 1)
        button.layer.cornerRadius = 45
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var sampleBufferDisplayLayer: AVSampleBufferDisplayLayer = {
        let layer = AVSampleBufferDisplayLayer()
        layer.videoGravity = .resizeAspectFill
        layer.transform = CATransform3DMakeRotation( .pi / 2, 0, 0, 1)
        
        return layer
    }()
    
    lazy var previewVC: PreviewViewController! = {
        let vc = PreviewViewController(withDelegate: self.delegate)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()
    
    let dateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        
        return dateFormatter
    }()
    
    init(withDelegate delegate: ViewControllerDelegateProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.backgroundView = delegate.getCameraBackgroundView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        
//        view.addSubview(backgroundView)
            
        view.addSubview(previewView)
        view.addSubview(captureButton)
        backgroundView.setLayer(sampleBufferDisplayLayer, withAnimation: false)
        
        configureConstraints()
        
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
                
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video) else {
            print("No video capture device available")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            session.addInput(input)
            
            
            captureOutput = AVCapturePhotoOutput()
            session.addOutput(captureOutput!)
            
            videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
            session.addOutput(videoDataOutput)

            
//            session.sessionPreset = AVCaptureSession.Preset.hd1920x1080
            
       
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            videoPreviewLayer?.videoGravity = .resizeAspectFill
            videoPreviewLayer?.cornerRadius = 60
            previewView.layer.addSublayer(videoPreviewLayer!)
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.startRunning()
            }
             
            
        } catch {
            print("Error setting up video input: \(error.localizedDescription)")
        }
    }
    
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            
            
            previewView.topAnchor.constraint(equalTo: view.topAnchor, constant: 137),
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewView.widthAnchor.constraint(equalTo: previewView.heightAnchor),
            
            
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.topAnchor.constraint(equalTo: previewView.bottomAnchor, constant: 48),
            captureButton.heightAnchor.constraint(equalToConstant: 90),
            captureButton.widthAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        videoPreviewLayer?.frame = previewView.bounds
  
        
    }
    
    @objc private func captureButtonTapped() {
        guard let captureOutput = captureOutput else { return }

        let settings = AVCapturePhotoSettings()

        captureOutput.capturePhoto(with: settings, delegate: self)
        
        needShoot = true
    }
    
    func setBackgroundTransparency(_ transparency: CGFloat) {
        
        backgroundView.alpha = transparency

    }
    
    
    private func cropImageToSquare(_ image: UIImage) -> UIImage {
        let cgImage = image.cgImage!
        
        // The shortest side
        let sideLength = min(
            cgImage.width,
            cgImage.height
        )

        // Determines the x,y coordinate of a centered
        // sideLength by sideLength square
        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
        let xOffset = (cgImage.width - sideLength) / 2
        let yOffset = (cgImage.height - sideLength) / 2

        // The cropRect is the rect of the image to keep,
        // in this case centered
        let cropRect = CGRect(x: xOffset,
                              y: yOffset,
                              width: sideLength,
                              height: sideLength
        )

        // Center crop the image
//        let cgImage = image.cgImage!
        let croppedCgImage = cgImage.cropping(to: cropRect)!
        

        // Use the cropped cgImage to initialize a cropped
        // UIImage with the same image scale and orientation
        let croppedImage = UIImage(
            cgImage: croppedCgImage,
            scale: image.imageRendererFormat.scale,
            orientation: image.imageOrientation
        )
                
        return croppedImage
    }

    
    
}


extension CameraViewController: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print(dateFormatter.string(from: .now), "did finish photo")

        if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) {

            let croppedImage = cropImageToSquare(image)
            
//            !!!!!!!!!!!!!!!
            previewVC.configure(withImage: croppedImage)
        }
    }
    
    
}



extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if sampleBufferDisplayLayer.status == .failed {
            sampleBufferDisplayLayer.flush()
        }
        
        if needShoot {
            needShoot.toggle()
            
            guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                return
            }
            
            let ciImage = CIImage(cvPixelBuffer: imageBuffer).transformed(by: CGAffineTransform(rotationAngle: -(.pi / 2)))
            
            let context = CIContext()
            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
                return
            }

            let croppedImage = cropImageToSquare(UIImage(cgImage: cgImage))
                       
            
            previewVC.configure(withImage: croppedImage)
            present(previewVC, animated: false)
        }
      
        DispatchQueue.main.async {
            self.sampleBufferDisplayLayer.enqueue(sampleBuffer)
        }
        
    }
    
}


