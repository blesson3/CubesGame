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

struct Pattern {
    let patternOption: PatternOptions
    var rotate: PatternRotateOptions
    
    var encoding: String {
        return patternOption.rotatedEncodedPattern(rotate)
    }
    
    func rotateBy(rotate: OrientationRotate) -> Pattern {
        return rotateBy(rotate.toPatternRotateOption())
    }
    
    func rotateBy(rotate: PatternRotateOptions) -> Pattern {
        let newRotation = self.rotate.getRotationByRotatingCurrentBy(rotate)
        return Pattern(patternOption: patternOption, rotate: newRotation)
    }
    
    static func generateRandomWithRandomRotate() -> Pattern {
        let patternOption = PatternOptions.randomPattern()
        let rotate = PatternRotateOptions.randomRotation()
        return Pattern(patternOption: patternOption, rotate: rotate)
    }
}

enum PatternOptions: UInt32 {
    case Single
    
    case SmallL
    case LargeL
    
    case SmallSquare
    case LargeSquare
    
    case SmallLine
    case MediumLine
    case LargeLine
    
    case Weirdo
    case WeirdoFlip
    
    func numberOfBlocksRequired() -> Int {
        // count the number of 1s in the encoded string
        return self.rotatedEncodedPattern(.None).characters.filter({$0 == "1"}).count
    }
    
//    func allRotatedEncodings() -> [PatternRotateOptions:String] {
//        var encodings: [PatternRotateOptions:String] = [:]
//        var rotates: [PatternRotateOptions] = []
//        for i in 0..<PatternRotateOptions.count {
//            rotates.append(PatternRotateOptions(rawValue: i)!)
//        }
//        for r in rotates {
//            encodings[r] = rotatedEncodedPattern(r)
//        }
//        return encodings
//    }
    
    func rotatedEncodedPattern(rotate: PatternRotateOptions) -> String {
        
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
            case .UpsideDown:
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
            case .UpsideDown:
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
            case .UpsideDown:
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
            case .UpsideDown:
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
            case .UpsideDown:
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
            case .UpsideDown:
                return "01|11|10"
            }
            
        case .WeirdoFlip:
            switch rotate {
            case .None:
                return "1|11|01"
            case .Right:
                return "011|11"
            case .Left:
                return "011|11"
            case .UpsideDown:
                return "1|11|01"
            }
            
//        case .Weirdo:
//            switch rotate {
//            case .None:
//                return "1|11|01"
//            case .Right:
//                return "011|11"
//            case .Left:
//                return "011|11"
//            case .UpsideDown:
//                return "1|11|01"
//            }
        }
        
    }
    
    static let count: PatternOptions.RawValue = {
        // find the maximum enum value
        var maxValue: UInt32 = 0
        while let _ = PatternOptions(rawValue: maxValue) {
            maxValue += 1
        }
        return maxValue
    }()
    
    static func allPatternOptions() -> [PatternOptions] {
        var patternOptions: [PatternOptions] = []
        for i in 0..<count {
            patternOptions.append(PatternOptions(rawValue: i)!)
        }
        return patternOptions
    }
    
    static func randomPattern() -> PatternOptions {
        // pick and return a new value
        let rand = arc4random_uniform(count)
        return PatternOptions(rawValue: rand)!
    }
}

enum PatternRotateOptions: UInt32 {
    case None
    case Right
    case Left
    case UpsideDown
    
    var nextRight: PatternRotateOptions {
        switch self {
        case .None:
            return .Right
        case .Right:
            return .UpsideDown
        case .UpsideDown:
            return .Left
        case .Left:
            return .None
        }
    }
    
    var nextLeft: PatternRotateOptions {
        switch self {
        case .None:
            return .Left
        case .Right:
            return .None
        case .UpsideDown:
            return .Right
        case .Left:
            return .UpsideDown
        }
    }
    
    func getRotationByRotatingCurrentBy(rotate: PatternRotateOptions) -> PatternRotateOptions {
        switch (self, rotate) {
            
        case _ where rotate == .None:
            return self
            
        case (.Left, .Right), (.Right, .Left), (.UpsideDown, .UpsideDown):
            return .None
            
        case (.None, .Left), (.UpsideDown, .Right), (.Right, .UpsideDown):
            return .Left
            
        case (.None, .Right), (.UpsideDown, .Left), (.Left, .UpsideDown):
            return .Right
            
        case (.Right, .Right), (.Left, .Left), (.None, .UpsideDown):
            return .UpsideDown
            
        default:
            fatalError("every case should be above")
        }
    }
    
    private static let count: PatternRotateOptions.RawValue = {
        // find the maximum enum value
        var maxValue: UInt32 = 0
        while let _ = PatternRotateOptions(rawValue: maxValue) {
            maxValue += 1
        }
        return maxValue
    }()
    
    static func allRotateOptions() -> [PatternRotateOptions] {
        var patternRotateOptions: [PatternRotateOptions] = []
        for i in 0..<count {
            patternRotateOptions.append(PatternRotateOptions(rawValue: i)!)
        }
        return patternRotateOptions
    }
    
    static func randomRotation() -> PatternRotateOptions {
        // pick and return a new value
        let rand = arc4random_uniform(count)
        return PatternRotateOptions(rawValue: rand)!
    }
}

enum OrientationRotate: CGFloat {
    case Left = 90
    case Right = -90
    case UpsideDown = 180
    case None = 0
    
    static func relativeOrientation(current: UIDeviceOrientation, old: UIDeviceOrientation) -> OrientationRotate {
        switch (old, current) {
            
        case _ where old == current:
            return .None
            
        case (.Portrait, .LandscapeLeft), (.LandscapeLeft, .PortraitUpsideDown), (.PortraitUpsideDown, .LandscapeRight), (.LandscapeRight, .Portrait):
            return .Left
        case  (.Portrait, .LandscapeRight), (.LandscapeRight, .PortraitUpsideDown), (.PortraitUpsideDown, .LandscapeLeft), (.LandscapeLeft, .Portrait):
            return .Right
        case (.Portrait, .PortraitUpsideDown), (.PortraitUpsideDown, .Portrait), (.LandscapeLeft, .LandscapeRight), (.LandscapeRight, .LandscapeLeft):
            return .UpsideDown
            
        case (.FaceUp, .LandscapeLeft), (.FaceDown, .LandscapeLeft):
            return .Left
        case (.FaceUp, .LandscapeRight), (.FaceDown, .LandscapeRight):
            return .Right
        case (.FaceUp, .Portrait), (.FaceDown, .Portrait):
            return .None
            
            // Treat a faceup and facedown as to portrait
        case _ where current == .FaceDown || current == .FaceUp:
            return relativeOrientation(.Portrait, old: old)
        case _ where old == .FaceDown || old == .FaceUp:
            return relativeOrientation(current, old: .Portrait)
        
            // Unsure
        case _ where current == .Unknown || old == .Unknown:
            return .None
        
        default:
            fatalError("Exhausted relative orientation c: \(current) o: \(old)")
        }
    }
    
    func toPatternRotateOption() -> PatternRotateOptions {
        switch self {
        case .Left:
            return .Left
        case .Right:
            return .Right
        case .None:
            return .None
        case .UpsideDown:
            return .UpsideDown
        }
    }
}

// MARK: GamePiecePattern

class GamePiecePattern: UIView {
    private let pieces: [GamePiece]
    var pattern: Pattern
    
    private(set) var beingDragged: Bool = false
    
//    var rotation: PatternRotateOptions
    
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
        beingDragged = true
        touchesHandler?.gamePieceTouchesBegan(self, touches: touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        beingDragged = false
        touchesHandler?.gamePieceTouchesEnded(self, touches: touches, withEvent: event)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        touchesHandler?.gamePieceTouchesMoved(self, touches: touches, withEvent: event)
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        touchesHandler?.gamePieceTouchesEnded(self, touches: touches, withEvent: event)
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let ht = super.hitTest(point, withEvent: event)
        return ht
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let margin: CGFloat = 20
        let area = CGRectInset(self.bounds, -margin, -margin)
        return CGRectContainsPoint(area, point)
    }
}

// MARK: GamePiecePatternGenerator

class GamePiecePatternGenerator {
    
//    static func generatePatternWRandomRotate(pattern: Pattern) -> GamePiecePattern {
//        // get randomly rotated pattern
//        let randomRotation = Pattern.PatternRotate.randomRotation()
//        return generatePattern(pattern, rotate: randomRotation)
//    }
    
    static func generatePattern(pattern: Pattern) -> GamePiecePattern {
//        MBLog("Generating \(pattern) with rotation \(rotate)")
        
        var pieces: [GamePiece] = []
        for _ in 0..<pattern.patternOption.numberOfBlocksRequired() {
            pieces.append(GamePiece())
        }
        
        // create piecePattern
        let piecePattern = GamePiecePattern(frame: CGRect(x: 0, y: 0, width: GameManager.sharedManager.globalPieceSize, height: GameManager.sharedManager.globalPieceSize), pattern: pattern, pieces: pieces)
        
        let piecePlusCushion = GameManager.sharedManager.globalPieceSize+GameManager.sharedManager.globalPieceCushion
        
        var maxX: CGFloat = 0
        var maxY: CGFloat = 0
        
        // get the components of the pattern
        let patternComponents = pattern.encoding.componentsSeparatedByString("|")
        
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
        piecePattern.setPiecesBackgroundColor(colorForNumber(pattern.patternOption.numberOfBlocksRequired()))
        
        return piecePattern
    }
    
    static func degreesToRadians(degrees: CGFloat) -> CGFloat {
        return CGFloat(M_PI)*degrees/180.0
    }
    
    static private func colorForNumber(num: Int) -> UIColor {
        switch num {
        case 1:
            return ASCFlatUIColor.sunFlowerColor()
        case 2:
            return ASCFlatUIColor.amethystColor()
        case 3:
            return ASCFlatUIColor.pomegranateColor()
        case 4:
            return ASCFlatUIColor.greenSeaColor()
        case 5:
            return ASCFlatUIColor.belizeHoleColor()
        default:
            return ASCFlatUIColor.pumpkinColor()
        }
    }
}
