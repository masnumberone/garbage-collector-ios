//
//  ViewController.swift
//  Summer-practice
//
//  Created by work on 02.06.2023.
//

import UIKit


class ViewController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = view.frame.size
        layout.minimumLineSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .clear

        return collectionView
    }()
    
    
    lazy var backgroundPhotoView: BackgroundView = {
        let view = BackgroundView(blurStyle: .systemMaterialDark)
        view.alpha = 0
        
        return view
    }()
    
    private let backgroundCameraView: BackgroundView = {
        let view = BackgroundView(blurStyle: .systemThinMaterialDark)  // почему Thin???
        view.configureDarkBlur()
        
        return view
    }()
    
    private lazy var bottomBackground: UIVisualEffectView = {
        var view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        view.clipsToBounds = true
        view.layer.cornerRadius = 26
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        
        return view
    }()
    
    private lazy var stateLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .left
        label.text = "Trash is ok"
        label.textColor = .white
        label.font = .rounded(ofSize: 17, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        
        
        return label
    }()
    
    
    private lazy var deleteButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(font: .rounded(ofSize: 22, weight: .semibold), scale: .default),
                                               forImageIn: .normal)

        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        
        button.addTarget(self, action: #selector(deleteCurrentPhoto), for: .touchUpInside)
        
        return button
    }()
    
    
    private lazy var updateButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(font: .rounded(ofSize: 22, weight: .semibold), scale: .default),
                                               forImageIn: .normal)

        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        
        button.addTarget(self, action: #selector(updateCurrentPhoto), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var preferencesButton: UIButton = {
        var button = UIButton()
        button.setImage(UIImage(systemName: "gear"), for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(font: .rounded(ofSize: 22, weight: .semibold), scale: .default),
                                               forImageIn: .normal)

        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
//        button.isHidden = false
        
        button.addTarget(self, action: #selector(changeServerAddress), for: .touchUpInside)
        
        return button
    }()
    

    
    var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>!
    var snapshot: NSDiffableDataSourceSnapshot<Section, AnyHashable>!
    
    var displayedItem = IndexPath(item: 0, section: 0) {
        didSet {
            if displayedItem.section > 0 {
                stateLabel.isHidden = false
                deleteButton.isHidden = false
                updateButton.isHidden = false
                bottomBackground.isHidden = false
                preferencesButton.isHidden = true
            } else {
                stateLabel.isHidden = true
                deleteButton.isHidden = true
                updateButton.isHidden = true
                bottomBackground.isHidden = true
                preferencesButton.isHidden = false
            }
        }
    }
       
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        view.addSubview(backgroundCameraView)
        view.addSubview(backgroundPhotoView)
        view.addSubview(collectionView)
        
        view.addSubview(bottomBackground)
        view.addSubview(deleteButton)
        view.addSubview(updateButton)
        view.addSubview(stateLabel)
        
        view.addSubview(preferencesButton)
        
        configureCollectionView()
        configureDataSource()

    }
    
    func configureDataSource() {
        var photos: [BinPhoto] = BinPhotoProvider.shared.fetchObjects()!
        photos.sort { $0.date! > $1.date! }
        
        snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        
        snapshot.deleteAllItems()
        snapshot.appendSections(Section.allCases)
        
        snapshot.appendItems([CameraViewController(withDelegate: self)], toSection: Section.camera)
        snapshot.appendItems(photos, toSection: Section.photo)
        
        collectionView.dataSource = dataSource
        dataSource.apply(snapshot)
    }

    
    func updateDataSource() {
        var photos: [BinPhoto] = BinPhotoProvider.shared.fetchObjects()!
        photos.sort { $0.date! > $1.date! }
    
        snapshot.deleteSections([Section.photo])
        snapshot.appendSections([Section.photo])
        
//        snapshot.appendItems([CameraViewController(withBackgroundView: backgroundCameraView)], toSection: Section.camera)
        snapshot.appendItems(photos, toSection: Section.photo)
        
        collectionView.dataSource = dataSource
        dataSource.apply(snapshot)
    }
    
    func updateView() {
        collectionView.reloadData()
        updateBottomLabel()
    }
    
    func updateViewBackground() {
        let binPhoto = dataSource.itemIdentifier(for: displayedItem) as! BinPhoto
        let image = UIImage(data: binPhoto.data!)
        let layer = CALayer()
        layer.contents = image?.cgImage
        layer.transform = CATransform3DMakeRotation( .pi / 2, 0, 0, 1)
        backgroundPhotoView.setLayer(layer, withAnimation: true)
        
    }
    
    func updateBottomLabel() {
        guard let currentPhoto = dataSource.itemIdentifier(for: displayedItem) as? BinPhoto else {
            return
        }
        
        if !currentPhoto.is_checked {
            stateLabel.text = "Fail send photo"
            stateLabel.textColor = #colorLiteral(red: 1, green: 0.4932563305, blue: 0.4739957452, alpha: 1)
        } else if currentPhoto.bins?.count == 0 {
            stateLabel.text = "Theare no trash bins"
            stateLabel.textColor = .white
        } else {
            stateLabel.text = "Found \(currentPhoto.bins?.count ?? 0) bins"
            stateLabel.textColor = .white
        }
    }
    

    
    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "photoCell")
        
        
        dataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>(
            collectionView: collectionView,
            cellProvider: { [weak self] (collectionView, indexPath, model) -> UICollectionViewCell? in
               
                guard let self, let section = Section(rawValue: indexPath.section)
                    else { return .init() }
                
                switch section {
                case .camera:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? UICollectionViewCell
                    let view = model as! CameraViewController

                    cell?.addSubview(view.view)

                    return cell
                    
                case .photo:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCollectionViewCell
                    let model = model as! BinPhoto
 
                    cell?.configureWith(image: .init(data: model.data!)!, bins: model.bins)

                    
                    return cell
                    
                }
                
            }
        )
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = .init(x: 0,
                                     y: 0,
                                     width: view.frame.width,
                                     height: view.frame.height)
        
        backgroundPhotoView.frame = collectionView.frame
        backgroundCameraView.frame = collectionView.frame
        
        NSLayoutConstraint.activate([
            bottomBackground.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            bottomBackground.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            bottomBackground.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBackground.heightAnchor.constraint(equalToConstant: 52),
            
            preferencesButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            preferencesButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            preferencesButton.heightAnchor.constraint(equalToConstant: 44),
            preferencesButton.widthAnchor.constraint(equalToConstant: 44),
            
            
            stateLabel.leadingAnchor.constraint(equalTo: bottomBackground.leadingAnchor, constant: 19),
            stateLabel.centerYAnchor.constraint(equalTo: bottomBackground.centerYAnchor),
            stateLabel.trailingAnchor.constraint(lessThanOrEqualTo: bottomBackground.trailingAnchor, constant: -19),
            
            deleteButton.trailingAnchor.constraint(equalTo: bottomBackground.trailingAnchor, constant: -16),
            deleteButton.centerYAnchor.constraint(equalTo: bottomBackground.centerYAnchor),
            
            updateButton.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -16),
            updateButton.centerYAnchor.constraint(equalTo: bottomBackground.centerYAnchor)
            
        ])
    }
    
    @objc
    private func deleteCurrentPhoto() {
        guard let currentPhoto = dataSource.itemIdentifier(for: displayedItem) as? BinPhoto else {
            return
        }
        BinPhotoProvider.shared.deleteObject(currentPhoto)
        updateDataSource()
    }
    
    @objc
    private func updateCurrentPhoto() {
        guard let currentPhoto = dataSource.itemIdentifier(for: displayedItem) as? BinPhoto else {
            return
        }
        
        QueryManager.shared.classifyBin(in: currentPhoto) { result in
            switch result {
            case .success(let bins):
                currentPhoto.bins = NSSet(array: bins)
                currentPhoto.is_checked = true
                
                bins.forEach {
                    $0.binPhoto = currentPhoto
                    $0.id_bin_photo = currentPhoto.id
                }
                
            case .failure(_):
                currentPhoto.is_checked = false
            }
            
            DispatchQueue.main.async {
                BinPhotoProvider.shared.saveContext()
//                self.needUpdate()
                self.updateView()
            }
            
        }
    }
    
    @objc
    private func changeServerAddress() {
        let alertController = UIAlertController(title: "Input IP-address", message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if let txtField = alertController.textFields?.first, let text = txtField.text {
                guard let url = URL(string: "http://" + text) else {
                    self.changeServerAddress()
                    return
                }
                QueryManager.baseUrl = url
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
            textField.placeholder = "0.0.0.0"
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
        
}


extension ViewController: UICollectionViewDelegateFlowLayout {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y <= 0) { scrollView.bounces = false }
        else { scrollView.bounces = true }
        
        let contentOffset = CGPoint(x: collectionView.contentOffset.x,
                                    y: collectionView.contentOffset.y + collectionView.frame.height / 2)
        
        let currentItem = collectionView.indexPathForItem(at: contentOffset) ?? displayedItem
        
        
        if (displayedItem != currentItem) {
            displayedItem = currentItem
            print(displayedItem)
            
            updateBottomLabel()
            
            switch dataSource.sectionIdentifier(for: displayedItem.section)! {
            case .camera:
                break
                
            case .photo:
                updateViewBackground()
            }
        }
        
        if (displayedItem.item == 0) {
            let alpha = CGFloat(collectionView.contentOffset.y / scrollView.frame.height)
            backgroundPhotoView.alpha = alpha
        }
    }
    
}


extension ViewController: ViewControllerDelegateProtocol {
    func getCameraBackgroundView() -> BackgroundView {
        backgroundCameraView
    }
    
    func needUpdate() {
        updateDataSource()
    }
}
