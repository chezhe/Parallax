//
//  SettingViewController.swift
//  Parallax
//
//  Created by 王亮 on 2019/10/26.
//  Copyright © 2019 王亮. All rights reserved.
//


import UIKit

class SettingViewController: UIViewController {
    
    @IBOutlet weak var saveLocalSwitcher: UISwitch!
    @IBOutlet weak var savePhotoLocalLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 0.99997437, blue: 0.9999912977, alpha: 1)
        
        let saveLocalTitle = NSLocalizedString("Save photo local directly", comment: "")
        savePhotoLocalLabel.text = saveLocalTitle

        let autoSaveLocal = UserDefaults.standard.string(forKey: "autoSaveLocal") == "true" ? true : false
        saveLocalSwitcher.setOn(autoSaveLocal, animated: true)
    }
    
    
    @IBAction func onToggle(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn ? "true" : "false", forKey: "autoSaveLocal")
    }
}
