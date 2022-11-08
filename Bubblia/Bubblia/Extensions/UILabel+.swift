//
//  UILabel+.swift
//  Bubblia
//
//  Created by 황정현 on 2022/11/09.
//

import UIKit

extension UILabel {
    func labelSetting(text: String, font: UIFont, isTransparent: Bool) {
        self.text = text
        self.textAlignment = .center
        self.font = font
        self.textColor = .accentColor
        self.alpha = isTransparent ? 0 : 1
    }
}
