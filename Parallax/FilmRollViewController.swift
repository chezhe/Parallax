//
//  FilmRoll.swift
//  Parallax
//
//  Created by 王亮 on 2019/10/24.
//  Copyright © 2019 王亮. All rights reserved.
//

import UIKit
import ElongationPreview

class FilmRollViewController: ElongationViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 0.99997437, blue: 0.9999912977, alpha: 1)
        
        let restore = NSLocalizedString("Restore", comment: "")
        let rightSideOptionButton = UIBarButtonItem(title: restore, style: .plain, target: self, action: #selector(restorePurchase))
        self.navigationItem.rightBarButtonItem = rightSideOptionButton
        
        setup()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func openDetailView(for indexPath: IndexPath) {
        let id = String(describing: DetailViewController.self)
        guard let detailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: id) as? DetailViewController else { return }
        let filter = FILTERS[indexPath.row]
        detailViewController.title = NSLocalizedString(filter.name, comment: "")
        expand(viewController: detailViewController)
    }
    
    @objc func restorePurchase(){
        StoreObserver.shared.restore()
    }
}

private extension FilmRollViewController {
    func setup() {
        tableView.backgroundColor = UIColor.black
        tableView.registerNib(FilmRollElongationCell.self)
    }
}

extension FilmRollViewController {

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return FILTERS.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt _: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(FilmRollElongationCell.self)
        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        guard let cell = cell as? FilmRollElongationCell else { return }

        let filter = FILTERS[indexPath.row]

        let attributedLocality = NSMutableAttributedString(string: NSLocalizedString(filter.name, comment: ""), attributes: [
            NSAttributedString.Key.font: UIFont.robotoFont(ofSize: 22, weight: .medium),
            NSAttributedString.Key.kern: 0,
            NSAttributedString.Key.foregroundColor: UIColor.white,
        ])

        cell.topImageView.image = UIImage(cgImage: getCGImage(name: filter.name, ext: "jpg"), scale: 3, orientation: UIImage.Orientation.up)
        cell.localityLabel?.attributedText = attributedLocality
        cell.countryLabel.text = NSLocalizedString(filter.name + "-subtitle", comment: "")
        cell.aboutTitleLabel.text = NSLocalizedString(filter.name + "-subtitle", comment: "")
        cell.aboutDescriptionLabel.text = NSLocalizedString(filter.name + "-desc", comment: "")
        cell.priceButton.accessibilityIdentifier = filter.productID
        if !filter.locked() {
            cell.priceButton.isHidden = true
        } else {
            cell.priceButton.setTitle("￥" + String(filter.price), for: .normal)
        }
    }
    
    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard shouldExpand else { return }
        DispatchQueue.main.async {
            self.expandedIndexPath = indexPath
            self.openDetailView(for: indexPath)
        }
        
        let cell = tableView.cellForRow(at: indexPath) as? FilmRollElongationCell
        cell?.priceButton.isHidden = true
    }
    
    override func animationController(forDismissed _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if expandedIndexPath != nil {
            let filter = FILTERS[expandedIndexPath!.row]
            let cell = tableView.cellForRow(at: expandedIndexPath!) as? FilmRollElongationCell
            cell?.priceButton.isHidden = false

            if !filter.locked() {
                cell?.priceButton.isHidden = true
            } else {
                cell?.priceButton.setTitle("￥" + String(filter.price), for: .normal)
            }
        }
        return super.animationController(forDismissed: self)
    }
}
