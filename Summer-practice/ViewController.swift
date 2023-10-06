//
//  ViewController.swift
//  Summer-practice
//
//  Created by work on 02.06.2023.
//

import UIKit


class ViewController: UIViewController, UIGestureRecognizerDelegate {
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
        let view = BackgroundView(blurStyle: .systemUltraThinMaterialDark)
        view.configureDarkBlur(withAlpha: 0.7)
        view.alpha = 0
        
        return view
    }()
    
    private let backgroundCameraView: BackgroundView = {
        let view = BackgroundView(blurStyle: .systemThinMaterialDark)
        view.configureDarkBlur(withAlpha: 0.75)

        return view
    }()

    private lazy var stateView: GalleryStateView = {
        let view = GalleryStateView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(onTapDeleteButton: deleteCurrentPhoto, onTapUpdateButton: updateCurrentPhoto)

        return view
    }()

    private lazy var galleryBottomView: GalleryBottomView = {
        let view = GalleryBottomView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configureCameraButton(with: scrollToCamera)

        return view
    }()

    private lazy var titleView: TitleView = {
        let view = TitleView(frame: .zero)
        view.onTapSettingsButton = changeServerAddress
        view.state = .cameraPreview
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private enum Section: Int, CaseIterable {
        case camera
        case photo
    }

    private var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>!
    private var snapshot: NSDiffableDataSourceSnapshot<Section, AnyHashable>!
    private let model: BinPhotoServiceProtocol
    private let networkService: NetworkServiceProtocol
    private var cameraService: CameraServiceProtocol
    private let cameraVC: CameraViewController
    private var galleryBottomViewBottomConstraint: [NSLayoutConstraint]!

    var displayedItem = IndexPath(item: 0, section: 1) {
        didSet {
            if displayedItem.section > 0 {
                titleView.state = .gallery
            } else {
                titleView.state = .cameraPreview
            }

            updateStateView()
            updateBackgroundPhotoView()
        }
    }

    init(with model: BinPhotoServiceProtocol, _ networkService: NetworkServiceProtocol) {
        self.model = model
        self.networkService = networkService
        self.cameraService = AVCameraService()
        self.cameraVC = CameraViewController(with: model, cameraService)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        view.addSubview(backgroundCameraView)
        view.addSubview(backgroundPhotoView)
        view.addSubview(collectionView)
        
        view.addSubview(titleView)
        view.addSubview(stateView)
        view.addSubview(galleryBottomView)

        configureConstraints()
        configureCollectionView()
        configureDataSource()
        configureModel()

        cameraVC.capturePreviewDidAppear = capturePreviewDidAppear
        cameraVC.capturePreviewDidDisappear = capturePreviewDidDisappear
        cameraVC.historyButtonTapped = scrollToGallery
    }

    func configureModel() {
        model.subscribe { [weak self] in
            self?.updateDataAndViews()
        }
    }

    func configureConstraints() {
        galleryBottomViewBottomConstraint = [galleryBottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: view.bounds.height)]

        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 3),
            titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleView.heightAnchor.constraint(equalToConstant: 44),

            stateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stateView.bottomAnchor.constraint(equalTo: galleryBottomView.topAnchor, constant: -19),
            stateView.heightAnchor.constraint(equalToConstant: 52),


            galleryBottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            galleryBottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            galleryBottomView.heightAnchor.constraint(equalToConstant: 52)

        ] + galleryBottomViewBottomConstraint)
    }
    
    func configureDataSource() {
        var photos: [BinPhoto] = model.getPhotos()
        photos.sort { $0.date! > $1.date! }
        
        snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        
        snapshot.deleteAllItems()
        snapshot.appendSections(Section.allCases)
        
        snapshot.appendItems([cameraVC], toSection: Section.camera)
        snapshot.appendItems(photos, toSection: Section.photo)
        
        collectionView.dataSource = dataSource
        dataSource.apply(snapshot)
    }


    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cameraCell")
        collectionView.register(PhotoViewCell.self, forCellWithReuseIdentifier: "photoCell")

        collectionView.delaysContentTouches = false
        collectionView.panGestureRecognizer.delaysTouchesBegan = false
//        collectionView.panGestureRecognizer.cancelsTouchesInView = false

        dataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, model) -> UICollectionViewCell? in

                guard let section = Section(rawValue: indexPath.section) else { return .init() }

                switch section {
                case .camera:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cameraCell", for: indexPath)
                    let cameraVC = model as! CameraViewController
                    cell.addSubview(cameraVC.view)
                    return cell

                case .photo:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoViewCell
                    let model = model as! BinPhoto
                    let imageData = model.data!
                    cell?.configureWith(image: .init(data: imageData)!, bins: model.bins)
                    return cell
                }
            }
        )
    }

    
    func updateDataSource() {
        var photos: [BinPhoto] = model.getPhotos()
        photos.sort { $0.date! > $1.date! }

        snapshot.deleteSections([Section.photo])
        snapshot.appendSections([Section.photo])

        snapshot.appendItems(photos, toSection: Section.photo)
        
        collectionView.dataSource = dataSource
        dataSource.apply(snapshot)
    }
    
    func updateDataAndViews() {
        updateDataSource()
        collectionView.reloadData()
        updateBackgroundPhotoView()
        updateStateView()
    }
    
    func updateBackgroundPhotoView() {
        guard let currentPhoto = dataSource.itemIdentifier(for: displayedItem) as? BinPhoto else { return }
        let image = UIImage(data: currentPhoto.data!) ?? UIImage()
        backgroundPhotoView.setBackgroundImage(image, withAnimation: true)
    }
    
    func updateStateView() {
        guard let currentPhoto = dataSource.itemIdentifier(for: displayedItem) as? BinPhoto else { return }
        if !currentPhoto.is_checked {
            stateView.state = .fail
        } else if currentPhoto.bins?.count == 0 || currentPhoto.bins == nil {
            stateView.state = .noFound
        } else {
            stateView.state = .found(currentPhoto.bins?.count ?? 0)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        collectionView.frame = view.bounds
        backgroundCameraView.frame = view.bounds
        backgroundPhotoView.frame = view.bounds

        let backgroundCameraLayer = cameraService.getLayerForCameraBackground()
        backgroundCameraView.setBackgroundLayer(backgroundCameraLayer, withAnimation: false)
    }

    private lazy var deleteCurrentPhoto = { [weak self] in
        guard let self,
              let currentPhoto = self.dataSource.itemIdentifier(for: self.displayedItem) as? BinPhoto else { return }
        self.model.removePhoto(currentPhoto)
    }

    private lazy var updateCurrentPhoto = { [weak self] in
        guard let self,
              let currentPhoto = self.dataSource.itemIdentifier(for: self.displayedItem) as? BinPhoto else { return }
        self.model.processPhoto(currentPhoto)
    }

    private lazy var changeServerAddress = { [weak self] in
        let alertController = UIAlertController(title: "Input IP-address", message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if let txtField = alertController.textFields?.first, let text = txtField.text {
                guard let url = URL(string: "http://" + text) else {
//                    self.changeServerAddress()
                    return
                }
                self?.networkService.setServerUrl(url)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
            textField.placeholder = "0.0.0.0"
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self?.present(alertController, animated: true, completion: nil)
    }

    private lazy var capturePreviewDidAppear = { [weak self] in
        guard let self else { return }
        self.titleView.state = .capturePreview
        self.collectionView.isScrollEnabled = false
    }

    private lazy var capturePreviewDidDisappear = { [weak self] in
        guard let self else { return }
        self.titleView.state = .cameraPreview
        self.collectionView.isScrollEnabled = true
    }

    private lazy var scrollToGallery = { [weak self] in
        guard let self else { return }
        self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 1), at: .top, animated: true)
    }

    private lazy var scrollToCamera = { [weak self] in
        guard let self else { return }
        self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
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
        }
        
        if (displayedItem.item == 0) {
            let alpha = CGFloat(collectionView.contentOffset.y / scrollView.frame.height)
            backgroundPhotoView.alpha = alpha
        }

        if (scrollView.contentOffset.y < scrollView.bounds.height) {
            let offset = scrollView.bounds.height - scrollView.contentOffset.y

            NSLayoutConstraint.deactivate(galleryBottomViewBottomConstraint)
            galleryBottomViewBottomConstraint = [ galleryBottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: offset - 43) ]
            NSLayoutConstraint.activate(galleryBottomViewBottomConstraint)
        } else {
            NSLayoutConstraint.deactivate(galleryBottomViewBottomConstraint)
            galleryBottomViewBottomConstraint = [ galleryBottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -43) ]
            NSLayoutConstraint.activate(galleryBottomViewBottomConstraint)
        }

    }
    
}
