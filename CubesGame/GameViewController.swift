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
    @IBOutlet weak var piecesSliderView: PiecesSliderView!
    @IBOutlet weak var resetButton: UIButton!
    
    private var currentPage: [GamePiecePattern] = []
    private var patternsStartingCenters: [GamePiecePattern:CGPoint] = [:]
    
    private var previousOrientation: UIDeviceOrientation = .Unknown
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        gameBoardView.backgroundColor = UIColor.clearColor()
        piecesSliderView.backgroundColor = UIColor.clearColor()
        
        // Removed orientation changing from gameplay for now
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(orientationDidChange(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // delay one second, then fill page
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(fillPage), userInfo: nil, repeats: false)
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
            pattern.transform = CGAffineTransformMakeScale(0.9, 0.9)
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
    
    @IBAction func resetButtonPressed(sender: AnyObject) {
        gameBoardView.resetBoard()
        
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
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

// MARK: Orientation Handler

extension GameViewController {
    private enum OrientationRotate {
        case Left
        case Right
    }
    
    func orientationDidChange(notification: NSNotification) {
        let orientation = UIDevice.currentDevice().orientation
        
        // if it was portrait, but now it is landscape, turn the blocks
        if (previousOrientation.isPortrait && orientation.isLandscape) || (previousOrientation.isLandscape && orientation.isPortrait) {
            rotatePage(previousOrientation == .LandscapeLeft && orientation == .Portrait ? .Right : .Left)
        }
        
        previousOrientation = orientation
        MBLog("Orientation changed! \(orientation.rawValue)")
    }
    
    private func rotatePage(rotate: OrientationRotate) {
        
        var rotatedPage: [GamePiecePattern] = []
        
        for piecePattern in currentPage {
            
            // get the new rotated pattern
            // generate the pattern
            // add to view with same center
            // transform to look like original
            // animate transform for effect
            
            let nextRotation = rotate == .Right ? piecePattern.rotation.nextRight :  piecePattern.rotation.nextLeft
            let rotatedPattern = GamePiecePatternGenerator.generatePattern(piecePattern.pattern, rotate: nextRotation)
            rotatedPattern.touchesHandler = self
            rotatedPattern.center = piecePattern.center
            rotatedPattern.transform = CGAffineTransformMakeRotation(GamePiecePatternGenerator.degreesToRadians(rotate == .Right ? -90 : 90)) // artifically rotate backwards to simulate the original
            self.view.addSubview(rotatedPattern)
            
            rotatedPage.append(rotatedPattern)
            
            // remove the original
            piecePattern.removeFromSuperview()
        }
        
        currentPage.removeAll()
        currentPage.appendContentsOf(rotatedPage)
        
        UIView.animateWithDuration(0.4, animations: {
        //UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: .CurveEaseInOut, animations: {
            
            for rp in rotatedPage {
                rp.transform = CGAffineTransformIdentity
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
        let newCenter = CGPoint(x: point.x, y: point.y-80)
        
        // record initial center and transform
        patternsStartingCenters[gamePiecePattern] = gamePiecePattern.center
        
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
        let newCenter = CGPoint(x: point.x, y: point.y-80)
        
         gamePiecePattern.center = newCenter
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
        }
        
        // shink back to normal size
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseInOut, animations: {
            gamePiecePattern.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
}
