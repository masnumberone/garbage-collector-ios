//
//  PhotoViewController.swift
//  Summer-practice
//
//  Created by work on 13.09.2023.
//

import UIKit

class PhotoViewController: UIViewController {
    private lazy var photoView: PhotoView = {
        print(view.bounds)
        return PhotoView(frame: view.bounds)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
    }

    private func addSubviews() {
        view.addSubview(photoView)
    }

    func configureWith(image: UIImage, bins: NSSet?) {
        photoView.configureWith(image: image, bins: bins)
    }
}
