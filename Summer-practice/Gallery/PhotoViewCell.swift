//
//  PhotoViewCell.swift
//  Summer-practice
//
//  Created by work on 05.06.2023.
//

import Foundation
import UIKit

class PhotoViewCell: UICollectionViewCell {
    
    private lazy var photoView: PhotoView = {
        PhotoView(frame: bounds)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(photoView)
    }
    
    func configureWith(image: UIImage, bins: NSSet?) {
        photoView.configureWith(image: image, bins: bins)
    }
}
