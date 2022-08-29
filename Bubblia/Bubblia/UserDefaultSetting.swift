//
//  UserDefaultSetting.swift
//  Bubblia
//
//  Created by 황정현 on 2022/08/30.
//

import Foundation

func setHighScore(value: Int) {
    UserDefaults.standard.set(value, forKey: "HighScore")
}

func getHighScore() -> Int {
    return UserDefaults.standard.integer(forKey: "HighScore")
}
