//
//  FilmRoll.swift
//  Parallax
//
//  Created by 王亮 on 2019/10/24.
//  Copyright © 2019 王亮. All rights reserved.
//

import UIKit

class FilmRollViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onGoSetting(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let setting = storyBoard.instantiateViewController(withIdentifier: "setting")
        self.navigationController?.pushViewController(setting, animated:true)
    }
    
}
