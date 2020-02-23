//
//  PhotoCell.swift
//  Parallax
//
//  Created by 王亮 on 2019/10/26.
//  Copyright © 2019 王亮. All rights reserved.
//

import UIKit
import INSPhotoGallery
import VersaPlayer

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var playerView: VersaPlayerView!
    var controls: VersaPlayerControls?
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func populateWithPhoto(_ photo: INSPhotoViewable) {
        controls = VersaPlayerControls()
        let playPauseButton = VersaStatefulButton(type: .custom)
        playPauseButton.activeImage = UIImage(named: "play")
        playPauseButton.inactiveImage = UIImage(named: "pause")
        controls?.playPauseButton = playPauseButton
        
        let fullscreenButton = VersaStatefulButton(type: .custom)
        fullscreenButton.activeImage = UIImage(named: "fullscreen")
        controls?.fullscreenButton = fullscreenButton
        
        self.playerView.use(controls: controls!)
        
        controls?.prepare()
    }
}
