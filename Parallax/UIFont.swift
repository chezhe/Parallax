//
//  UIFont.swift
//  Parallax
//
//  Created by 王亮 on 2019/11/29.
//  Copyright © 2019 王亮. All rights reserved.
//

import UIKit

extension UIFont {

    enum FontWeight: String {
        case regular, medium, bold
    }

    static func robotoFont(ofSize: CGFloat, weight: FontWeight = .regular) -> UIFont {
        return UIFont(name: "Roboto-\(weight.rawValue.capitalized)", size: ofSize) ?? UIFont.systemFont(ofSize: ofSize)
    }
}
