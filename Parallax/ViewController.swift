//
//  ViewController.swift
//  Parallax
//
//  Created by 王亮 on 2019/10/22.
//  Copyright © 2019 王亮. All rights reserved.
//

import UIKit
import EVGPUImage2
import AVFoundation
import Persei

class ViewController: UIViewController {
    
    @IBOutlet weak var viewport: RenderView!

    @IBOutlet var screenView: UIView!
    
    @IBOutlet weak var filterSwitcher: UIScrollView!
    
    @IBOutlet weak var filmButton: UIButton!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    
    var videoCamera: Camera?
    var pictureOutput: PictureOutput!
    var filter: ImageProcessingOperation!
    var soundEffect: AVAudioPlayer?
    let cameraEnabled: Bool = true
    var filterName: String?
    
    fileprivate var menu: MenuView!
    
    required init(coder aDecoder: NSCoder)
    {
        if cameraEnabled {
            do {
                videoCamera = try Camera(sessionPreset:.hd4K3840x2160, location:.backFacing)
                videoCamera!.runBenchmark = true
            } catch {
                videoCamera = nil
                print("Couldn't initialize camera with error: \(error)")
            }
        }

        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            filmButton.tintColor = .white
            captureButton.tintColor = .white
            photoButton.tintColor = .white
            let lastPhoto = ImageUtil.cropScaleSize(image: FileUtil.getLastPhoto(), size: CGSize(width: 200, height: 200))
            photoButton.setImage(lastPhoto, for: .normal)
            
            filterName = UserDefaults.standard.string(forKey: "filterName") ?? "schindlers-list"
            
            if cameraEnabled {
                viewport.fillMode = .preserveAspectRatioAndFill
                videoCamera = try Camera(sessionPreset: .hd4K3840x2160, location: .backFacing)

                filter = getFilter(name: filterName!)
                videoCamera?.addTarget(filter)
                filter.addTarget(viewport)
                videoCamera?.startCapture()
//                soundEffect = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "shoot.mp3", ofType:nil)!))
            }
            
            menu = MenuView()
            menu.delegate = self
            filterSwitcher.addSubview(menu)
            
            menu.items = FILTERS.map { item in
                return MenuItem(image: UIImage(cgImage: getCGImage(name: item.name, ext: "jpg")))
            }
            menu.items.append(MenuItem(image: UIImage(named: "shop")!))
            menu.selectedIndex = getIndexOf(filterName: filterName!)
        } catch {
            print("Initialize camera with error: \(error)")
        }
    }


    @IBAction func onCapture(_ sender: Any) {
//        soundEffect?.play()
        
        if cameraEnabled {
            pictureOutput = PictureOutput()
            pictureOutput.encodedImageFormat = .png
            pictureOutput.imageAvailableCallback = {image in
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
                let name = dateformatter.string(from: Date())

                let isPortrait = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isPortrait ?? false

                let orient = isPortrait ? "portrait" : "landscape"

                let croppedImage = ImageUtil.cropScaleSize(image: image, size: self.viewport.bounds.size)
                FileUtil.storeImageToDocumentDirectory(image: croppedImage, fileName: [name, orient].joined(separator: "~"))
                
                self.onCaptureCompleted(image: croppedImage)
            }
            filter --> pictureOutput
        }
    }
    
    func onCaptureCompleted(image: UIImage) {
        DispatchQueue.main.async {
            let lastPhoto = ImageUtil.cropScaleSize(image: image, size: CGSize(width: 200, height: 200))
            self.photoButton.setImage(lastPhoto, for: .normal)
        }

        // if enable save image to photo library directly
        let autoSaveLocal = UserDefaults.standard.string(forKey: "autoSaveLocal") == "true" ? true : false
        if autoSaveLocal {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        
        FileUtil.onLaunch()
    }
    
    @IBAction func onSwitchFilter(_ sender: Any) {
        menu.setRevealed(!menu.revealed, animated: true)
    }
    
    @IBAction func onGoGallery(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let gallery = storyBoard.instantiateViewController(withIdentifier: "gallery")
        self.navigationController?.pushViewController(gallery, animated:true)
    }
    
    func resetCamera() {
        if let videoCamera = videoCamera {
            videoCamera.stopCapture()
            videoCamera.removeAllTargets()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let videoCamera = videoCamera {
            videoCamera.stopCapture()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let videoCamera = videoCamera {
            videoCamera.startCapture()
        }
        
        let newFilterName = UserDefaults.standard.string(forKey: "filterName") ?? "schindlers-list"
        if newFilterName != filterName {
            switchFilter(name: newFilterName)
        }
    }
    
    func switchFilter(name: String) -> Void {
        filterName = name
        menu.selectedIndex = getIndexOf(filterName: name)
        
        if cameraEnabled {
            filter.removeAllTargets()
            resetCamera()
            filter = getFilter(name: name)
            videoCamera!.addTarget(filter)
            filter.addTarget(viewport!)
            videoCamera!.startCapture()
        }
    }
}


extension ViewController: MenuViewDelegate {
    func menu(_ menu: MenuView, didSelectItemAt index: Int) {
        if index == FILTERS.count {
            let storyBoard = UIStoryboard(name: "Main", bundle:nil)
            let filmroll = storyBoard.instantiateViewController(withIdentifier: "filmroll") as! FilmRollViewController
            self.navigationController?.pushViewController(filmroll, animated:true)
            
            let filterName = UserDefaults.standard.string(forKey: "filterName") ?? "schindlers-list"
            menu.selectedIndex = getIndexOf(filterName: filterName)
            return
        }

        let filterItem = FILTERS[index]
        UserDefaults.standard.set(filterItem.name, forKey: "filterName")
        
        self.switchFilter(name: filterItem.name)
    }
}

