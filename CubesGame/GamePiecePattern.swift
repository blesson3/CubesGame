//
//  GamePiecePattern.swift
//  CubesGame
//
//  Created by Matt B on 4/3/16.
//  Copyright © 2016 Matt Blessed. All rights reserved.
//

import Foundation
import UIKit
import ASCFlatUIColor
import SwiftRandom

// MARK: Pattern

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
        return self.encodedPattern().characters.filter({$0 == "1"}).count
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
    
    enum PatternRotate: UInt32 {
        case None
        case Right
        case Left
        case Flip
        
        private static let count: PatternRotate.RawValue = {
            // find the maximum enum value
            var maxValue: UInt32 = 0
            while let _ = PatternRotate(rawValue: maxValue) {
                maxValue += 1
            }
            return maxValue
        }()
        
        static func randomRotation() -> PatternRotate {
            // pick and return a new value
            let rand = arc4random_uniform(count)
            return PatternRotate(rawValue: rand)!
        }
    }
    
    func rotatedEncodedPattern(rotate: PatternRotate) -> String {
        
        switch self {
        case .Single:
            return "1"
            
        case .SmallL:
            switch rotate {
            case .None:
                return "1|11"
            case .Right:
                return "01|11"
            case .Left:
                return "11|1"
            case .Flip:
                return "11|01"
            }
            
        case .LargeL:
            switch rotate {
            case .None:
                return "1|1|111"
            case .Right:
                return "001|001|111"
            case .Left:
                return "111|1|1"
            case .Flip:
                return "111|001|001"
            }
            
        case .SmallSquare:
            return "11|11"
            
        case .LargeSquare:
            return "111|111|111"
            
        case .SmallLine:
            switch rotate {
            case .None:
                return "1|1"
            case .Right:
                return "11"
            case .Left:
                return "11"
            case .Flip:
                return "1|1"
            }
            
        case .MediumLine:
            switch rotate {
            case .None:
                return "1|1|1"
            case .Right:
                return "111"
            case .Left:
                return "111"
            case .Flip:
                return "1|1|1"
            }
            
        case .LargeLine:
            switch rotate {
            case .None:
                return "1|1|1|1"
            case .Right:
                return "1111"
            case .Left:
                return "1111"
            case .Flip:
                return "1|1|1|1"
            }
            
        case .Weirdo:
            switch rotate {
            case .None:
                return "01|11|10"
            case .Right:
                return "11|011"
            case .Left:
                return "11|011"
            case .Flip:
                return "01|11|10"
            }
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

// MARK: GamePiecePattern

class GamePiecePattern: UIView {
    private let pieces: [GamePiece]
    let pattern: Pattern
    let rotation: Pattern.PatternRotate
    
    var piecesBackgroundColor: UIColor {
        return pieces[0].backgroundColor!
    }
    
//    var transformedFrame: CGRect {
//        let switchSize = rotationDegrees % 180 == 90 // if its rotated at a 90 or 270 degree angle, switch the width and height
//        let size = CGSize(width: switchSize ? self.bounds.size.height : self.bounds.size.width, height: switchSize ? self.bounds.size.width : self.bounds.size.height)
//        let center = self.center
//        
//        let origin = CGPoint(x: center.x-size.width/2, y: center.y-size.height/2)
//        
//        return CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height)
//    }
    
    weak var touchesHandler: TouchesHandler?
    
    var pointOfInterest: CGPoint {
        return pieces[0].frame.origin
    }
    
    init(frame: CGRect, pattern: Pattern, rotation: Pattern.PatternRotate, pieces: [GamePiece]) {
        self.pieces = pieces
        self.pattern = pattern
        self.rotation = rotation
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPiecesBackgroundColor(color: UIColor) {
        for p in pieces {
            p.backgroundColor = color
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        touchesHandler?.gamePieceTouchesBegan(self, touches: touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        touchesHandler?.gamePieceTouchesEnded(self, touches: touches, withEvent: event)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        touchesHandler?.gamePieceTouchesMoved(self, touches: touches, withEvent: event)
    }
}

// MARK: GamePiecePatternGenerator

class GamePiecePatternGenerator {
    static func generatePattern(pattern: Pattern) -> GamePiecePattern {
        
        // get randomly rotated pattern
        let randomRotation = Pattern.PatternRotate.randomRotation()
        MBLog("Generating \(pattern) with rotation \(randomRotation)")
        
        var pieces: [GamePiece] = []
        for _ in 0..<pattern.numberOfBlocksRequired() {
            pieces.append(GamePiece())
        }
        
        // create piecePattern
        let piecePattern = GamePiecePattern(frame: CGRect(x: 0, y: 0, width: GameManager.sharedManager.globalPieceSize, height: GameManager.sharedManager.globalPieceSize), pattern: pattern, rotation: randomRotation, pieces: pieces)
        
        let piecePlusCushion = GameManager.sharedManager.globalPieceSize+GameManager.sharedManager.globalPieceCushion
        
        var maxX: CGFloat = 0
        var maxY: CGFloat = 0
        
        // get the components of the pattern
        let patternComponents = pattern.rotatedEncodedPattern(randomRotation).componentsSeparatedByString("|")
        
        var k = 0
        for _i in 0..<patternComponents.count { // columns
            let i = CGFloat(_i)
            
            let l = patternComponents[_i]
            let rows = l.characters.map{ String($0) }
            for _j in 0..<rows.count {
                let j = CGFloat(_j)
                
                let c = rows[_j]
                if c == "1" {
                    let p = pieces[k]
                    k += 1
                    
                    let x = i*piecePlusCushion
                    let y = j*piecePlusCushion
                    
                    if x+GameManager.sharedManager.globalPieceSize > maxX {
                        maxX = x+GameManager.sharedManager.globalPieceSize
                    }
                    if y+GameManager.sharedManager.globalPieceSize > maxY {
                        maxY = y+GameManager.sharedManager.globalPieceSize
                    }
                    
                    p.frame.origin = CGPoint(x: x, y: y)
                    piecePattern.addSubview(p)
                }
            }
        }
        
        piecePattern.frame.size = CGSize(width: maxX, height: maxY)
//        piecePattern.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.4) // TESTING
        
        // set colors based on the number of pieces used for each pattern
        piecePattern.setPiecesBackgroundColor(colorForNumber(pattern.numberOfBlocksRequired()))
        
        return piecePattern
    }
    
    private static func degreesToRadians(degrees: CGFloat) -> CGFloat {
        return CGFloat(M_PI)*degrees/180.0
    }
    
    static private func colorForNumber(num: Int) -> UIColor {
        switch num {
        case 1:
            return ASCFlatUIColor.carrotColor()
        case 2:
            return ASCFlatUIColor.amethystColor()
        case 3:
            return ASCFlatUIColor.pomegranateColor()
        case 4:
            return ASCFlatUIColor.greenSeaColor()
        case 5:
            return ASCFlatUIColor.belizeHoleColor()
        default:
            return ASCFlatUIColor.alizarinColor()
        }
    }
}
