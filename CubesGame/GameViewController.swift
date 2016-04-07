//
//  ViewController.swift
//  CubesGame
//
//  Created by Matt B on 4/3/16.
//  Copyright © 2016 Matt Blessed. All rights reserved.
//

import UIKit

@objc protocol TouchesHandler: class {
    func gamePieceTouchesBegan(gamePiecePattern: GamePiecePattern, touches: Set<UITouch>, withEvent event: UIEvent?)
    func gamePieceTouchesMoved(gamePiecePattern: GamePiecePattern, touches: Set<UITouch>, withEvent event: UIEvent?)
    func gamePieceTouchesEnded(gamePiecePattern: GamePiecePattern, touches: Set<UITouch>, withEvent event: UIEvent?)
}

class GameViewController: UIViewController {

    @IBOutlet weak var gameBoardView: GameBoardView!
    @IBOutlet weak var piecesSliderView: UIView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    private var currentPage: [GamePiecePattern] = []
    private var patternsStartingCenters: [GamePiecePattern:CGPoint] = [:]
    private var patternsStartingTransforms: [GamePiecePattern:CGAffineTransform] = [:]
    
    private var currentOrientation: UIDeviceOrientation = .Unknown
    
    private var scaleDownTransform = CGAffineTransformMakeScale(0.9, 0.9)
    
    @IBOutlet weak var characterImageView: UIImageView!
    
    private var viewHasAppeared: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !viewHasAppeared {
            gameBoardView.backgroundColor = UIColor.clearColor()
            piecesSliderView.backgroundColor = UIColor.clearColor()
            
            gameBoardView.delegate = self
            
            // Removed orientation changing from gameplay for now
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(orientationDidChange(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !viewHasAppeared {
            viewHasAppeared = true
            
            // for effect
            delay(1.0) {
                // simulates a reset of the board, page, and timer
                self.resetButtonPressed(self.resetButton)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fillPage() {
        // ensure there are spaces to fill
        guard currentPage.count < GameManager.sharedManager.sliderPageSize else { return }
        
        let difference = GameManager.sharedManager.sliderPageSize-currentPage.count
        
        // create new pieces
        for _ in 0..<difference {
            let p = Pattern.randomPattern()
            
            let pattern = GamePiecePatternGenerator.generatePatternWRandomRotate(p)
            pattern.touchesHandler = self
            pattern.center = CGPoint(x: -pattern.bounds.width*1.5, y: piecesSliderView.center.y)
            pattern.transform = scaleDownTransform
            self.view.addSubview(pattern)
            
            currentPage.insert(pattern, atIndex: 0)
        }
        
        // animate each seperately on screen at x points: 3/16 | 8/16 | 13/16
        var i: CGFloat = 0 // index
        var j: CGFloat = 3 // x delta
        for piece in currentPage {
            UIView.animateWithDuration(0.35, delay: 0.07*Double(CGFloat(currentPage.count)-i), usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: .CurveEaseInOut, animations: {
                piece.center = CGPointMake(self.piecesSliderView.bounds.width*j/16, self.piecesSliderView.center.y)
                }, completion: { (finished) in
            })
            
            i += 1
            j += 5
        }
    }
    
    @IBAction func shareButtonPressed(sender: AnyObject) {
        let imageToShare = UIView.captureScreen(self.view)
        let textToShare = "So addicting.\n\nDownload!\nhttp://mylink.com/eEoDks123" // TODO: randomize the text
        let activityItems: [AnyObject] = [textToShare, imageToShare]
        let activity = UIActivity()
        activity.prepareWithActivityItems([UIActivityTypeMessage, UIActivityTypePostToTwitter, UIActivityTypePostToFacebook, UIActivityTypeSaveToCameraRoll])
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: [activity])
        activityVC.excludedActivityTypes = [UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypeAddToReadingList, UIActivityTypeOpenInIBooks, UIActivityTypeAirDrop, UIActivityTypePrint]
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func resetButtonPressed(sender: AnyObject) {
        
        // animate each seperately on screen at x points: 3/16 | 8/16 | 13/16, but plus 16 for each numerator because we are animating them offscreen
        var i: CGFloat = 0 // index
        var j: CGFloat = 3 // x delta
        for piece in currentPage {
            UIView.animateWithDuration(0.35, delay: 0.07*Double(CGFloat(currentPage.count)-i), usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: .CurveEaseInOut, animations: {
                piece.center = CGPointMake(self.piecesSliderView.bounds.width+(self.piecesSliderView.bounds.width*j/16), self.piecesSliderView.center.y)
                }, completion: { (finished) in
                    piece.removeFromSuperview()
            })
            
            i += 1
            j += 5
        }
        
        currentPage.removeAll()
        
        delay(0.5) {
            self.fillPage()
        }
        
        gameBoardView.resetBoard()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

// MARK: Orientation Handler

extension GameViewController {
    func orientationDidChange(notification: NSNotification) {
        let orientation = UIDevice.currentDevice().orientation
        let previousOrientation = currentOrientation
        currentOrientation = orientation
        
        // Compare against current block orientedRotate
        // Reset the blocks back to their original .None rotate
        
        // if it was portrait, but now it is landscape, turn the blocks
        if currentOrientation != previousOrientation {
            // get difference
            let relativeRotate = OrientationRotate.relativeOrientation(currentOrientation, old: previousOrientation)
            if relativeRotate != .None {
                rotatePage(relativeRotate)
            }
        }
        
        MBLog("Orientation changed! \(orientation.rawValue)")
    }
    
    private func rotatePage(rotate: OrientationRotate) {
        
        var initialTransforms: [GamePiecePattern:CGAffineTransform] = [:]
        
        for piecePattern in currentPage {
            
            // get the new rotated pattern
            // generate the pattern
            // add to view with same center
            // transform to look like original
            // animate transform for effect
            
            initialTransforms[piecePattern] = piecePattern.transform
            
            let nextRotation: Pattern.PatternRotate = piecePattern.rotation.getRotationByRotatingCurrentBy(rotate)
            let rotatedPattern = GamePiecePatternGenerator.generatePattern(piecePattern.pattern, rotate: nextRotation)
            rotatedPattern.center = piecePattern.center
            
            // removes all of the subviews from the piece pattern
            for s in piecePattern.subviews {
                s.removeFromSuperview()
            }
            
            // add all of the rotated pieces in
            for s in rotatedPattern.subviews {
                piecePattern.addSubview(s)
            }
            
            let center = piecePattern.center
            piecePattern.frame = rotatedPattern.frame
            piecePattern.center = center // need to retain same center
            piecePattern.rotation = rotatedPattern.rotation
            piecePattern.pattern = rotatedPattern.pattern
            let rotatedTransform = CGAffineTransformMakeRotation(GamePiecePatternGenerator.degreesToRadians(rotate.rawValue))
            piecePattern.transform = CGAffineTransformConcat(piecePattern.transform, rotatedTransform) // artifically rotate backwards to simulate the original
        }
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: [.CurveEaseInOut, .AllowUserInteraction], animations: {
        // UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: .CurveEaseInOut, animations: {
            
            // rotatedPage
            for rp in self.currentPage {
                rp.transform = initialTransforms[rp]!
            }
            
            }) { (finished) in
        }
    }
}

// MARK: GamePiecePattern TouchesHandler

extension GameViewController: TouchesHandler {
    
    func gamePieceTouchesBegan(gamePiecePattern: GamePiecePattern, touches: Set<UITouch>, withEvent event: UIEvent?) {
        let t = touches.first!
        let point = t.locationInView(self.view)
        
        var newCenter = CGPoint(x: point.x, y: point.y)
        
        // adjust so the piece is not directly under the user's finger
        // adjust the center for the orientation
        switch currentOrientation {
        case .FaceDown, .FaceUp, .Portrait:
            newCenter.y -= 80
        case .LandscapeLeft:
            newCenter.x += 80
        case .LandscapeRight:
            newCenter.x -= 80
        case .PortraitUpsideDown:
            newCenter.y += 80
        default:
            newCenter.y -= 80
        }
        
        // record initial center and transform
        patternsStartingCenters[gamePiecePattern] = gamePiecePattern.center
        patternsStartingTransforms[gamePiecePattern] = gamePiecePattern.transform
        
        // animate larger
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseInOut, animations: {
            gamePiecePattern.transform = CGAffineTransformMakeScale(1.1, 1.1)
            }, completion: nil)
        
        // animate center initially
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseInOut, animations: {
            gamePiecePattern.center = newCenter
            }, completion: nil)
    }
    
    func gamePieceTouchesMoved(gamePiecePattern: GamePiecePattern, touches: Set<UITouch>, withEvent event: UIEvent?) {
        let t = touches.first!
        let point = t.locationInView(self.view)
        
        
        var newCenter = CGPoint(x: point.x, y: point.y)
        
        // adjust so the piece is not directly under the user's finger
        // adjust the center for the orientation
        switch currentOrientation {
        case .FaceDown, .FaceUp, .Portrait:
            newCenter.y -= 80
            
        case .LandscapeLeft:
            newCenter.x += 80
            
            // needs adjustment near left edge
            if point.x < 100 {
                let percent = (point.x/100)
                newCenter.x = max(point.x, (newCenter.x*percent)+GameManager.sharedManager.globalPieceSize*1.0*(1-percent))
            }
            
        case .LandscapeRight:
            // needs adjustment near right edge
            if point.x > UIScreen.mainScreen().bounds.width-100 {
                let percent = ((point.x-(UIScreen.mainScreen().bounds.width-100))/100)
                newCenter.x -= 80 - (percent * 80) + GameManager.sharedManager.globalPieceSize*1.0*percent
            }
            else {
                newCenter.x -= 80
            }
            
        case .PortraitUpsideDown:
            newCenter.y += 80
            
        default:
            newCenter.y -= 80
        }
        
        UIView.animateWithDuration(0.08, delay: 0.0, options: [.CurveEaseInOut, .AllowUserInteraction], animations: {
            gamePiecePattern.center = newCenter
            }, completion: { finished in
            })
        
    }
    
    func gamePieceTouchesEnded(gamePiecePattern: GamePiecePattern, touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        // check if the pattern was placed on the board and it can be placed there
        let convertedPiecePatternRect = self.view.convertRect(gamePiecePattern.frame, toView: gameBoardView)
        if gamePiecePattern.frame.intersects(gameBoardView.frame) && gameBoardView.canPlaceGamePiecePattern(gamePiecePattern, frameInBoard: convertedPiecePatternRect) {
            // place pattern onto the gameview
            var nextOrigin = gameBoardView.placeGamePiecePattern(gamePiecePattern, frameInBoard: convertedPiecePatternRect)
            // we must convert the frame given, to a frame in self.view
            nextOrigin = gameBoardView.convertPoint(nextOrigin, toView: self.view)
            
            // with the size transform larger, the rect gets messed up. The real origin is the width halved * (1-transformDelta)
            // in this case the transform delta is 1.1 so 0.1 is used
            nextOrigin = CGPointMake(nextOrigin.x-gamePiecePattern.bounds.size.width/2*0.1, nextOrigin.y-gamePiecePattern.bounds.size.height/2*0.1)
            
            UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseInOut, animations: {
                gamePiecePattern.frame.origin = nextOrigin
                }, completion: { (finished) in
                    self.gameBoardView.updateBoardColoring() // does the work of setting the background square to the color of the placed piece
                    gamePiecePattern.removeFromSuperview()   // remove the piece as we do not need it anymore
            })
            
            delay(0.1) {
                // play placement sound effect
                GameSoundManager.sharedManager.playRandomPlacementSound()
            }
            
            // remove pattern from current page
            // safer than assuming that the pattern is on the page, sort of testing
            if let i = currentPage.indexOf(gamePiecePattern) {
                currentPage.removeAtIndex(i)
            }
            
            // fill the gaps in the page with new blocks
            fillPage()
            
            // shink back to normal size
            UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseInOut, animations: {
                gamePiecePattern.transform = CGAffineTransformIdentity
                }, completion: nil)
        }
        else {
            // throw that piece back to where it belongs
            UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseInOut, animations: {
                gamePiecePattern.center = self.patternsStartingCenters[gamePiecePattern]!
                }, completion: { finished in
                    if finished {
                        self.patternsStartingCenters[gamePiecePattern] = nil
                    }
            })
            
            // shink back to normal size
            UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseInOut, animations: {
                gamePiecePattern.transform = self.patternsStartingTransforms[gamePiecePattern]!
                }, completion: nil)
        }
    }
}

// MARK: GameBoardViewDelegate

extension GameViewController: GameBoardViewDelegate {
    func gameBoardDidFill() {
        UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseInOut, animations: { 
            self.characterImageView.transform = CGAffineTransformMakeRotation(GamePiecePatternGenerator.degreesToRadians(360*2))
            }) { (finished) in
                self.characterImageView.transform = CGAffineTransformIdentity
        }
    }
}

// MARK: MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate

//extension GameViewController: MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate {
//    
//}
