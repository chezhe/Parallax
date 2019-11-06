//
//  CustomOverlayView.swift
//  Parallax
//
//  Created by 王亮 on 2019/10/27.
//  Copyright © 2019 王亮. All rights reserved.
//

import UIKit
import INSNibLoading
import INSPhotoGallery
import SPAlert

class CustomOverlayView: INSNibLoadedView {
    weak var photosViewController: INSPhotosViewController?
    var delete: (_ photos: [PhotoModel]) -> Void = {photos in }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Pass the touches down to other views
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let hitView = super.hitTest(point, with: event) , hitView != self {
            return hitView
        }
        return nil
    }
    
    func setDeleteFunc(delete: @escaping (_ photos: [PhotoModel]) -> Void) -> Void {
        self.delete = delete
    }
    
    @IBAction func closeButtonTapped(_ sender: AnyObject) {
        photosViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func onShare(_ sender: Any) {
        let currentPhoto = photosViewController?.currentPhoto as! PhotoModel
        
        currentPhoto.loadImageWithCompletionHandler({ [weak self] (image, error) -> () in
            if let image = (image ?? currentPhoto.thumbnailImage) {
                let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                activityController.popoverPresentationController?.barButtonItem = (sender as! UIBarButtonItem)
                self?.photosViewController?.present(activityController, animated: true, completion: nil)
            }
        });
    }
    
    @IBAction func onDownload(_ sender: Any) {
        let saved = NSLocalizedString("Saved :)", comment: "")
        SPAlert.present(message: saved)
        let photo = photosViewController?.currentPhoto as! PhotoModel
        FileUtil.saveToPhotoLibrary(url: photo.url)
    }
    
    @IBAction func onDelete(_ sender: Any) {
        let deleted = NSLocalizedString("Deleted :)", comment: "")
        SPAlert.present(message: deleted)
        let currentPhoto = photosViewController?.currentPhoto as! PhotoModel
        photosViewController?.handleDeleteButtonTapped()
        delete([currentPhoto])
        photosViewController?.dismiss(animated: true, completion: nil)
    }
}


extension CustomOverlayView: INSPhotosOverlayViewable {
    func populateWithPhoto(_ photo: INSPhotoViewable) {
        
    }
    
    func setHidden(_ hidden: Bool, animated: Bool) {
        if self.isHidden == hidden {
            return
        }
        
        if animated {
            self.isHidden = false
            self.alpha = hidden ? 1.0 : 0.0
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.allowAnimatedContent, .allowUserInteraction], animations: { () -> Void in
                self.alpha = hidden ? 0.0 : 1.0
                }, completion: { result in
                    self.alpha = 1.0
                    self.isHidden = hidden
            })
        } else {
            self.isHidden = hidden
        }
    }
}

