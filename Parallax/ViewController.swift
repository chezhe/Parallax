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
    var filter: ImageProcessingOperation = getFilter(name: "schindlers-list")
    var soundEffect: AVAudioPlayer?
    let cameraEnabled: Bool = false
    
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
            photoButton.setImage(lastPhoto, for: UIControl.State.normal)
            photoButton.layer.cornerRadius = 4
            
            if cameraEnabled {
                viewport.fillMode = .preserveAspectRatioAndFill
                videoCamera = try Camera(sessionPreset: .hd4K3840x2160, location: .backFacing)

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
            menu.selectedIndex = 0
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
                FileUtil.storeImageToDocumentDirectory(image: croppedImage, fileName: [name, orient].joined(separator: "~") )
                // if enable save image to photo library directly
    //            if autoSaveLocal {
    //                UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil)
    //            }
            }
            filter --> pictureOutput
        }
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
}


extension ViewController: MenuViewDelegate {
    func menu(_ menu: MenuView, didSelectItemAt index: Int) {
        if index == FILTERS.count {
            let storyBoard = UIStoryboard(name: "Main", bundle:nil)
            let filmroll = storyBoard.instantiateViewController(withIdentifier: "filmroll") as! FilmRollViewController
            self.navigationController?.pushViewController(filmroll, animated:true)
            return
        }
        
        if cameraEnabled {
            let filterItem = FILTERS[index]
            filter.removeAllTargets()
            resetCamera()
            filter = getFilter(name: filterItem.name)
            videoCamera!.addTarget(filter)
            filter.addTarget(viewport!)
            videoCamera!.startCapture()
        }
    }
}

