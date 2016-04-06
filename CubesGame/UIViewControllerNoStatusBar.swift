//
//  UIViewController-NoStatusBar.swift
//  CubesGame
//
//  Created by Matt B on 4/6/16.
//  Copyright © 2016 Matt Blessed. All rights reserved.
//

import Foundation
import UIKit

class UIViewControllerNoStatusBar: UIViewController {
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}