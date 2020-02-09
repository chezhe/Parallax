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
    
    var photos:[PhotoModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 0.99997437, blue: 0.9999912977, alpha: 1)
        
        let currentFilterName = UserDefaults.standard.string(forKey: "filterName") ?? "schindlers-list"
        
        let currentFilter = NSLocalizedString(currentFilterName, comment: "")
        let allFilters = NSLocalizedString("All Photos", comment: "")
        
        let segment: UISegmentedControl = UISegmentedControl(items: [currentFilter, allFilters])
        segment.sizeToFit()
        segment.tintColor = UIColor(red:0.99, green:0.00, blue:0.25, alpha:1.00)
        segment.selectedSegmentIndex = 0;
//        segment.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "ProximaNova-Light", size: 15)!], for: .normal)
        self.navigationItem.titleView = segment
        segment.addTarget(self, action: #selector(segmentedControlValueChanged), for:.valueChanged)
        
        let rightSideOptionButton = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "import"), style: .plain, target: self, action: #selector(importPhoto))
        self.navigationItem.rightBarButtonItem = rightSideOptionButton
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        photos = FileUtil.photoList.filter { photo in
            let filterName = photo.url.path.components(separatedBy: "_")
            return filterName[1] == currentFilterName
        }.map { photo in
            return PhotoModel(image: photo.image, thumbnailImage: ImageUtil.cropScaleSize(image: photo.image, size: CGSize(width: 128, height: 128)), url: photo.url)
        }
        
        if photos.count > 0 {
            emptyText.isHidden = true
        }
    }
    
    @objc func segmentedControlValueChanged(segment: UISegmentedControl) {
        print("\(segment.selectedSegmentIndex)")
        let currentFilterName = UserDefaults.standard.string(forKey: "filterName") ?? "schindlers-list"
        if segment.selectedSegmentIndex == 0 {
            photos = FileUtil.photoList.filter { photo in
                let filterName = photo.url.path.components(separatedBy: "_")
                return filterName[1] == currentFilterName
            }.map { photo in
                return PhotoModel(image: photo.image, thumbnailImage: ImageUtil.cropScaleSize(image: photo.image, size: CGSize(width: 128, height: 128)), url: photo.url)
            }
        } else {
            photos = FileUtil.photoList.map { photo in
                return PhotoModel(image: photo.image, thumbnailImage: ImageUtil.cropScaleSize(image: photo.image, size: CGSize(width: 128, height: 128)), url: photo.url)
            }
        }
        collectionView.reloadData()
    }
    
    @objc func importPhoto() {
//        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
//        let setting = storyBoard.instantiateViewController(withIdentifier: "setting")
//        self.navigationController?.pushViewController(setting, animated:true)
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

