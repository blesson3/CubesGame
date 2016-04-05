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
    
    private var currentPage: [GamePiecePattern] = []
    private var patternsStartingCenters: [GamePiecePattern:CGPoint] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GameSoundManager.sharedManager.initSounds()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        gameBoardView.backgroundColor = UIColor.clearColor()
        piecesSliderView.backgroundColor = UIColor.clearColor()
        
        // IDEA: when using orientation to change shape, generate the same pattern rotated the in the new direction, transform it so it looks like the old one, then transform it so it looks like its rotating
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(orientationDidChange(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    func orientationDidChange(notification: NSNotification) {
        MBLog("Orientation changed! \(notification.userInfo)")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(nextPage), userInfo: nil, repeats: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func nextPage() {
        guard currentPage.count == 0 else { MBLog("Cannot create a next page because there are still pieces on the current page"); return }
        
        // Create three new game patterns offscreen
        // Then slide them onscreen
        
        var page: [GamePiecePattern] = []
        for _ in 0...2 {
            let p = Pattern.randomPattern()
            
            let pattern = GamePiecePatternGenerator.generatePattern(p)
            pattern.touchesHandler = self
            pattern.center = CGPoint(x: -pattern.bounds.width*1.5, y: piecesSliderView.center.y)
            self.view.addSubview(pattern)
            
            page.append(pattern)
        }
        
        currentPage = page
        
        // TESTING
//        UIView.animateWithDuration(0.2, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: .CurveEaseInOut, animations: {
//            page[0].center = CGPointMake(self.piecesSliderView.bounds.width*3/16, self.piecesSliderView.center.y)
//            page[1].center = CGPointMake(self.piecesSliderView.bounds.width*8/16, self.piecesSliderView.center.y)
//            page[2].center = CGPointMake(self.piecesSliderView.bounds.width*13/16, self.piecesSliderView.center.y)
//            }, completion: { (finished) in
//        })
        
        // animate each seperately on screen at x points: 3/16 | 8/16 | 13/16
        var i: CGFloat = 0 // index
        var j: CGFloat = 3 // x delta
        for piece in page {
            UIView.animateWithDuration(0.2, delay: 0.07*Double(CGFloat(page.count)-i), usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: .CurveEaseInOut, animations: {
                piece.center = CGPointMake(self.piecesSliderView.bounds.width*j/16, self.piecesSliderView.center.y)
                }, completion: { (finished) in
            })
            
            i += 1
            j += 5
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

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
            
            // when there are no more pieces on the current page, generate a new page with a delay of 1 second
            if currentPage.count == 0 {
                nextPage()
            }
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



