//
//  PhotoCollectionViewCell.swift
//  Summer-practice
//
//  Created by work on 05.06.2023.
//

import Foundation
import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    private lazy var imageView: UIImageView = {
        var view = UIImageView(image: image)
        view.clipsToBounds = true
        view.layer.cornerRadius = 60
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private var image: UIImage!
    
    private lazy var bottomBackground: UIVisualEffectView = {
        var view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        view.clipsToBounds = true
        view.layer.cornerRadius = 26
        view.translatesAutoresizingMaskIntoConstraints = false
 
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(imageView)
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
                      
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 130),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
            
        ])
    }
    
    func configureWith(image: UIImage, bins: NSSet?) {
        self.image = image
        imageView.image = image
        
        imageView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        guard let bins = bins else {
            return
        }
        
        bins.allObjects.forEach {
            let bin = $0 as! Bin
            let x = CGFloat(Int(bin.x1)) / image.size.width * contentView.frame.width
            let y = CGFloat(Int(bin.y1)) / image.size.height * contentView.frame.width
            let width = (CGFloat(Int(bin.x2)) / image.size.width * contentView.frame.width - x)
            let height = (CGFloat(Int(bin.y2)) / image.size.height * contentView.frame.width - y)
            
            
            let rectView = UIView(frame: .init(x: x,
                                               y: y,
                                               width: width,
                                               height: height))
            rectView.backgroundColor = .clear
            rectView.layer.cornerRadius = 10
            rectView.layer.borderWidth = 6
            
            switch bin.class_name! {
            case "full":
                rectView.layer.borderColor = UIColor.red.withAlphaComponent(0.75).cgColor
            case "halfempty":
                rectView.layer.borderColor = UIColor.yellow.withAlphaComponent(0.75).cgColor
            case "empty":
                rectView.layer.borderColor = UIColor.green.withAlphaComponent(0.75).cgColor
            case "undefined":
                rectView.layer.borderColor = UIColor.black.withAlphaComponent(0.75).cgColor
            default:
                break
            }
            
            imageView.addSubview(rectView)
        }
    }
    
    
}
