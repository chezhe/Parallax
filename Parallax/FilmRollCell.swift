//
//  FilmRollCard.swift
//  Parallax
//
//  Created by 王亮 on 2019/10/27.
//  Copyright © 2019 王亮. All rights reserved.
//

import UIKit

class FilmRollCell: UICollectionViewCell {
    @IBOutlet weak var filterName: UILabel!
    
    @IBOutlet weak var useBtn: UIButton!
    
    @IBOutlet weak var effectImage: UIImageView!
    
    var index: Int?
    var onBack: (_ sender: Any) -> Void = {sender in }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func updateCell(index: Int, onBack: @escaping (_ sender: Any) -> Void) -> Void {
        self.index = index
        self.onBack = onBack
        
        let filter = FILTERS[index]
        
        filterName.text = NSLocalizedString(filter.name, comment: "")
        
        let apply = NSLocalizedString("Apply", comment: "")
        let applying = NSLocalizedString("Applying", comment: "")
        
        let image = UIImage(cgImage: getCGImage(name: filter.name, ext: "jpg"), scale: 8, orientation: UIImage.Orientation.up)
        effectImage.image = image
        effectImage.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        
        useBtn.layer.cornerRadius = 15
        useBtn.contentEdgeInsets = UIEdgeInsets(top: 0,left: 15,bottom: 0,right: 15)
        useBtn.bounds.size = CGSize(width: 80, height: 30)
        
        let filterName = UserDefaults.standard.string(forKey: "filterName") ?? "schindlers-list"
        if filterName == filter.name {
            useBtn.setTitle(applying, for: .normal)
            useBtn.layer.backgroundColor = UIColor.orange.cgColor
            useBtn.layer.borderColor = UIColor.orange.cgColor
            useBtn.setTitleColor(UIColor.darkGray, for: .normal)
        } else {
            if filter.locked() {
                useBtn.setTitle("￥" + String(filter.price), for: .normal)
            } else {
                useBtn.setTitle(apply, for: .normal)
            }
            
            useBtn.layer.backgroundColor = UIColor.darkGray.cgColor
            useBtn.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    @IBAction func onUsed(_ sender: Any) {
        let filter = FILTERS[index!]
        UserDefaults.standard.set(filter.name, forKey: "filterName")
        
        let applying = NSLocalizedString("Applying", comment: "")
        useBtn.setTitle(applying, for: .normal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.onBack(sender)
        }
    }
}

