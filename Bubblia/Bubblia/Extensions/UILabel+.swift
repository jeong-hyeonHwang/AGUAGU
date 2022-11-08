//
//  UILabel+.swift
//  Bubblia
//
//  Created by 황정현 on 2022/11/09.
//

import UIKit

extension UILabel {
    func labelSetting(text: String, fontSize: CGFloat, weight: UIFont.Weight) {
        self.text = text
        self.textAlignment = .center
        self.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        self.textColor = .accentColor
    }
}
