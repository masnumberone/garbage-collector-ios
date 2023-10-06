//
//  UIImage+CropToSquare.swift
//  Summer-practice
//
//  Created by work on 15.09.2023.
//

import UIKit

extension UIImage {
    func cropToSquare() -> UIImage {
        let cgImage = cgImage!

        // The shortest side
        let sideLength = min(
            cgImage.width,
            cgImage.height
        )

        // Determines the x,y coordinate of a centered
        // sideLength by sideLength square
        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
        let xOffset = (cgImage.width - sideLength) / 2
        let yOffset = (cgImage.height - sideLength) / 2

        // The cropRect is the rect of the image to keep,
        // in this case centered
        let cropRect = CGRect(x: xOffset,
                              y: yOffset,
                              width: sideLength,
                              height: sideLength
        )

        // Center crop the image
//        let cgImage = image.cgImage!
        let croppedCgImage = cgImage.cropping(to: cropRect)!


        // Use the cropped cgImage to initialize a cropped
        // UIImage with the same image scale and orientation
        let croppedImage = UIImage(
            cgImage: croppedCgImage,
            scale: imageRendererFormat.scale,
            orientation: imageOrientation
        )

        return croppedImage
    }
}
