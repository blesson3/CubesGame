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
    private var patternStartingTransforms: [GamePiecePattern:CGAffineTransform] = [:]
    
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
        patternStartingTransforms[gamePiecePattern] = gamePiecePattern.transform
        
        // animate larger
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseInOut, animations: {
            gamePiecePattern.transform = CGAffineTransformConcat(gamePiecePattern.transform, CGAffineTransformMakeScale(1.1, 1.1))
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
            
            // remove pattern from current page
            currentPage.removeAtIndex(currentPage.indexOf(gamePiecePattern)!)
            
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
            gamePiecePattern.transform = self.patternStartingTransforms[gamePiecePattern]!
            }, completion: nil)
        
        
    }
}



