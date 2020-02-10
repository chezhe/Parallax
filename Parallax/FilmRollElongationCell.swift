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

    @IBOutlet weak var priceButton: UIButton!
    @IBOutlet var topImageViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBAction func onClick(_ sender: Any) {
        fetchProductInformation(id: priceButton.accessibilityIdentifier!)
    }
    
    // MARK: - Fetch Product Information

    /// Retrieves product information from the App Store.
    fileprivate func fetchProductInformation(id: String) {
        if StoreObserver.shared.isAuthorizedForPayments {
            let identifiers = [id]
            StoreManager.shared.startProductRequest(with: identifiers)
        } else {
            
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        print("+")
    }
}

