//
//  PhotoCollectionViewController.swift
//  Summer-practice
//
//  Created by work on 11.09.2023.
//

import UIKit

class PhotoCollectionViewController: UIViewController, UICollectionViewDelegate {
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
        view.alpha = 1

        return view
    }()

    private lazy var stateView: BottomStateView = {
        let view = BottomStateView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false

        view.configure(onTapDeleteButton: deleteCurrentPhoto, onTapUpdateButton: updateCurrentPhoto)

        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        view.addSubview(backgroundPhotoView)
        view.addSubview(collectionView)

        view.addSubview(stateView)

        configureCollectionView()
        configureDataSource()

        model.subscribe { [weak self] in
            self?.updateDataAndViews()
        }

    }

    private var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>!
    private var snapshot: NSDiffableDataSourceSnapshot<Section, AnyHashable>!
    private let model: BinPhotoManager

    private var displayedItem = IndexPath(item: 0, section: 0)

    init(with model: BinPhotoManager) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureDataSource() {
        var photos: [BinPhoto] = model.getPhotos()
        photos.sort { $0.date! > $1.date! }

        snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()

        snapshot.deleteAllItems()
        snapshot.appendSections([Section.photo])

        snapshot.appendItems(photos, toSection: Section.photo)

        collectionView.dataSource = dataSource
        dataSource.apply(snapshot)
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
//        collectionView.reloadData()
        updateDataSource()
        updateViewBackground()
    }

    func updateViewBackground() {
        let binPhoto = dataSource.itemIdentifier(for: displayedItem) as! BinPhoto
        let image = UIImage(data: binPhoto.data!)
        let layer = CALayer()
        layer.contents = image?.cgImage
        layer.transform = CATransform3DMakeRotation( .pi / 2, 0, 0, 1)
        backgroundPhotoView.setLayer(layer, withAnimation: true)

    }

    func updateStateView() {
        guard let currentPhoto = dataSource.itemIdentifier(for: displayedItem) as? BinPhoto else {
            return
        }

        if !currentPhoto.is_checked {
            stateView.state = .fail
        } else if currentPhoto.bins?.count == 0 {
            stateView.state = .noFound
        } else {
            stateView.state = .found(currentPhoto.bins?.count ?? 0)
        }
    }

    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "photoCell")

        dataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, model) -> UICollectionViewCell? in

                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCollectionViewCell
                let model = model as! BinPhoto

                cell?.configureWith(image: .init(data: model.data!)!, bins: model.bins)

                return cell
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

        NSLayoutConstraint.activate([
            stateView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stateView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stateView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stateView.heightAnchor.constraint(equalToConstant: 52)

        ])
    }

    private lazy var deleteCurrentPhoto = { [weak self] in
        guard let currentPhoto = self?.dataSource.itemIdentifier(for: self!.displayedItem) as? BinPhoto else {
            return
        }
        self?.model.removePhoto(currentPhoto)
        self?.updateDataSource()
    }

    private lazy var updateCurrentPhoto = { [weak self] in
        guard let currentPhoto = self?.dataSource.itemIdentifier(for: self!.displayedItem) as? BinPhoto else {
            return
        }
        self?.model.processPhoto(currentPhoto)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y <= 0) { scrollView.bounces = false }
        else { scrollView.bounces = true }

        let contentOffset = CGPoint(x: collectionView.contentOffset.x,
                                    y: collectionView.contentOffset.y + collectionView.frame.height / 2)

        let currentItem = collectionView.indexPathForItem(at: contentOffset) ?? displayedItem


        if (displayedItem != currentItem) {
            displayedItem = currentItem
            print(displayedItem)

            updateStateView()
            updateViewBackground()

        }

        if (displayedItem.item == 0) {
            print(collectionView.contentOffset.y)
            let alpha = CGFloat(collectionView.contentOffset.y / scrollView.frame.height)
//            backgroundPhotoView.alpha = alpha
        }
    }

}

