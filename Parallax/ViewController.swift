//
//  ViewController.swift
//  Parallax
//
//  Created by 王亮 on 2019/10/22.
//  Copyright © 2019 王亮. All rights reserved.
//

import UIKit
import EVGPUImage2

class ViewController: UIViewController {
    var videoCamera: Camera?
    @IBOutlet weak var viewport: RenderView!
    
    required init(coder aDecoder: NSCoder)
    {
        do {
            videoCamera = try Camera(sessionPreset:.hd4K3840x2160, location:.backFacing)
            videoCamera!.runBenchmark = true
        } catch {
            videoCamera = nil
            print("Couldn't initialize camera with error: \(error)")
        }

        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("###")
        do {
            viewport.fillMode = .preserveAspectRatioAndFill
            videoCamera = try Camera(sessionPreset: .hd4K3840x2160, location: .backFacing)
            let filter = FalseColor()
            videoCamera?.addTarget(filter)
            filter.addTarget(viewport)
            videoCamera?.startCapture()
        } catch {
            print("Initialize camera with error: \(error)")
        }
    }


}

