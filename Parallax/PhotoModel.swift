//
//  PhotoModel.swift
//  Parallax
//
//  Created by 王亮 on 2019/10/27.
//  Copyright © 2019 王亮. All rights reserved.
//

import UIKit
import INSPhotoGallery

class PhotoModel: NSObject, INSPhotoViewable {
    var image: UIImage?
    var thumbnailImage: UIImage?
    var attributedTitle: NSAttributedString?
    var url: URL
    
    init(image: UIImage?, thumbnailImage: UIImage?, url: URL) {
        self.image = image
        self.thumbnailImage = thumbnailImage
        self.url = url
    }
    
    func loadImageWithCompletionHandler(_ completion: @escaping (UIImage?, Error?) -> ()) {
        completion(image, nil)
    }
    
    func loadThumbnailImageWithCompletionHandler(_ completion: @escaping (UIImage?, Error?) -> ()) {
        completion(thumbnailImage, nil)
    }
}
