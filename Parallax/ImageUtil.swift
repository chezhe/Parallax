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
        let newHeight = scale * size.height
        
        let y = (image.size.height - newHeight) / 2
        let cropRect = CGRect(x: 0, y: y, width: image.size.width, height: newHeight)
        if let imageRef = image.cgImage!.cropping(to: cropRect) {
            return UIImage(cgImage: imageRef, scale: 0, orientation: image.imageOrientation)
        }
        return image
    }
}
