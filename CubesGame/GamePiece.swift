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
    
    case Weirdo
    
    func numberOfBlocksRequired() -> Int {
        // count the number of 1s in the encoded string
        return self.encodedPattern().characters.filter({ $0 == "1"}).count
    }
    
    func encodedPattern() -> String {
        switch self {
        case .Single:
            return "1"
        case .SmallL:
            return "1|11"
        case .LargeL:
            return "1|1|111"
        case .SmallSquare:
            return "11|11"
        case .LargeSquare:
            return "111|111|111"
        case .SmallLine:
            return "1|1"
        case .MediumLine:
            return "1|1|1"
        case .LargeLine:
            return "1|1|1|1"
            
        case .Weirdo:
            return "01|11|1"
        }
    }
    
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
        self.layer.cornerRadius = 4 // 3.2
    }
}

