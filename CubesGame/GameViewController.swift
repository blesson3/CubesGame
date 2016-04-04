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
        
        // animate each seperately on screen
        var i: CGFloat = 0
        for piece in page {
            UIView.animateWithDuration(0.2, delay: 0.07*Double(CGFloat(page.count)-i), usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: .CurveEaseInOut, animations: {
                piece.center = CGPointMake(self.piecesSliderView.bounds.width*(i+1)/4, self.piecesSliderView.center.y)
                }, completion: { (finished) in
            })
            
            i += 1
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
        
        // record initial center
        patternsStartingCenters[gamePiecePattern] = gamePiecePattern.center
        
        // animate larger
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseInOut, animations: {
            gamePiecePattern.transform = CGAffineTransformMakeScale(1.2, 1.2)
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
        if gamePiecePattern.frame.intersects(gameBoardView.frame) && gameBoardView.canPlaceGamePiecePattern(gamePiecePattern, point: self.view.convertRect(gamePiecePattern.frame, toView: gameBoardView).origin) {
            // pattern was placed onto game board
            
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



