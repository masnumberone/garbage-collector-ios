//
//  PreviewViewController.swift
//  Summer-practice
//
//  Created by work on 04.06.2023.
//

import UIKit

class PreviewViewController: UIViewController {
    
    private lazy var imageView: UIImageView = {
        var view = UIImageView(image: image)
        view.clipsToBounds = true
        view.layer.cornerRadius = 60
        view.layer.cornerCurve = .continuous
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var sendButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        view.layer.cornerRadius = 45
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var backgroundView: BackgroundView = {
        let view = BackgroundView(blurStyle: .systemThinMaterialDark)
        view.configureDarkBlur()
        return view
    }()
    
    
    private var image: UIImage!
    private weak var delegate: ViewControllerDelegateProtocol!
    
    init(withDelegate delegate: ViewControllerDelegateProtocol) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.backgroundColor = .systemBackground
        view.addSubview(backgroundView)
        view.addSubview(imageView)
        view.addSubview(sendButton)
        view.addSubview(cancelButton)
        
        configureConstraints()
        
        cancelButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(send), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        backgroundView.frame = view.bounds
        backgroundView.backrgoundLayer?.frame = view.bounds
    }
    
    let dateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        
        return dateFormatter
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        print(dateFormatter.string(from: .now), "VC did appear")
    }
    
    func configure(withImage image: UIImage) {
        self.image = image
        imageView.image = image
        
        let imageLayer = CALayer()
        imageLayer.contents = image.cgImage
        backgroundView.setLayer(imageLayer, withAnimation: false)
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 137),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            
            sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 48),
            sendButton.heightAnchor.constraint(equalToConstant: 90),
            sendButton.widthAnchor.constraint(equalToConstant: 90),
            
            cancelButton.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor),
            cancelButton.centerXAnchor.constraint(equalTo: sendButton.centerXAnchor, constant: -130),
            cancelButton.heightAnchor.constraint(equalToConstant: 25),
            cancelButton.widthAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    @objc
    private func dismissVC() {
        dismiss(animated: false)
    }
    
    @objc
    private func send() {
        let photo = BinPhoto()
        
        photo.id = UUID()
        photo.date = Date.now
        photo.data = image.jpegData(compressionQuality: 0.8)

        print("send photo: ", dateFormatter.string(from: photo.date!))
        
        BinPhotoProvider.shared.saveContext()
        delegate.needUpdate()
        
        QueryManager.shared.classifyBin(in: photo) { result in
            switch result {
            case .success(let bins):
                photo.bins = NSSet(array: bins)
                photo.is_checked = true
                
                bins.forEach {
                    $0.binPhoto = photo
                    $0.id_bin_photo = photo.id
                }
                
            case .failure(_):
                photo.is_checked = false
            }
            
            DispatchQueue.main.async {
                BinPhotoProvider.shared.saveContext()
                self.delegate.needUpdate()
            }
            
        }
        
        dismissVC()
    }
    
    
}


