//
//  FilmRoll.swift
//  Parallax
//
//  Created by 王亮 on 2019/10/24.
//  Copyright © 2019 王亮. All rights reserved.
//

import UIKit

class FilmRollViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
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

extension FilmRollViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FILTERS.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilmRollCell", for: indexPath) as! FilmRollCell
        cell.updateCell(index: indexPath.item, onBack: self.onBack)
        return cell
    }
    
    
}
