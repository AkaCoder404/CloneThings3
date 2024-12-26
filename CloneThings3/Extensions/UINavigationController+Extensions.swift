//
//  UINavigationController+Extensions.swift
//  CloneThings3
//
//  Created by George Li on 12/21/24.
//

import Foundation
import SwiftUI

// inspired: https://stackoverflow.com/questions/59921239/hide-navigation-bar-without-losing-swipe-back-gesture-in-swiftui

extension UINavigationController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
    }
}
