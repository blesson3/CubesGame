//
//  GameBoardView.swift
//  CubesGame
//
//  Created by Matt B on 4/3/16.
//  Copyright © 2016 Matt Blessed. All rights reserved.
//

import Foundation
import UIKit

class GameBoardView: UIView {
    private var baseSetup: Bool = false
    
    private var blankSpaces: [CGRect] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLog("GameBoard LayoutSubviews Size: \(self.bounds)")
        if !baseSetup {
            baseSetup = true
            setSizeDefaults()
            setupBlankSquares()
        }
    }
    
    func setSizeDefaults() {
        let cushion: CGFloat = 1.5
        let pieceSize = (self.bounds.size.width-(9*CGFloat(cushion)))/10
        
        GameManager.sharedManager.globalPieceSize = pieceSize
        GameManager.sharedManager.globalPieceCushion = cushion
    }
    
    func setupBlankSquares() {
        let cushion: CGFloat = GameManager.sharedManager.globalPieceCushion
        let pieceSize = GameManager.sharedManager.globalPieceSize
        
        for _i in 0...9 {       // row
            let i = CGFloat(_i)
            for _j in 0...9 {   // column
                let j = CGFloat(_j)
                
                let piece = GamePiece()
                piece.frame.origin = CGPoint(x: (pieceSize+cushion)*j, y: (pieceSize+cushion)*i)
                self.addSubview(piece)
                
                blankSpaces.append(piece.frame)
            }
        }
    }
    
    func canPlaceGamePiecePattern(gamePiecePattern: GamePiecePattern, point: CGPoint) -> Bool {
        // TODO: implement me
        return true
    }
}