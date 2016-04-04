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
    
    var globalPieceSize: CGFloat = 0.0
    var globalPieceCushion: CGFloat = 0.0
}