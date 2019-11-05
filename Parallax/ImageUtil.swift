//
//  ImageUtil.swift
//  Parallax
//
//  Created by 王亮 on 2019/10/23.
//  Copyright © 2019 王亮. All rights reserved.
//

import Foundation
import UIKit

class ImageUtil {
    public static func cropImageToSquare(image: UIImage) -> UIImage {
        let squareWidth = min(image.size.width, image.size.height)
        let size = CGSize(width: squareWidth, height: squareWidth)

        let refWidth : CGFloat = CGFloat(image.cgImage!.width)
        let refHeight : CGFloat = CGFloat(image.cgImage!.height)

        let x = (refWidth - size.width) / 2
        let y = (refHeight - size.height) / 2

        let cropRect = CGRect(x: x, y: y, width: size.height, height: size.width)
        if let imageRef = image.cgImage!.cropping(to: cropRect) {
            return UIImage(cgImage: imageRef, scale: 0, orientation: image.imageOrientation)
        }
        return image
    }
    
    public static func cropScaleSize(image: UIImage, size: CGSize) -> UIImage {
        let originSmallLen = min(image.size.width, image.size.height)
        let newSmallLen = min(size.width, size.height)
        
        let scale: CGFloat = originSmallLen / newSmallLen
        
        var cropRect = CGRect(x: 0, y: 0, width: 0, height: 0)
        if image.size.width < image.size.height {
            let newHeight = scale * size.height
            let y = (image.size.height - newHeight) / 2
            cropRect = CGRect(x: 0, y: y, width: image.size.width, height: newHeight)
        } else {
            let newWidth = scale * size.width
            let x = (image.size.width - newWidth) / 2
            cropRect = CGRect(x: x, y: 0, width: newWidth, height: image.size.height)
        }
        if let imageRef = image.cgImage!.cropping(to: cropRect) {
            return UIImage(cgImage: imageRef, scale: 0, orientation: image.imageOrientation)
        }
        return image
    }
    
    public static func makeRoundedImage(image: UIImage, radius: Float) -> UIImage {
        let imageLayer = CALayer()
        imageLayer.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        imageLayer.contents = image.cgImage

        imageLayer.masksToBounds = true
        imageLayer.cornerRadius = CGFloat(radius)

        UIGraphicsBeginImageContext(image.size)
        imageLayer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return roundedImage!
    }
    
    public static func rotateImage(image: UIImage, orientation: UIImage.Orientation) -> UIImage {
        let cgImage = image.cgImage
        return UIImage(cgImage: cgImage!, scale: 1.0, orientation: orientation)
    }
}

extension UIImage {
    var png: Data? {
        return flattened.pngData()
    }
    var flattened: UIImage {
        if imageOrientation == .up { return self }
        return UIGraphicsImageRenderer(size: size, format: imageRendererFormat).image { _ in draw(at: .zero) }
    }
}
