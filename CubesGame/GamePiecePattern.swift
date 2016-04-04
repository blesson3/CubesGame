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

class GamePiecePattern: UIView {
    private let pieces: [GamePiece]
    let pattern: Pattern
    
    private(set) var rotationDegrees: CGFloat = 0
    
    var transformedFrame: CGRect {
        let switchSize = rotationDegrees % 180 == 90 // if its rotated at a 90 or 270 degree angle, switch the width and height
        let size = CGSize(width: switchSize ? self.bounds.size.height : self.bounds.size.width, height: switchSize ? self.bounds.size.width : self.bounds.size.height)
        let center = self.center
        
        let origin = CGPoint(x: center.x-size.width/2, y: center.y-size.height/2)
        
        return CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height)
    }
    
    weak var touchesHandler: TouchesHandler?
    
    var pointOfInterest: CGPoint {
        return pieces[0].frame.origin
    }
    
    init(frame: CGRect, pattern: Pattern, pieces: [GamePiece]) {
        self.pieces = pieces
        self.pattern = pattern
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

class GamePiecePatternGenerator {
    static func generatePattern(pattern: Pattern) -> GamePiecePattern {
        MBLog("Generating \(pattern)")
        
        var pieces: [GamePiece] = []
        for _ in 0...pattern.numberOfBlocksRequired() {
            pieces.append(GamePiece())
        }
        
        let piecePattern = GamePiecePattern(frame: CGRect(x: 0, y: 0, width: GameManager.sharedManager.globalPieceSize, height: GameManager.sharedManager.globalPieceSize), pattern: pattern, pieces: pieces)
        let patternComponents = pattern.encodedPattern().componentsSeparatedByString("|")
        
        let piecePlusCushion = GameManager.sharedManager.globalPieceSize+GameManager.sharedManager.globalPieceCushion
        
        var maxX: CGFloat = 0
        var maxY: CGFloat = 0
        
        var k = 0
        for _i in 0...patternComponents.count-1 { // columns
            let i = CGFloat(_i)
            
            let l = patternComponents[_i]
            let rows = l.characters.map{ String($0) }
            for _j in 0...rows.count-1 {
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
        piecePattern.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.4) // TESTING
        
        piecePattern.setPiecesBackgroundColor(colorForNumber(pattern.numberOfBlocksRequired()))
        
        // random rotate
        let delta = Int.random(0...3)
        MBLog("Rotating the \(pattern) \(delta*90) degrees")
        piecePattern.rotationDegrees = CGFloat(90*delta)
        piecePattern.transform = CGAffineTransformMakeRotation(degreesToRadians(piecePattern.rotationDegrees))
        
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
            return ASCFlatUIColor.cloudsColor()
        case 4:
            return ASCFlatUIColor.greenSeaColor()
        case 5:
            return ASCFlatUIColor.belizeHoleColor()
        default:
            return ASCFlatUIColor.alizarinColor()
        }
    }
}
