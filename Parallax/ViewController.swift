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
    // MARK: - Properties
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
    var movieOutput: MovieOutput? = nil
    var filter: ImageProcessingOperation!
    var soundEffect: AVAudioPlayer?
    var filterName: String?
    var zoomEnd: CGFloat = 1.0
    var currentFilter: Filter?
    var isRecording = false
    var fileURL: URL?
    
    fileprivate var menu: MenuView!
    fileprivate var deviceOrientation: UIDeviceOrientation?
    
    // MARK: - Funtions
    required init(coder aDecoder: NSCoder)
    {
        do {
            videoCamera = try Camera(sessionPreset:.high, location:.backFacing)
            videoCamera!.runBenchmark = true
        } catch {
            videoCamera = nil
            print("Couldn't initialize camera with error: \(error)")
        }

        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deviceOrientation = .portrait
        deviceOrientationHelper.startDeviceOrientationNotifier(with: self.onDeviceRotate)
        
        StoreManager.shared.delegate = self
        StoreObserver.shared.delegate = self
        
        do {
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
            let filmIcon = UIImage(cgImage: getCGImage(name: filterItem!.name + "-filter", ext: "jpg"))
            filmButton.setImage(filmIcon, for: .normal)
            filmButton.bounds.size = CGSize(width: 50, height: 50)
            filmButton.backgroundColor = UIColor.white
            captureButton.tintColor = .white
            photoButton.tintColor = .white
            currentFilter = filterItem
            
            photoButton.bounds.size = CGSize(width: 50, height: 50)
            
            // camera & filter
            videoCamera = try Camera(sessionPreset: .high, location: .backFacing)
            
            filter = getFilter(name: filterName!)
            videoCamera?.addTarget(filter)
            filter.addTarget(viewport)
            videoCamera?.startCapture()

            // sound effect
            soundEffect = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "shoot.mp3", ofType:nil)!))
            
            // filter switch menu
            menu = MenuView()
            menu.delegate = self
            filterSwitcher.addSubview(menu)
            
            menu.items = FILTERS.map { item in
                var item = MenuItem(image: UIImage(cgImage: getCGImage(name: item.name + "-filter", ext: "jpg")))
                item.backgroundColor = UIColor.black
                item.highlightedBackgroundColor = UIColor(white: 1, alpha: 0.3)
                item.shadowColor = UIColor(white: 1, alpha: 0.3)
                return item
            }
            var shopItem = MenuItem(image: UIImage(named: "shop")!)
            shopItem.backgroundColor = UIColor(displayP3Red: 17.0/255, green: 18.0/255, blue: 19.0/255, alpha: 1.0)
            shopItem.shadowColor = UIColor(displayP3Red: 17.0/255, green: 18.0/255, blue: 19.0/255, alpha: 1.0)
            menu.items.append(shopItem)
            menu.selectedIndex = getIndexOf(filterName: filterName!)
            menu.backgroundColor = UIColor(displayP3Red: 17.0/255, green: 18.0/255, blue: 19.0/255, alpha: 1.0)
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
        if !isRecording {
            do {
                isRecording = true
                captureButton.setImage(UIImage(named: "stop"), for: .normal)
                
                let currentFilterName = UserDefaults.standard.string(forKey: "filterName") ?? "schindlers-list"
                
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "yyyy-MM-dd+hh:mm:ss"
                let name = dateformatter.string(from: Date()) + "_" + currentFilterName + "_.mp4"
                
                let documentsDir = try FileManager.default.url(for:.documentDirectory, in:.userDomainMask, appropriateFor:nil, create:true)
                fileURL = URL(string: name, relativeTo: documentsDir)!
                do {
                    try FileManager.default.removeItem(at: fileURL!)
                } catch {
                }
                let viewportSize = viewport.bounds.size
                movieOutput = try MovieOutput(URL: fileURL!, size: Size(width: Float(viewportSize.width), height: Float(viewportSize.height)), liveVideo:true)
                
    //                camera.audioEncodingTarget = movieOutput
                filter --> movieOutput!
                movieOutput!.startRecording()
            } catch {
                fatalError("Couldn't initialize movie, error: \(error)")
            }
        } else {
            isRecording = false
            movieOutput = nil
            captureButton.setImage(UIImage(named: "record"), for: .normal)
            FileUtil.onLaunch()
            if (fileURL != nil) {
                UISaveVideoAtPathToSavedPhotosAlbum(fileURL!.path, nil, nil, nil)
            }
            fileURL = nil
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
    
    
    func resetCamera() {
        if let videoCamera = videoCamera {
            videoCamera.stopCapture()
            videoCamera.removeAllTargets()
        }
    }
    
    func onDeviceRotate(deviceOrientation: UIDeviceOrientation) -> Void {
        self.deviceOrientation = deviceOrientation
        switch deviceOrientation {
            case .landscapeLeft:
                print("### landscapeLeft")
                videoCamera?.orientation = .landscapeRight
            case .landscapeRight:
                print("### landscapeRight")
                videoCamera?.orientation = .landscapeRight
                break
            case .portrait:
                print("### portrait")
                break
            default: break
                
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let videoCamera = videoCamera {
            videoCamera.stopCapture()
        }
        deviceOrientationHelper.stopDeviceOrientationNotifier()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        deviceOrientationHelper.startDeviceOrientationNotifier(with: self.onDeviceRotate)
        super.viewWillAppear(animated)
        if let videoCamera = videoCamera {
            videoCamera.startCapture()
        }
    }
    
    func switchFilter(name: String) -> Void {
        filterName = name
        menu.selectedIndex = getIndexOf(filterName: name)
        
        filter.removeAllTargets()
        resetCamera()
        
        self.filter = getFilter(name: name)
        self.videoCamera!.addTarget(self.filter)
        self.filter.addTarget(self.viewport!)
        self.videoCamera!.startCapture()
    }
    
    func animateLottie(name: String) {
        let overlay = UIView(frame: self.view.frame)
        overlay.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        self.view.addSubview(overlay)
        overlay.center = self.view.center
        
        let animView = AnimationView(name: "camera-motion")
        let anim = Animation.named(name, bundle: Bundle.main)
        animView.animation = anim
//        animView.backgroundColor = UIColor.trans
        overlay.addSubview(animView)
        animView.frame = CGRect(x: 0, y: 0, width: 375, height: 375)
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
            let filmroll = storyBoard.instantiateViewController(withIdentifier: "filters") as! FiltersViewController
            self.navigationController?.pushViewController(filmroll, animated:true)
            
            let filterName = UserDefaults.standard.string(forKey: "filterName") ?? "schindlers-list"
            menu.selectedIndex = getIndexOf(filterName: filterName)
            return
        }

        let filterItem = FILTERS[index]
        UserDefaults.standard.set(filterItem.name, forKey: "filterName")
        
        self.switchFilter(name: filterItem.name)
        let filmIcon = UIImage(cgImage: getCGImage(name: filterItem.name + "-filter", ext: "jpg"))
        filmButton.setImage(filmIcon, for: .normal)
        currentFilter = filterItem
    }
}


// MARK: - StoreManagerDelegate

/// Extends ParentViewController to conform to StoreManagerDelegate.
extension ViewController: StoreManagerDelegate {
    func storeManagerDidReceiveResponse(_ response: [Section]) {
//        switchToViewController(segment: .products)
        // Switch to the Products view controller.
//        products.reload(with: response)
//        segmentedControl.selectedSegmentIndex = 0
    }

    func storeManagerDidReceiveMessage(_ message: String) {
//        alert(with: Messages.productRequestStatus, message: message)
    }
}

// MARK: - StoreObserverDelegate

/// Extends ParentViewController to conform to StoreObserverDelegate.
extension ViewController: StoreObserverDelegate {
    func storeObserverDidReceiveMessage(_ message: String) {
        //handle purchase result,update UI
//        alert(with: Messages.purchaseStatus, message: message)
        print("### \(message)")
        
    }

    func storeObserverRestoreDidSucceed() {
//        handleRestoredSucceededTransaction()
    }
}
