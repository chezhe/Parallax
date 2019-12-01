//
//  DetailViewController.swift
//  Parallax
//
//  Created by 王亮 on 2019/11/29.
//  Copyright © 2019 王亮. All rights reserved.
//

import ElongationPreview
import UIKit

final class DetailViewController: ElongationDetailViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.registerNib(GridViewCell.self)
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt _: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(GridViewCell.self)
        return cell
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        let appearance = ElongationConfig.shared
        let headerHeight = appearance.topViewHeight + appearance.bottomViewHeight
        let screenHeight = UIScreen.main.bounds.height
        return screenHeight - headerHeight
    }
}
