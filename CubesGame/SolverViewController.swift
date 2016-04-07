//
//  SolverViewController.swift
//  CubesGame
//
//  Created by Matt B on 4/7/16.
//  Copyright © 2016 Matt Blessed. All rights reserved.
//

import Foundation

class SolverViewController: UIViewController {
    
    @IBOutlet weak var sizeInput: UITextField!
    @IBOutlet weak var numberOfSolutionsLabel: UILabel!
    @IBOutlet weak var solutionNumberLabel: UILabel!
    
    @IBOutlet weak var gameBoardView: GameBoardView!
    
    private var solvingSize: Int? {
        if let t = sizeInput.text {
            return Int(t)
        }
        return nil
    }
    
    private var solutions: [[GameCoordinate : [Pattern]]] = []
    private var solutionsBoard: [[Int]] = [] // Row:[Column]
    private var showingSolutions: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        sizeInput.text = "\(gameBoardView.boardSize)"
        
        gameBoardView.backgroundColor = UIColor.clearColor()
    }
    
    @IBAction func solveButtonPressed(sender: AnyObject) {
        guard let s = solvingSize else { showAlert(title: "Error", message: "Solving size must be a number"); return }
        
        // end editing -- for keyboard to be dismissed
        self.view.endEditing(true)
        
        let currentBoard = gameBoardView.getBoard()
        
        // create board, with existing black or other pieces
        solutionsBoard = []
        for i in 0..<s {
            solutionsBoard.append([])
            solutionsBoard[i] = []
            for j in 0..<s {
                solutionsBoard[i].append(currentBoard[i][j]) //
            }
        }
        
        let board = solutionsBoard // just so theres no chance that the board will be modified
        solutions = []
        GameBoardSolver.solve(board, _currentSolution: [:], runningSolutions: &solutions, currentCoord: GameCoordinate(row: 0, column: 0))
        
        numberOfSolutionsLabel.text = "Solutions: \(solutions.count)"
        
        if solutions.count == 0 {
            gameBoardView.resetBoard()
            showingSolutions = 0
            showAlert(title: "Error", message: "No solutions could be found for this size")
        }
        else {
            // emulate the nextSolutionPressedButton because its easier
            showingSolutions = -1
            nextSolutionPressed(self)
        }
    }
    
    @IBAction func nextSolutionPressed(sender: AnyObject) {
        if showingSolutions+1 < solutions.count {
            showingSolutions += 1
            showSolution(showingSolutions)
        }
        else {
            MBLog("No more next solutions")
        }
    }
    
    @IBAction func previousSolutionPressed(sender: AnyObject) {
        if showingSolutions-1 >= 0 {
            showingSolutions -= 1
            showSolution(showingSolutions)
        }
        else {
            MBLog("No more previous solutions")
        }
    }
    
    @IBAction func resetBoardPressed(sender: AnyObject) {
        gameBoardView.resetBoard()
        solutions = []
        solutionNumberLabel.text = "Solution #0"
        numberOfSolutionsLabel.text = "Solutions: 0"
    }
    
    private func showSolution(i: Int) {
        // it is the programmers responsibility to ensure this is called for a valid i in the `solutions` array
        // 0..inf
        
        gameBoardView.resetBoard()
        
        let pieceCushionSize = GameManager.sharedManager.globalPieceSizePlusCushion
        
        for i in 0..<solutionsBoard.count {
            for j in 0..<solutionsBoard.count {
                if solutionsBoard[i][j] == 1 {
                    let piecePattern = GamePiecePatternGenerator.generatePattern(.Single, rotate: .None)
                    piecePattern.setPiecesBackgroundColor(UIColor.blackColor())
                    gameBoardView.placeGamePiecePattern(piecePattern, frameInBoard: CGRect(origin: CGPoint(x: pieceCushionSize*CGFloat(j)+(pieceCushionSize/2), y: pieceCushionSize*CGFloat(i)+(pieceCushionSize/2)), size: piecePattern.bounds.size))
                }
            }
        }
        
        for (coord, patterns) in solutions[i] {
            // the algorithm ensures that the none of the patterns placed on this coordinate are conflicting
            for p in patterns {
                let piecePattern = GamePiecePatternGenerator.generatePattern(p, rotate: .None)
                gameBoardView.placeGamePiecePattern(piecePattern, frameInBoard: CGRect(origin: CGPoint(x: pieceCushionSize*CGFloat(coord.column)+(pieceCushionSize/2), y: pieceCushionSize*CGFloat(coord.row)+(pieceCushionSize/2)), size: piecePattern.bounds.size))
            }
        }
        
        gameBoardView.updateBoardColoring()
        
        solutionNumberLabel.text = "Solution #\(i+1)"
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        let t = touches.first!
        
        // ensure the touch intersections the gameBoardView
        let pointInGameBoard = t.locationInView(gameBoardView)
        let pieceRect = CGRect(origin: CGPoint(x: pointInGameBoard.x-GameManager.sharedManager.globalPieceSizePlusCushion/2, y:pointInGameBoard.y-GameManager.sharedManager.globalPieceSizePlusCushion/2), size: CGSizeMake(GameManager.sharedManager.globalPieceSizePlusCushion, GameManager.sharedManager.globalPieceSizePlusCushion))
        guard gameBoardView.canPlaceGamePiecePattern(GamePiecePatternGenerator.generatePattern(.Single, rotate: .None), frameInBoard: pieceRect) else { return }
        
        if solutions.count > 0 {
            solutions = []
            gameBoardView.resetBoard()
        }
        
        // place a single black piece wherever the user touches
        let piecePattern = GamePiecePatternGenerator.generatePattern(.Single, rotate: .None)
        piecePattern.setPiecesBackgroundColor(UIColor.blackColor())
        gameBoardView.placeGamePiecePattern(piecePattern, frameInBoard: pieceRect)
        gameBoardView.updateBoardColoring()
        
    }
}
















