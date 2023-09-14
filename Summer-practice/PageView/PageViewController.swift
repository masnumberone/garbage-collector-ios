//
//  PageViewController.swift
//  Summer-practice
//
//  Created by work on 11.09.2023.
//

import UIKit

// две страницы в uipageview. вторая стринца содержит коллекцию и стейтВью поверх коллекции

class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    private lazy var cameraVC = {
        var vc = CameraViewController(with: model)

        return vc
    }()

    private lazy var currentPhotoVC = {
        var vc = PhotoViewController(nibName: nil, bundle: nil)
        vc.view.frame = view.bounds

        return vc
    }()

    private lazy var nextPhotoVC = {
        var vc = PhotoViewController(nibName: nil, bundle: nil)
        vc.view.frame = view.bounds

        return vc
    }()

    private lazy var collectionVC = {
        var vc = PhotoCollectionViewController(with: model)
        return vc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setViewControllers([cameraVC], direction: .forward, animated: false)
        view.backgroundColor = .secondarySystemBackground.withAlphaComponent(1)

        for view in view.subviews {
            if let subView = view as? UIScrollView {
                subView.delegate = self
            }
        }



        dataSource = self
        delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    private let model: BinPhotoManager

    init(with model: BinPhotoManager) {
        self.model = model
        super.init(transitionStyle: .scroll, navigationOrientation: .vertical)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var displayedItem = 0
    private lazy var photos = model.getPhotos()

    private func configureNextPhotoVC(with itemIndex: Int) {
        let binPhoto = photos[itemIndex]
        nextPhotoVC.configureWith(image: .init(data: binPhoto.data!)!, bins: binPhoto.bins)
    }

    private func swapPhotoVC() {
        let tmpVC = currentPhotoVC
        currentPhotoVC = nextPhotoVC
        nextPhotoVC = tmpVC

    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        print("viewControllerAfter")
//        if viewController == cameraVC && !photos.isEmpty  {
//            configureNextPhotoVC(with: displayedItem)
//
//            return nextPhotoVC
//        }
//
//        if viewController != cameraVC && displayedItem + 1 < photos.count {
//            configureNextPhotoVC(with: displayedItem + 1)
//
//            return nextPhotoVC
//        }

        print(gestureRecognizers)


        if viewController == cameraVC && !photos.isEmpty  {
            return collectionVC
        }

        return nil
    }


    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        print("viewControllerBefore")

        if viewController == collectionVC {
            return cameraVC
        }

//        if viewController != cameraVC && displayedItem == 0 {
//            return cameraVC
//        }
//
//        if viewController != cameraVC && displayedItem != 0 {
//            configureNextPhotoVC(with: displayedItem - 1)
//
//            return nextPhotoVC
//        }

        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        print("didFinishAnimating")


        if completed && previousViewControllers.contains(cameraVC) {
            currentPage = 1
        }

        if completed && previousViewControllers.contains(collectionVC) {
            currentPage = 0
        }

        print(currentPage)

//        if completed && previousViewControllers.contains(cameraVC) {
//            for view in view.subviews {
//                if let subView = view as? UIScrollView {
//                    subView.isScrollEnabled = false
//                    print("isScrollEnabled = false")
//                }
//            }
//        }


//        print(completed, previousViewControllers)
//
//        if self.viewControllers!.contains(nextPhotoVC) {
//            print("swap")
//            swapPhotoVC()
//        }

//        if (completed && !previousViewControllers.contains(cameraVC)) {
//            swapPhotoVC()
//        }

//        if (completed && previousViewControllers.contains(photoVC)) {
//            displayedVC = cameraVC
//        }
//        if (completed && previousViewControllers.contains(cameraVC)) {
//            displayedVC = photoVC
//        }
    }

    let totalViewControllersInPageController = 2
    var currentPage = 0


}


extension UIPageViewController {
    var bounces: Bool {
        get {
            var bounces: Bool = true
            for view in view.subviews {
                if let subView = view as? UIScrollView {
                    bounces = subView.bounces
                }
            }
            return bounces
        }
        set {
            for view in view.subviews {
                if let subView = view as? UIScrollView {
                    subView.bounces = newValue
                }
            }
        }
    }
}

extension PageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        if (scrollView.contentOffset.y < scrollView.bounds.size.height) {
            print(scrollView.contentOffset)
            scrollView.contentOffset = CGPoint(x: 0, y: scrollView.bounds.size.height)
        }

//        else if (currentPage == totalViewControllersInPageController - 1 && scrollView.contentOffset.y > scrollView.bounds.size.height) {
//            scrollView.contentOffset = CGPoint(x: 0, y: scrollView.bounds.size.height)
//        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        if (currentPage == 0 && scrollView.contentOffset.y <= scrollView.bounds.size.height) {
//            targetContentOffset.pointee = CGPoint(x: 0, y: scrollView.bounds.size.height)
//        } else if (currentPage == totalViewControllersInPageController - 1 && scrollView.contentOffset.y >= scrollView.bounds.size.height) {
//            targetContentOffset.pointee = CGPoint(x: 0, y: scrollView.bounds.size.height)
//        }
    }
}
