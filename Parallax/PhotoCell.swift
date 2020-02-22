//
//  PhotoCell.swift
//  Parallax
//
//  Created by 王亮 on 2019/10/26.
//  Copyright © 2019 王亮. All rights reserved.
//

import UIKit
import INSPhotoGallery
import VersaPlayer

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var playerView: VersaPlayerView!
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func populateWithPhoto(_ photo: INSPhotoViewable) {
//        photo.loadThumbnailImageWithCompletionHandler { [weak photo] (image, error) in
//            if let image = image {
//                if let photo = photo as? INSPhoto {
//                    photo.thumbnailImage = image
//                }
//                self.imageView.image = image
//            }
//        }
    }
}
