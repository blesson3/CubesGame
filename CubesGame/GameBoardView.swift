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
    
    private var boardSize: Int = 10
    
    private var board: [Int:[Int]] = [:]            // Row:[Column]
    private var boardColors: [Int:[UIColor]] = [:]  // Row:[Column(Color)]
    private var boardPieces: [[GamePiece]] = []     // boardPieces[Row][Column]
    
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
        let pieceSize = (self.bounds.size.width-(CGFloat(boardSize-1)*CGFloat(cushion)))/CGFloat(boardSize)
        
        GameManager.sharedManager.globalPieceSize = pieceSize
        GameManager.sharedManager.globalPieceCushion = cushion
    }
    
    func setupBlankSquares() {
        let cushion: CGFloat = GameManager.sharedManager.globalPieceCushion
        let pieceSize = GameManager.sharedManager.globalPieceSize
        
        for _i in 0..<boardSize {       // row
            let i = CGFloat(_i)
            board[_i] = []
            boardColors[_i] = []
            
            boardPieces.append([])
            boardPieces[_i] = []
            
            for _j in 0..<boardSize {   // column
                let j = CGFloat(_j)
                
                let piece = GamePiece()
                piece.frame.origin = CGPoint(x: (pieceSize+cushion)*j, y: (pieceSize+cushion)*i)
                self.addSubview(piece)
                
                boardPieces[_i].append(piece)
                board[_i]?.append(0)
                boardColors[_i]?.append(piece.backgroundColor!)
            }
        }
    }
}

struct GameCoordinate {
    let row: Int
    let column: Int
}

// MARK: Placing GamePiecePatterns

extension GameBoardView {
    func canPlaceGamePiecePattern(gamePiecePattern: GamePiecePattern, frameInBoard: CGRect) -> Bool {
        let initialCoord = getClosestCoords(frameInBoard)
        
        MBLog("Closest initial coord (r, c) (\(initialCoord.row), \(initialCoord.column))")
        
        // incorporate pattern
        let pattern = gamePiecePattern.pattern.rotatedEncodedPattern(gamePiecePattern.rotation)
        
        let coords = getCoordsPatternOccupies(pattern, initialCoord: initialCoord)
        
        for c in coords {
            // ensure the space is free
            guard isSpaceFree(c) else { return false }
        }
        
        // the algorithm will break if there is a space that is not free
        return true
    }
    
    func placeGamePiecePattern(gamePiecePattern: GamePiecePattern, frameInBoard: CGRect) -> CGPoint {
        let initialCoord = getClosestCoords(frameInBoard)
        
        // testing only to ensure the spaces are all free
        guard canPlaceGamePiecePattern(gamePiecePattern, frameInBoard: frameInBoard) else { fatalError("called placeGamePiece while it is found that the piece will not fit")}
        
        // incorporate pattern
        let pattern = gamePiecePattern.pattern.rotatedEncodedPattern(gamePiecePattern.rotation)
        
        let coords = getCoordsPatternOccupies(pattern, initialCoord: initialCoord)
        let piecesColor = gamePiecePattern.piecesBackgroundColor
        
        for c in coords {
            setSpaceOccupied(c)
            pseudoSetCoordColor(c, color: piecesColor)
        }
        
        let piecePlusCushion = GameManager.sharedManager.globalPieceSizePlusCushion
        
        // -2 to both of the origin points to account for the extra cushion added
        return CGPoint(x: CGFloat(initialCoord.column)*piecePlusCushion, y: CGFloat(initialCoord.row)*piecePlusCushion)//, width: gamePiecePattern.bounds.size.width, height: gamePiecePattern.bounds.size.height)
    }
    
    func getClosestCoords(rect: CGRect) -> GameCoordinate {
        // reducing frame to single piece
        let pieceSize = GameManager.sharedManager.globalPieceSize
        let pieceFrame = CGRect(x: rect.origin.x+pieceSize/2, y: rect.origin.y+pieceSize/2, width: pieceSize, height: pieceSize)
        
        // find the closest place where that piece can fit
        let piecePlusCushion = GameManager.sharedManager.globalPieceSizePlusCushion
        
        let c = Int(floor(pieceFrame.origin.x/piecePlusCushion)) // column number closest to the left
        let r = Int(floor(pieceFrame.origin.y/piecePlusCushion)) // row number closest to the top
        return GameCoordinate(row: r, column: c)
    }
    
    private func getCoordsPatternOccupies(pattern: String, initialCoord: GameCoordinate) -> [GameCoordinate] {
        var coords: [GameCoordinate] = []
        
        let columns = pattern.componentsSeparatedByString("|")
        for i in 0..<columns.count {
            let c = columns[i]
            let rs = c.characters.map { String($0) }
            for j in 0..<rs.count {
                let r = rs[j]
                if r == "1" {
                    // check the space
                    let column = i + initialCoord.column
                    let row = j + initialCoord.row
                    
                    coords.append(GameCoordinate(row: row, column: column))
                }
            }
        }
        
        return coords
    }
}

// MARK: Board Maintaining

extension GameBoardView {
    private func setSpaceOccupied(coord: GameCoordinate) {
        guard board[coord.row] != nil else { return }
        board[coord.row]![coord.column] = 1 // set occupied
    }
    
    private func isSpaceFree(coord: GameCoordinate) -> Bool {
        return getSpace(coord) == 0
    }
    
    private func isValidCoord(coord: GameCoordinate) -> Bool {
        return coord.row >= 0 && coord.row < boardSize && coord.column >= 0 && coord.column < boardSize
    }
    
    private func getSpace(coord: GameCoordinate) -> Int {
        guard isValidCoord(coord) else { return -1 }
        return board[coord.row]![coord.column]
    }
    
    private func getPiece(coord: GameCoordinate) -> GamePiece {
        return boardPieces[coord.row][coord.column]
    }
    
    func updateBoardColoring() {
        // go through every square and update its color
        for i in 0..<boardSize {
            for j in 0..<boardSize {
                getPiece(GameCoordinate(row: i, column: j)).backgroundColor = boardColors[i]![j]
            }
        }
    }
    
    private func pseudoSetCoordColor(coord: GameCoordinate, color: UIColor) {
        guard isValidCoord(coord) else { return }
        guard !isSpaceFree(coord) else { return }
        
        boardColors[coord.row]![coord.column] = color
        
        // do no update real pieces, the update board coloring function is for that
    }
}

