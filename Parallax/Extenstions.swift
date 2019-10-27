//
//  Extenstions.swift
//  Parallax
//
//  Created by 王亮 on 2019/10/26.
//  Copyright © 2019 王亮. All rights reserved.
//

import UIKit

// MARK: tableview

extension UITableView {
    func getReusableCellWithIdentifier<T: UITableViewCell>(indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withIdentifier: T.cellIdentifier, for: indexPath as IndexPath) as? T else {
            fatalError("Couldn't instantiate view controller with identifier \(T.cellIdentifier) ")
        }

        return cell
    }
}

// MARK: UITableViewCell

protocol TableViewCellIdentifiable {
    static var cellIdentifier: String { get }
}

extension TableViewCellIdentifiable where Self: UITableViewCell {
    static var cellIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: TableViewCellIdentifiable {}

// MARK: storyboard

extension UIStoryboard {

    enum Storyboard: String {
        case Main
    }

    convenience init(storyboard: Storyboard, bundle: Bundle? = nil) {
        self.init(name: storyboard.rawValue, bundle: bundle)
    }

    class func storyboard(storyboard: Storyboard, bundle: Bundle? = nil) -> UIStoryboard {
        return UIStoryboard(name: storyboard.rawValue, bundle: bundle)
    }

    func instantiateViewController<T: UIViewController>() -> T {
        guard let viewController = self.instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("Couldn't instantiate view controller with identifier \(T.storyboardIdentifier) ")
        }

        return viewController
    }
}

extension UIViewController: StoryboardIdentifiable {}

// MARK: identifiable

protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

extension StoryboardIdentifiable where Self: UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
}
