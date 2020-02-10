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

class GalleryViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var emptyText: UILabel!
    
    var useCustomOverlay = true
    let numberOfItemsPerRow = 4
    var segmentIndex = 0
    
    var photos:[PhotoModel] = []
    var imagePicker = UIImagePickerController()
    
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
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
        self.navigationItem.titleView = segment
        segment.addTarget(self, action: #selector(segmentedControlValueChanged), for:.valueChanged)
        
        let rightSideOptionButton = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "import"), style: .plain, target: self, action: #selector(importPhoto))
        self.navigationItem.rightBarButtonItem = rightSideOptionButton
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        loadPhotos(index: 0)
    }
    
    @objc func segmentedControlValueChanged(segment: UISegmentedControl) {
        segmentIndex = segment.selectedSegmentIndex
        loadPhotos(index: segment.selectedSegmentIndex)
    }
    
    func loadPhotos(index: Int) -> Void {
        let currentFilterName = UserDefaults.standard.string(forKey: "filterName") ?? "schindlers-list"
        if index == 0 {
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
        
        if photos.count > 0 {
            emptyText.isHidden = true
        }
    }
    
    @objc func importPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
           imagePicker.delegate = self
           imagePicker.sourceType = .savedPhotosAlbum
           imagePicker.allowsEditing = false

           present(imagePicker, animated: true, completion: nil)
       }
    }
    
    func onImagePicked(_ controller: UIImagePickerController, didSelect image: UIImage){
        self.dismiss(animated: true, completion: { () -> Void in

        })
        let currentFilterName = UserDefaults.standard.string(forKey: "filterName") ?? "schindlers-list"
        
        let currentFilter = getFilter(name: currentFilterName) as! BasicOperation
        
        let newImage = image.filterWithOperation(currentFilter)
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let name = dateformatter.string(from: Date()) + "_" + currentFilterName + "_"

        FileUtil.storeImageToDocumentDirectory(image: newImage, fileName: name)
        FileUtil.onLaunch()
        loadPhotos(index: segmentIndex)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        self.onImagePicked(picker, didSelect: image)
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

