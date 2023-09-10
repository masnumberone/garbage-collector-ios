//
//  PhotoCollectionViewCell.swift
//  Summer-practice
//
//  Created by work on 05.06.2023.
//

import Foundation
import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    private lazy var photoCollectionView: PhotoCollectionView = {
        PhotoCollectionView(frame: bounds)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(photoCollectionView)
    }
    
    func configureWith(image: UIImage, bins: NSSet?) {
        photoCollectionView.configureWith(image: image, bins: bins)
    }
}
