//
//  Constants.swift
//  Bubblia
//
//  Created by 황정현 on 2022/08/29.
//

import UIKit

// https://stackoverflow.com/questions/52402477/ios-detect-if-the-device-is-iphone-x-family-frameless
var hasTopNotch: Bool {
    if #available(iOS 11.0, tvOS 11.0, *) {
        return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
    }
    return false
}

// https://stackoverflow.com/questions/52652956/how-to-detect-if-the-device-iphone-has-physical-home-button
//https://www.hackingwithswift.com/forums/swift/how-to-create-a-value-type-from-uiwindowscene/10485
var isPhysicalHomeButtonExist: Bool {
    let scenes = UIApplication.shared.connectedScenes
    let windowScenes = scenes.first as? UIWindowScene
    let window = windowScenes?.windows.first
    if #available(iOS 13.0, *),
       window?.safeAreaInsets.bottom ?? 0 > 0 {
       return false
   }
   return true
}

