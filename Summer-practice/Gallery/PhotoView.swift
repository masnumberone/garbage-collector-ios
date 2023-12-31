//
//  PhotoView.swift
//  Summer-practice
//
//  Created by work on 10.09.2023.
//

import UIKit

class PhotoView: UIView {
    private lazy var imageView: UIImageView = {
        var view = UIImageView(image: image)
        view.clipsToBounds = true
        view.layer.cornerRadius = 60
        view.layer.cornerCurve = .continuous
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private var image: UIImage!

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

        guard let bins = bins else { return }
        drawRectFor(bins)
    }

    private func drawRectFor(_ bins: NSSet) {
        bins.allObjects.forEach {
            let bin = $0 as! Bin
            let x = CGFloat(Int(bin.x1)) / image.size.width * frame.width
            let y = CGFloat(Int(bin.y1)) / image.size.height * frame.width
            let width = (CGFloat(Int(bin.x2)) / image.size.width * frame.width - x)
            let height = (CGFloat(Int(bin.y2)) / image.size.height * frame.width - y)


            let rectView = UIView(frame: .init(x: x,
                                               y: y,
                                               width: width,
                                               height: height))
            rectView.backgroundColor = .clear
            rectView.layer.cornerRadius = 10
            rectView.layer.cornerCurve = .continuous
            rectView.layer.borderWidth = 3

            switch bin.class_name! {
            case "full":
                rectView.layer.borderColor = #colorLiteral(red: 0.9201472402, green: 0.3259413242, blue: 0.3237701058, alpha: 1).withAlphaComponent(0.9).cgColor
            case "halfempty":
                rectView.layer.borderColor = #colorLiteral(red: 0.9767822623, green: 0.8522312641, blue: 0.1392843127, alpha: 1).withAlphaComponent(0.9).cgColor
            case "empty":
                rectView.layer.borderColor = #colorLiteral(red: 0.2127317786, green: 0.6835202575, blue: 0.4844830632, alpha: 1).withAlphaComponent(0.9).cgColor
            case "undefined":
                rectView.layer.borderColor = #colorLiteral(red: 0.06899917126, green: 0.2821590006, blue: 0.4185755253, alpha: 1).withAlphaComponent(0.9).cgColor
            default:
                break
            }

            imageView.addSubview(rectView)
        }
    }
}
