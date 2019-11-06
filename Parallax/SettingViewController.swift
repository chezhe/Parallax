//
//  SettingViewController.swift
//  Parallax
//
//  Created by 王亮 on 2019/10/26.
//  Copyright © 2019 王亮. All rights reserved.
//


import UIKit

class SettingViewController: UIViewController {
    
    @IBOutlet weak var saveLocalBtnOn: UIButton!
    
    @IBOutlet weak var saveLocalBtnOff: UIButton!
    
    @IBOutlet weak var savePhotoLocalLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        let onTitle = NSLocalizedString("On", comment: "")
        let offTitle = NSLocalizedString("Off", comment: "")
        let saveLocalTitle = NSLocalizedString("Save photo local directly", comment: "")
        
        saveLocalBtnOn.setTitle(onTitle, for: .normal)
        saveLocalBtnOff.setTitle(offTitle, for: .normal)
        savePhotoLocalLabel.text = saveLocalTitle
        
        let autoSaveLocal = UserDefaults.standard.string(forKey: "autoSaveLocal") == "true" ? true : false
        if autoSaveLocal {
            saveLocalBtnOn.setTitleColor(.orange, for: .normal)
            saveLocalBtnOff.setTitleColor(.gray, for: .normal)
        } else {
            saveLocalBtnOn.setTitleColor(.gray, for: .normal)
            saveLocalBtnOff.setTitleColor(.orange, for: .normal)
        }
    }
    
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func turnSaveLocalOn(_ sender: Any) {
        UserDefaults.standard.set("true", forKey: "autoSaveLocal")
        saveLocalBtnOn.setTitleColor(.orange, for: .normal)
        saveLocalBtnOff.setTitleColor(.gray, for: .normal)
    }
 
    
    @IBAction func turnSaveLocalOff(_ sender: Any) {
        UserDefaults.standard.set("false", forKey: "autoSaveLocal")
        saveLocalBtnOn.setTitleColor(.gray, for: .normal)
        saveLocalBtnOff.setTitleColor(.orange, for: .normal)
    }
}
