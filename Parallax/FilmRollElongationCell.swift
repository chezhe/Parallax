//
//  ElongationCell.swift
//  Parallax
//
//  Created by 王亮 on 2019/11/29.
//  Copyright © 2019 王亮. All rights reserved.
//

import ElongationPreview
import UIKit

class FilmRollElongationCell: ElongationCell {
    @IBOutlet var topImageView: UIImageView!
    @IBOutlet var localityLabel: UILabel!
    @IBOutlet var countryLabel: UILabel!

    @IBOutlet var aboutTitleLabel: UILabel!
    @IBOutlet var aboutDescriptionLabel: UILabel!

    @IBOutlet var topImageViewTopConstraint: NSLayoutConstraint!
}
