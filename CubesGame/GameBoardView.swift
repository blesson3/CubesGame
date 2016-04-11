//
//  GameBoardView.swift
//  CubesGame
//
//  Created by Matt B on 4/3/16.
//  Copyright © 2016 Matt Blessed. All rights reserved.
//

import Foundation
import UIKit

protocol GameBoardViewDelegate: class {
    func gameBoardDidFill()
}

class GameBoardView: UIView {
    private var baseSetup: Bool = false
    
    var boardSize: Int = 10
    var percentFilled: CGFloat {
        let numberOccupied = board.reduce(0) { $0+$1.reduce(0) { $1 == 1 ? $0+1 : $0 } }
        return CGFloat(numberOccupied)/100.0
    }
    
    private var board: [[Int]] = []            // Row:[Column]
    private var boardColors: [Int:[UIColor]] = [:]  // Row:[Column(Color)]
    private var boardPieces: [[GamePiece]] = []     // boardPieces[Row][Column]
    
    weak var delegate: GameBoardViewDelegate?
    
    private var memoisedPatterns:[String:[[String]]] = [:]
    
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
            board.append([])
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
                board[_i].append(0)
                boardColors[_i]?.append(piece.backgroundColor!)
            }
        }
    }
    
    // used for the solving view controller
    internal func getBoard() -> [[Int]] {
        return board
    }
}

// MARK: Patterns Suggestions Delegate

extension GameBoardView {
//    func getSuggestedPatterns() -> [Pattern] {
//        
//        // first, solve the board for any one solution
//        var solutions: [[GameCoordinate : [Pattern]]] = []
//        GameBoardSolver.solve(board, allSolutions: false, _currentSolution: [:], runningSolutions: &solutions, currentCoord: GameCoordinate(row: 0, column: 0))
//        
//        // then iterate through the first solution to get all of the patterns
//        guard solutions.count > 0 else { fatalError("Solver could not solve board") }
//        var suggestedPatterns: [Pattern] = []
//        for (_, patterns) in solutions[0] {
//            suggestedPatterns.appendContentsOf(patterns)
//        }
//        return suggestedPatterns
//    }
    
    func solutionExistsWithPatterns(patterns: [Pattern]) -> Bool {
        return GameBoardSolver.canPlaceAtLeastOnePattern(board, patterns: patterns)
    }
}

func ==(lhs: GameCoordinate, rhs: GameCoordinate) -> Bool {
    return lhs.row == rhs.row && lhs.column == rhs.column
}

struct GameCoordinate: Hashable, Equatable {
    let row: Int
    let column: Int
    
    var hashValue: Int {
        var hash = 0
        hash = ((row >> 16) ^ row) * 0x45d9f3b
        hash = ((row >> 16) ^ row) * 0x45d9f3b
        hash = ((row >> 16) ^ row)
        return hash+column
    }
}

// MARK: Placing GamePiecePatterns

extension GameBoardView {
    func canPlaceGamePiecePattern(gamePiecePattern: GamePiecePattern, frameInBoard: CGRect) -> Bool {
        let initialCoord = getClosestCoords(frameInBoard)
        
//        MBLog("Closest initial coord (r, c) (\(initialCoord.row), \(initialCoord.column))")
        
        // incorporate pattern
        let pattern = gamePiecePattern.pattern.encoding
        
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
        guard canPlaceGamePiecePattern(gamePiecePattern, frameInBoard: frameInBoard) else { fatalError("called placeGamePiece while it is found that the piece will not fit") }
        
        // incorporate pattern
        let encoding = gamePiecePattern.pattern.encoding
        
        let coords = getCoordsPatternOccupies(encoding, initialCoord: initialCoord)
        let piecesColor = gamePiecePattern.piecesBackgroundColor
        
        for c in coords {
            setSpaceOccupied(c)
            pseudoSetCoordColor(c, color: piecesColor)
        }
        
        // check if the board is full
        if isBoardFull() {
            delegate?.gameBoardDidFill()
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
        
        let rows: [[String]]
        
        if memoisedPatterns[pattern] == nil {
            let columns = pattern.componentsSeparatedByString("|")
            rows = columns.map { $0.characters.map { String($0) } }
        }
        else {
            rows = memoisedPatterns[pattern]!
        }
        
        for i in 0..<rows.count {
            let rs = rows[i]
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
    
    func resetBoard(animation: Bool = true) {
        for i in 0..<boardSize {
            for j in 0..<boardSize {
                let c = GameCoordinate(row: i, column: j)
                let p = getPiece(c)
                if animation {
                    UIView.animateWithDuration(0.2, delay: Double(i+j)*0.06, options: .CurveEaseInOut, animations: {
                        p.backgroundColor = GamePiece.defaultBackgroundColor
                        }, completion: { (finished) in
                    })
                } else {
                    p.backgroundColor = GamePiece.defaultBackgroundColor
                }
                
                setSpaceFree(c)
                pseudoSetCoordColor(c, color: GamePiece.defaultBackgroundColor)
            }
        }
    }
    
    private func setSpaceOccupied(coord: GameCoordinate) {
        guard isValidCoord(coord) else { return }
        board[coord.row][coord.column] = 1 // set occupied
    }
    
    private func setSpaceFree(coord: GameCoordinate) {
        guard isValidCoord(coord) else { return }
        board[coord.row][coord.column] = 0 // set unoccupied
    }
    
    private func isSpaceFree(coord: GameCoordinate) -> Bool {
        return getSpace(coord) == 0
    }
    
    private func isValidCoord(coord: GameCoordinate) -> Bool {
        return coord.row >= 0 && coord.row < boardSize && coord.column >= 0 && coord.column < boardSize
    }
    
    private func getSpace(coord: GameCoordinate) -> Int {
        guard isValidCoord(coord) else { return -1 }
        return board[coord.row][coord.column]
    }
    
    private func getPiece(coord: GameCoordinate) -> GamePiece {
        return boardPieces[coord.row][coord.column]
    }
    
    private func isBoardFull() -> Bool {
        for i in 0..<boardSize {
            for j in 0..<boardSize {
                let c = GameCoordinate(row: i, column: j)
                if isSpaceFree(c) {
                    return false
                }
            }
        }
        return true
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
        
        boardColors[coord.row]![coord.column] = color
        
        // do no update real pieces, the update board coloring function is for that
    }
}

