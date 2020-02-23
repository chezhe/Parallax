//
//  VideoViewController.swift
//  Parallax
//
//  Created by 王亮 on 2020/2/23.
//  Copyright © 2020 王亮. All rights reserved.
//

import UIKit
import VersaPlayer

class VideoViewController: UIViewController {
    
    
    @IBOutlet weak var playerView: VersaPlayerView!
    
    @IBOutlet weak var controls: VersaPlayerControls!
    
    var fileURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 0.99997437, blue: 0.9999912977, alpha: 1)
        
        playerView.layer.backgroundColor = UIColor.black.cgColor
        playerView.use(controls: controls)
        
        if let url = fileURL {
            let item = VersaPlayerItem(url: url)
            playerView.set(item: item)
        }
    }
}
