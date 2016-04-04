//
//  GamePiece.swift
//  CubesGame
//
//  Created by Matt B on 4/3/16.
//  Copyright © 2016 Matt Blessed. All rights reserved.
//

import Foundation
import UIKit

enum Pattern: UInt32 {
    case Single
    
    case SmallL
    case LargeL
    
    case SmallSquare
    case LargeSquare
    
    case SmallLine
    case MediumLine
    case LargeLine
    
    private static let count: Pattern.RawValue = {
        // find the maximum enum value
        var maxValue: UInt32 = 0
        while let _ = Pattern(rawValue: maxValue) {
            maxValue += 1
        }
        return maxValue
    }()
    
    static func randomPattern() -> Pattern {
        // pick and return a new value
        let rand = arc4random_uniform(count)
        return Pattern(rawValue: rand)!
    }
}

class GamePiece: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    init() {
        let frame = CGRect(x: 0, y: 0, width: GameManager.sharedManager.globalPieceSize, height: GameManager.sharedManager.globalPieceSize)
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        self.backgroundColor = UIColor(red: 195.0/255.0, green: 195.0/255.0, blue: 195.0/255.0, alpha: 1.0)
        self.layer.cornerRadius = 3.2
    }
}

