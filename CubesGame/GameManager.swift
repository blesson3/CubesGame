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
    
    // if this is changed from (3), the algorithm for piece placement within the slide needs changing
    var sliderPageSize: Int = 3
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