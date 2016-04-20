//
//  ViewController.swift
//  CubesGame
//
//  Created by Matt B on 4/3/16.
//  Copyright © 2016 Matt Blessed. All rights reserved.
//

import UIKit
import Appodeal

@objc protocol TouchesHandler: class {
    func gamePieceTouchesBegan(gamePiecePattern: GamePiecePattern, touches: Set<UITouch>, withEvent event: UIEvent?)
    func gamePieceTouchesMoved(gamePiecePattern: GamePiecePattern, touches: Set<UITouch>, withEvent event: UIEvent?)
    func gamePieceTouchesEnded(gamePiecePattern: GamePiecePattern, touches: Set<UITouch>?, withEvent event: UIEvent?)
}

class GameViewController: UIViewController {

    @IBOutlet weak var gameBoardView: GameBoardView!
    @IBOutlet weak var piecesSliderView: UIView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var resetImageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var shareImageView: UIImageView!
    
    private var currentPage: [GamePiecePattern] = []
    private var patternsStartingCenters: [GamePiecePattern:CGPoint] = [:]
    private var patternsStartingTransforms: [GamePiecePattern:CGAffineTransform] = [:]
    
    private var currentOrientation: UIDeviceOrientation = .Unknown
    
    private var scaleDownTransform = CGAffineTransformMakeScale(0.75, 0.75)
    
    @IBOutlet weak var characterImageView: UIImageView!
    
    // flags
    private var viewHasAppeared: Bool = false
    private let rotationEnabled = false // TODO: move to GameManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // make sure this setup code is not called more than once
        if !viewHasAppeared {
            gameBoardView.backgroundColor = UIColor.clearColor()
            piecesSliderView.backgroundColor = UIColor.clearColor()
            
            // make the share and reset buttons white
            resetImageView.image = resetImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
            resetImageView.tintColor = UIColor.whiteColor()
            
            shareImageView.image = shareImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
            shareImageView.tintColor = UIColor.whiteColor()
            
            if rotationEnabled {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(orientationDidChange(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !viewHasAppeared {
            viewHasAppeared = true
            
            Appodeal.showAd(AppodealShowStyle.BannerTop, rootViewController: self)
            
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
        
        let gameBoardPercentFilled = gameBoardView.percentFilled
        
        // create new piece(s)
        for _ in 0..<difference {
            // gets pattern based on an algorithm with a varied distribution
            let pattern: Pattern = Pattern(patternOption: PatternOptions.getWeightedRandomPattern(boardFill: Double(gameBoardPercentFilled)), rotate: PatternRotateOptions.randomRotation())
            
            let piecePattern = GamePiecePatternGenerator.generatePattern(pattern)
            piecePattern.touchesHandler = self
            piecePattern.center = CGPoint(x: -piecePattern.bounds.width*1.5, y: piecesSliderView.center.y)
            piecePattern.transform = scaleDownTransform
            self.view.addSubview(piecePattern)
            
            currentPage.insert(piecePattern, atIndex: 0)
        }
        
        // animate each seperately on screen at x points: 3/16 | 8/16 | 13/16
        var i: CGFloat = 0 // index
        var j: CGFloat = 3 // x delta
        for piece in currentPage {
            if !piece.beingDragged {
                UIView.animateWithDuration(0.35, delay: 0.07*Double(CGFloat(currentPage.count)-i), usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: [.AllowUserInteraction, .CurveEaseInOut], animations: {
                    piece.center = self.getPieceCenterForCurrentPage(piece)
                    }, completion: { (finished) in
                })
            }
           
            i += 1
            j += 5
        }
        
        // if the board is around 80% full, check if there is at least one more placing with the current page
        if gameBoardPercentFilled == 1.0 {
            determinedGameWon()
        }
        else if gameBoardPercentFilled >= 0.8 && !gameBoardView.solutionExistsWithPatterns(currentPage.map { $0.pattern }, rotationEnabled: rotationEnabled) {
            determinedGameLost()
        }
    }
    
    func determinedGameWon() {
        MBLog("You win!")
        GameManager.sharedManager.trackSessionWin()
        delay(1.0) {
            showAlert(title: "You Win!", message: "You won! Share with your friends retry?", style: .Alert, buttons: [("Retry?", .Default), ("Ok", .Default)], buttonPressed: { (title) in
                switch title! {
                case "Retry?":
                    self.resetButtonPressed(self)
                case "Ok":
                    // do nothing
                    break
                default:
                    break
                }
                
                // show ad
                delay(0.5) {
                    // First check for videos loaded, then interstitial
                    let adStylePriority:[AppodealShowStyle] = [.SkippableVideo, .Interstitial]
                    for s in adStylePriority {
                        if Appodeal.isReadyForShowWithStyle(s) {
                            Appodeal.showAd(s, rootViewController: self)
                        }
                    }
                }
            })
        }

    }
    
    func determinedGameLost() {
        MBLog("Game over!")
        // analytics
        GameManager.sharedManager.trackSessionLose()
        
        // fix: this causes a problem that the user is unable to retry if okay is pressed in the following prompt
//        self.view.userInteractionEnabled = false // disallow the user to make any more moves
        
        delay(2.0) {
            showAlert(title: "Game Over!", message: "There are no more moves, retry?", style: .Alert, buttons: [("Retry?", .Default), ("Ok", .Default)], buttonPressed: { (title) in
                switch title! {
                case "Retry?":
                    self.resetButtonPressed(self)
                case "Ok":
                    // do nothing
                    break
                default:
                    break
                }
                
                // show ad
                delay(0.5) {
                    // First check for videos loaded, then interstitial
                    let adStylePriority:[AppodealShowStyle] = [.SkippableVideo, .Interstitial]
                    for s in adStylePriority {
                        if Appodeal.isReadyForShowWithStyle(s) {
                            Appodeal.showAd(s, rootViewController: self)
                        }
                    }
                }
            })
        }
    }
    
    func getPieceCenterForCurrentPage(gamePiecePattern: GamePiecePattern) -> CGPoint {
        guard let index = currentPage.indexOf(gamePiecePattern) else { fatalError("Attempting to find a center to a piece in the current page, where not found in the current page") }
        return CGPointMake(self.piecesSliderView.bounds.width*(3+5*CGFloat(index))/16, self.piecesSliderView.center.y)
    }
    
    @IBAction func shareButtonPressed(sender: AnyObject) {
        let imageToShare = UIView.captureScreen(self.view)
        // TODO: fix the link
        let textToShare = "So addicting.\n\nDownload!\nhttp://mylink.com/eEoDks123" // TODO: randomize the text
        let activityItems: [AnyObject] = [textToShare, imageToShare]
        let activity = UIActivity()
        activity.prepareWithActivityItems([UIActivityTypeMessage, UIActivityTypePostToTwitter, UIActivityTypePostToFacebook, UIActivityTypeSaveToCameraRoll])
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: [activity])
        activityVC.excludedActivityTypes = [UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypeAddToReadingList, UIActivityTypeOpenInIBooks, UIActivityTypeAirDrop, UIActivityTypePrint]
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func resetButtonPressed(sender: AnyObject) {
        
        GameManager.sharedManager.trackSessionNotFinished()
        
        // animate each seperately on screen at x points: 3/16 | 8/16 | 13/16, but plus 16 for each numerator because we are animating them offscreen
        var i: CGFloat = 0 // index
//        var j: CGFloat = 3 // x delta
        for piece in currentPage {
            UIView.animateWithDuration(0.35, delay: 0.07*Double(CGFloat(currentPage.count)-i), usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: .CurveEaseInOut, animations: {
                piece.center = self.getPieceCenterForCurrentPage(piece)
                }, completion: { (finished) in
                    piece.removeFromSuperview()
            })
            
            i += 1
//            j += 5
        }
        
        currentPage.removeAll()
        
        delay(0.5) {
            GameManager.sharedManager.trackSessionStart()
            self.view.userInteractionEnabled = true // enable interaction
            self.fillPage()
        }
        
        gameBoardView.resetBoard()
    }
    
    @IBAction func undoButtonPressed(sender: AnyObject) {
        
        
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
            
            // generate a dummy piecePattern that will describe what needs to be done to the current piecePattern
            let nextRotationPattern: Pattern = piecePattern.pattern.rotateBy(rotate)
            let rotatedPattern = GamePiecePatternGenerator.generatePattern(nextRotationPattern)
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
            gamePiecePattern.alpha = 0.85
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
    
    func gamePieceTouchesEnded(gamePiecePattern: GamePiecePattern, touches: Set<UITouch>?, withEvent event: UIEvent?) {
        
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
                gamePiecePattern.alpha = 1.0
                }, completion: nil)
        }
        else {
            // throw that piece back to where it belongs
            UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseInOut, animations: {
//                gamePiecePattern.center = self.patternsStartingCenters[gamePiecePattern]!
                gamePiecePattern.center = self.getPieceCenterForCurrentPage(gamePiecePattern)
                }, completion: { finished in
                    if finished {
                        self.patternsStartingCenters[gamePiecePattern] = nil
                        
                    }
            })
            
            // shink back to normal size
            UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseInOut, animations: {
                gamePiecePattern.transform = self.patternsStartingTransforms[gamePiecePattern]!
                gamePiecePattern.alpha = 1.0
                }, completion: nil)
        }
    }
}

// MARK: MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate

//extension GameViewController: MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate {
//    
//}
