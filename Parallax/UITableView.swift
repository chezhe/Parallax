//
//  UITableView.swift
//  Parallax
//
//  Created by 王亮 on 2019/11/29.
//  Copyright © 2019 王亮. All rights reserved.
//

import UIKit

/// :nodoc:
public extension UITableView {

    /// Register given `UITableViewCell` in tableView.
    /// Cell will be registered with the name of it's class as identifier.
    func register<T: UITableViewCell>(_: T.Type) {
        register(T.self, forCellReuseIdentifier: String(describing: T.self))
    }

    /// Register given `UITableViewCell` in tableView.
    /// Cell will be registered with the name of it's class as identifier.
    func registerNib<T: UITableViewCell>(_: T.Type) {
        let nib = UINib(nibName: String(describing: T.self), bundle: nil)
        register(nib, forCellReuseIdentifier: String(describing: T.self))
    }

    /// Dequeue cell of given class from tableView.
    func dequeue<T: UITableViewCell>(_: T.Type) -> T {
        return dequeueReusableCell(withIdentifier: String(describing: T.self)) as? T ?? T()
    }
}

