//
//  ViewController.swift
//  Parallax
//
//  Created by 王亮 on 2019/10/22.
//  Copyright © 2019 王亮. All rights reserved.
//

import UIKit
import AVFoundation
import Persei
import Lottie
import GPUImage

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var viewport: RenderView!

    @IBOutlet var screenView: UIView!
    
    @IBOutlet weak var filterSwitcher: UIScrollView!
    
    @IBOutlet weak var filmButton: UIButton!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    
    @IBOutlet weak var torchBtn: UIButton!
    @IBOutlet weak var switchBtn: UIButton!
    
    private var deviceOrientationHelper = DeviceOrientationHelper()
    
    var videoCamera: Camera?
    var pictureOutput: PictureOutput!
    var filter: ImageProcessingOperation!
    var soundEffect: AVAudioPlayer?
    let cameraEnabled: Bool = true
    var filterName: String?
    var zoomEnd: CGFloat = 1.0
    
    fileprivate var menu: MenuView!
    fileprivate var deviceOrientation: UIDeviceOrientation?
    
    required init(coder aDecoder: NSCoder)
    {
        if cameraEnabled {
            do {
                videoCamera = try Camera(sessionPreset:.high, location:.backFacing)
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
        
        deviceOrientation = .portrait
        deviceOrientationHelper.startDeviceOrientationNotifier(with: self.onDeviceRotate)
        
        do {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.modalPresentationCapturesStatusBarAppearance = true
            torchBtn.isHidden = true
            switchBtn.isHidden = true
            
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoomFrame(_:)))
            pinchGesture.delegate = self
            viewport.addGestureRecognizer(pinchGesture)
            
            filterName = UserDefaults.standard.string(forKey: "filterName") ?? "schindlers-list"
            
            // button style
            let filterItem = FILTERS.first { item in
                return item.name == filterName
            }
            filmButton.tintColor = .white
            let filmIcon = UIImage(cgImage: getCGImage(name: filterItem!.name + "-filter", ext: "png"))
            filmButton.setImage(filmIcon, for: .normal)
            filmButton.bounds.size = CGSize(width: 50, height: 50)
            filmButton.backgroundColor = UIColor.white
            captureButton.tintColor = .white
            photoButton.tintColor = .white
            
            photoButton.bounds.size = CGSize(width: 50, height: 50)
            
            // camera & filter
            if cameraEnabled {
//                viewport.fillMode = .preserveAspectRatioAndFill
                videoCamera = try Camera(sessionPreset: .hd4K3840x2160, location: .backFacing)

                filter = getFilter(name: filterName!)
                videoCamera?.addTarget(filter)
                filter.addTarget(viewport)
                videoCamera?.startCapture()
            }

            // sound effect
            soundEffect = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "shoot.mp3", ofType:nil)!))
            
            // filter switch menu
            menu = MenuView()
            menu.delegate = self
            filterSwitcher.addSubview(menu)
            
            menu.items = FILTERS.map { item in
                var item = MenuItem(image: UIImage(cgImage: getCGImage(name: item.name + "-filter", ext: "png")))
                item.backgroundColor = UIColor.darkGray
                item.highlightedBackgroundColor = UIColor(white: 1, alpha: 0.3)
                item.shadowColor = UIColor(white: 1, alpha: 0.3)
                return item
            }
            var shopItem = MenuItem(image: UIImage(named: "shop")!)
            shopItem.backgroundColor = UIColor.darkGray
            shopItem.shadowColor = UIColor.darkGray
            menu.items.append(shopItem)
            menu.selectedIndex = getIndexOf(filterName: filterName!)
            menu.backgroundColor = UIColor.darkGray
        } catch {
            print("Initialize camera with error: \(error)")
        }
    }
    
    @objc func zoomFrame(_ gestureRecognizer: UIPinchGestureRecognizer) {
        var zoomScale = gestureRecognizer.scale
        if videoCamera!.inputCamera.videoZoomFactor > 1.0 && zoomScale < 1.0 {
            zoomScale = zoomScale * zoomEnd * 0.8
        }
        zoomScale = max(1.0, zoomScale)
        zoomScale = min(3.0, zoomScale)
        do {
            try videoCamera!.inputCamera.lockForConfiguration()
            if gestureRecognizer.state == .ended {
                if zoomScale <= 1.0 {
                    zoomScale = 1.0
                }
                zoomEnd = zoomScale
            }
            videoCamera!.inputCamera.videoZoomFactor = CGFloat(zoomScale)
            videoCamera!.inputCamera.unlockForConfiguration()
        } catch {
            
        }
    }

    @IBAction func onCapture(_ sender: Any) {
        soundEffect?.play()
        
        if cameraEnabled {
            pictureOutput = PictureOutput()
            pictureOutput.encodedImageFormat = .jpeg
            pictureOutput.imageAvailableCallback = {image in
                self.onCaptureCompleted(image: image)
            }
            filter --> pictureOutput
        }
    }
    
    func onCaptureCompleted(image: UIImage) {
        DispatchQueue.main.async {
            self.animateLottie()
            
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            let name = dateformatter.string(from: Date())

            var newImage = ImageUtil.cropScaleSize(image: image, size: self.viewport.bounds.size)

            switch self.deviceOrientation {
                case .portraitUpsideDown:
                    newImage = UIImage(cgImage: newImage.cgImage!, scale: 1.0, orientation: UIImage.Orientation.down)
                case .landscapeLeft:
                    newImage = UIImage(cgImage: newImage.cgImage!, scale: 1.0, orientation: UIImage.Orientation.right)
                case .landscapeRight:
                    newImage = UIImage(cgImage: newImage.cgImage!, scale: 1.0, orientation: UIImage.Orientation.left)
                default: break
                    
            }

            // if enable save image to photo library directly
            let autoSaveLocal = UserDefaults.standard.string(forKey: "autoSaveLocal") == "true" ? true : false
            if autoSaveLocal {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            } else {
                FileUtil.storeImageToDocumentDirectory(image: newImage, fileName: name)

                FileUtil.onLaunch()
            }
            
            let lastPhoto = ImageUtil.cropScaleSize(image: newImage, size: CGSize(width: 200, height: 200))
            self.photoButton.setImage(lastPhoto, for: .normal)
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
    
    @IBAction func onSwitchCamera(_ sender: Any) {
        resetCamera()
        do {
            let location = videoCamera?.location == .backFacing ? PhysicalCameraLocation.frontFacing : PhysicalCameraLocation.backFacing
            videoCamera = try Camera(sessionPreset: .high, location: location)
            videoCamera!.addTarget(filter)
            videoCamera!.startCapture()
        } catch {
            print("toggle position error: \(error)")
        }
    }
    
    @IBAction func onToggleFlash(_ sender: Any) {
        if cameraEnabled {
            do {
                try videoCamera!.inputCamera.lockForConfiguration()
                if videoCamera?.inputCamera.torchMode == .off {
                    videoCamera?.inputCamera.torchMode = .on
                    torchBtn.setImage(UIImage(imageLiteralResourceName: "flash-off"), for: .normal)
                } else {
                    videoCamera?.inputCamera.torchMode = .off
                    torchBtn.setImage(UIImage(imageLiteralResourceName: "flash-on"), for: .normal)
                }
                videoCamera!.inputCamera.unlockForConfiguration()
            } catch {
                
            }
        }
    }
    
    
    func resetCamera() {
        if let videoCamera = videoCamera {
            videoCamera.stopCapture()
            videoCamera.removeAllTargets()
        }
    }
    
    func onDeviceRotate(deviceOrientation: UIDeviceOrientation) -> Void {
        self.deviceOrientation = deviceOrientation
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let videoCamera = videoCamera {
            videoCamera.stopCapture()
        }
        deviceOrientationHelper.stopDeviceOrientationNotifier()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        deviceOrientationHelper.startDeviceOrientationNotifier(with: self.onDeviceRotate)
        super.viewWillAppear(animated)
        if let videoCamera = videoCamera {
            videoCamera.startCapture()
        }
        
        let lastPhoto = FileUtil.getLastPhoto()
        photoButton.setImage(lastPhoto, for: .normal)
        
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
            
            self.filter = getFilter(name: name)
            self.videoCamera!.addTarget(self.filter)
            self.filter.addTarget(self.viewport!)
            self.videoCamera!.startCapture()
        }
    }
    
    func animateLottie() {
        let overlay = UIView(frame: self.view.frame)
        overlay.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        self.view.addSubview(overlay)
        overlay.center = self.view.center
        
        let animView = AnimationView(name: "camera-motion")
        let anim = Animation.named("loading", bundle: Bundle.main)
        animView.animation = anim
        overlay.addSubview(animView)
        animView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        animView.center = overlay.center
        animView.play { (finished) in
            overlay.removeFromSuperview()
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
        let filmIcon = UIImage(cgImage: getCGImage(name: filterItem.name + "-filter", ext: "png"))
        filmButton.setImage(filmIcon, for: .normal)
    }
}

