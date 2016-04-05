//
//  GameManager.swift
//  CubesGame
//
//  Created by Matt B on 4/3/16.
//  Copyright © 2016 Matt Blessed. All rights reserved.
//

import Foundation
import UIKit

class GameManager {
    static let sharedManager = GameManager()
    
    var globalPieceSizePlusCushion: CGFloat {
        return globalPieceSize+globalPieceCushion
    }
    
    var globalPieceSize: CGFloat = 0.0
    var globalPieceCushion: CGFloat = 0.0
}

// Global helper function

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}