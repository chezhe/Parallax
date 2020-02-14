//
//  FilterCollectionCell.swift
//  Parallax
//
//  Created by 王亮 on 2020/2/14.
//  Copyright © 2020 王亮. All rights reserved.
//

import Foundation
import UIKit
import CollectionViewSlantedLayout

let yOffsetSpeed: CGFloat = 150.0
let xOffsetSpeed: CGFloat = 100.0

class FilterCollectionCell: CollectionViewSlantedCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    private var gradient = CAGradientLayer()

    override func awakeFromNib() {
        super.awakeFromNib()

        if let backgroundView = backgroundView {
            gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
            gradient.locations = [0.0, 1.0]
            gradient.frame = backgroundView.bounds
            backgroundView.layer.addSublayer(gradient)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let backgroundView = backgroundView {
            gradient.frame = backgroundView.bounds
        }
    }

    var image: UIImage = UIImage() {
        didSet {
            imageView.image = image
        }
    }

    var imageHeight: CGFloat {
        return (imageView?.image?.size.height) ?? 0.0
    }

    var imageWidth: CGFloat {
        return (imageView?.image?.size.width) ?? 0.0
    }

    func offset(_ offset: CGPoint) {
        imageView.frame = imageView.bounds.offsetBy(dx: offset.x, dy: offset.y)
    }

}
