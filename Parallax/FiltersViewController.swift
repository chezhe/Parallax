//
//  FiltersViewController.swift
//  Parallax
//
//  Created by 王亮 on 2020/2/14.
//  Copyright © 2020 王亮. All rights reserved.
//

import UIKit
import CollectionViewSlantedLayout

class FiltersViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewLayout: CollectionViewSlantedLayout!
    
    internal var covers = [[String: String]]()

    let reuseIdentifier = "customViewCell"

    override func loadView() {
        super.loadView()
        if let url = Bundle.main.url(forResource: "covers", withExtension: "plist"),
            let contents = NSArray(contentsOf: url) as? [[String: String]] {
            covers = contents
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 0.99997437, blue: 0.9999912977, alpha: 1)
        
        let restore = NSLocalizedString("Restore", comment: "")
        let rightSideOptionButton = UIBarButtonItem(title: restore, style: .plain, target: self, action: #selector(restorePurchase))
        self.navigationItem.rightBarButtonItem = rightSideOptionButton
        
//        collectionViewLayout.isFirstCellExcluded = true
//        collectionViewLayout.isLastCellExcluded = true
//        collectionViewLayout.lineSpacing = 0.0
//        collectionViewLayout.slantingSize = 0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }

    @objc func restorePurchase(){
        StoreObserver.shared.restore()
    }
}


extension FiltersViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return covers.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
                            as? FilterCollectionCell else {
            fatalError()
        }
        
        cell.image = UIImage(named: covers[indexPath.row]["picture"]!)!

        if let layout = collectionView.collectionViewLayout as? CollectionViewSlantedLayout {
            cell.contentView.transform = CGAffineTransform(rotationAngle: layout.slantingAngle)
        }

        return cell
    }
}

extension FiltersViewController: CollectionViewDelegateSlantedLayout {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        NSLog("Did select item at indexPath: [\(indexPath.section)][\(indexPath.row)]")
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: CollectionViewSlantedLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGFloat {
        return collectionViewLayout.scrollDirection == .vertical ? 275 : 325
    }
}

extension FiltersViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = collectionView else {return}
        guard let visibleCells = collectionView.visibleCells as? [FilterCollectionCell] else {return}
        for parallaxCell in visibleCells {
            let yOffset = (collectionView.contentOffset.y - parallaxCell.frame.origin.y) / parallaxCell.imageHeight
            let xOffset = (collectionView.contentOffset.x - parallaxCell.frame.origin.x) / parallaxCell.imageWidth
            parallaxCell.offset(CGPoint(x: xOffset * xOffsetSpeed, y: yOffset * yOffsetSpeed))
        }
    }
}
