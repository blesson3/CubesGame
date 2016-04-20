//
//  UINavigationControllerNoStatusBar.swift
//  CubesGame
//
//  Created by Matt B on 4/18/16.
//  Copyright © 2016 Matt Blessed. All rights reserved.
//

import Foundation

class UINavigationControllerNoStatusBar: UINavigationController {    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
}