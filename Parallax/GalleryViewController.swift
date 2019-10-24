//
//  GalleryViewController.swift
//  Parallax
//
//  Created by 王亮 on 2019/10/23.
//  Copyright © 2019 王亮. All rights reserved.
//


import UIKit
import EVGPUImage2
import INSPhotoGallery

class GalleryViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var useCustomOverlay = false
    
    var photos:[INSPhotoViewable] = FileUtil.getPhotoList().map { photo in
        return INSPhoto(image: photo.image, thumbnailImage: photo.image)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        collectionView.delegate = self
//        collectionView.dataSource = self
        
        for photo in photos {
            if let photo = photo as? INSPhoto {
                photo.attributedTitle = NSAttributedString(string: "Example caption text\ncaption text", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            }
        }
    }
    
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.dismiss(animated: true)
    }
    
}

//extension GalleryViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExampleCollectionViewCell", for: indexPath) as! ExampleCollectionViewCell
//        cell.populateWithPhoto(photos[(indexPath as NSIndexPath).row])
//
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return photos.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath) as! ExampleCollectionViewCell
//        let currentPhoto = photos[(indexPath as NSIndexPath).row]
//        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: cell)
//        if useCustomOverlay {
//            galleryPreview.overlayView = CustomOverlayView(frame: CGRect.zero)
//        }
//
//        galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
//            if let index = self?.photos.firstIndex(where: {$0 === photo}) {
//                let indexPath = IndexPath(item: index, section: 0)
//                return collectionView.cellForItem(at: indexPath) as? ExampleCollectionViewCell
//            }
//            return nil
//        }
//        present(galleryPreview, animated: true, completion: nil)
//    }
//}
