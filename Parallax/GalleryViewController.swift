//
//  GalleryViewController.swift
//  Parallax
//
//  Created by 王亮 on 2019/10/23.
//  Copyright © 2019 王亮. All rights reserved.
//


import UIKit
import GPUImage
import INSPhotoGallery

class GalleryViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var emptyText: UILabel!
    
    var useCustomOverlay = true
    let numberOfItemsPerRow = 4
    
    var photos = FileUtil.photoList.map { photo in
        return PhotoModel(image: photo.image, thumbnailImage: ImageUtil.cropScaleSize(image: photo.image, size: CGSize(width: 128, height: 128)), url: photo.url)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 0.99997437, blue: 0.9999912977, alpha: 1)
        
        let rightSideOptionButton = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "setting"), style: .plain, target: self, action: #selector(goSetting))
        self.navigationItem.rightBarButtonItem = rightSideOptionButton
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if photos.count > 0 {
            emptyText.isHidden = true
        }
    }
    
    @objc func goSetting() {
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let setting = storyBoard.instantiateViewController(withIdentifier: "setting")
        self.navigationController?.pushViewController(setting, animated:true)
    }
}

extension GalleryViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        cell.populateWithPhoto(photos[(indexPath as NSIndexPath).row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    private func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
        let size:CGFloat = (collectionView.frame.size.width - space) / 3.0
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        let currentPhoto = photos[(indexPath as NSIndexPath).row]
        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: cell)
        if useCustomOverlay {
            let overlayView = CustomOverlayView(frame: CGRect.zero)
            overlayView.setDeleteFunc(delete: self.delete)
            galleryPreview.overlayView = overlayView
        }
        
        galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
            if let index = self?.photos.firstIndex(where: {$0 === photo}) {
                let indexPath = IndexPath(item: index, section: 0)
                return collectionView.cellForItem(at: indexPath) as? PhotoCell
            }
            return nil
        }
        present(galleryPreview, animated: true, completion: nil)
    }
    
    func delete(photos: [PhotoModel]) -> Void {
        for photo in photos {
            FileUtil.deletePhoto(url: photo.url)
        }
        FileUtil.onLaunch()
        self.photos = FileUtil.photoList.map { photo in
            return PhotoModel(image: photo.image, thumbnailImage: ImageUtil.cropScaleSize(image: photo.image, size: CGSize(width: 128, height: 128)), url: photo.url)
        }
        self.collectionView.reloadData()
    }
}

