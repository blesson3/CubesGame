//
//  BoardSolver.swift
//  CubesGame
//
//  Created by Matt B on 4/6/16.
//  Copyright © 2016 Matt Blessed. All rights reserved.
//

import Foundation

class GameBoardSolver {
    
    static var solutions: [[GameCoordinate:Pattern]] = []
    
    // Given a board, solves for every possible set of valid patterns
    // Gives an array of solutions that once applied to the board, work
    static func solve(_board: [[Int]], _currentSolution: [GameCoordinate:[Pattern]], inout runningSolutions: [[GameCoordinate:[Pattern]]], currentCoord: GameCoordinate) { // -> [[GameCoordinate:Pattern]]
        var board = _board
        var currentSolution = _currentSolution
        
        let allValidPatterns = getAllValidPatterns()
        
        if isSpaceFree(board, coord: currentCoord) {
            // try all of the possible patterns, for every pattern that fits, attempt to solve that board
            
            // placablePatterns
            var placablePatterns: [(pattern: Pattern, coords: [GameCoordinate])] = []
            
            for p in allValidPatterns {
                var patternCanFit = true
                let patternCoords = getCoordsPatternOccupies(board, pattern: p.encodedPattern(), initialCoord: currentCoord)
                for pc in patternCoords {
                    if !isSpaceFree(board, coord: pc) {
                        patternCanFit = false
                        break // break from testing pattern coordinates
                    }
                    else {
                        // space is free
                        patternCanFit = true // TESTING: only having this statement so I can break on it
                    }
                }
                
                if patternCanFit {
                    placablePatterns.append((pattern: p, coords: patternCoords))
                }
            }
            
            if placablePatterns.count == 0 {
                // no placable patterns
                // just continue
            }
            else {
                // one or more placable pattern
                // add to solution and continue
                let pattern = placablePatterns.first!.pattern
                let occupyingCoords = placablePatterns.first!.coords
                
                if placablePatterns.count > 1 {
                    // more than one placable patterns
                    // place first in solution and spin off placablePatterns.count-1 more solving threads
                    
                    placablePatterns.removeFirst()
                    
                    for placable in placablePatterns {
                        var alternativeBoard = board // will copy
                        var alterativeCurrentSolution = currentSolution
                        
                        // add to alternative current solution
                        if alterativeCurrentSolution[currentCoord] != nil {
                            alterativeCurrentSolution[currentCoord]?.append(placable.pattern)
                        }
                        else {
                            alterativeCurrentSolution[currentCoord] = [placable.pattern]
                        }
                        
                        for c in placable.coords {
                            setSpaceOccupied(&alternativeBoard, coord: c)
                        }
                        
                        // recursively call more solving funcs with the alternative board
                        solve(alternativeBoard, _currentSolution: alterativeCurrentSolution, runningSolutions: &runningSolutions, currentCoord: currentCoord) // will attempt to increment the current coord
                    }
                }
                
                // I think that placablePatterns.count > 1 block is changing 'board' and 'currentSolution'
                
                // set that pattern as a solution to that coordinate
                if currentSolution[currentCoord] != nil {
                    currentSolution[currentCoord]?.append(pattern)
                }
                else {
                    currentSolution[currentCoord] = [pattern]
                }
                
                // set all of the spaces occupied
                for c in occupyingCoords {
                    setSpaceOccupied(&board, coord: c)
                }
            }
        }
        
        let nextCoord = incrementGameCoordinate(board, coord: currentCoord)
        if let nc = nextCoord {
            return solve(board, _currentSolution: currentSolution, runningSolutions: &runningSolutions, currentCoord: nc)
        }
        
        // reached the end of the board, add my currentSolution to my solutions and return everything
        runningSolutions.append(currentSolution)
    }
    
    
    
    private static func getCoordsPatternOccupies(board: [[Int]], pattern: String, initialCoord: GameCoordinate) -> [GameCoordinate] {
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
    
    private static func incrementGameCoordinate(board: [[Int]], coord: GameCoordinate) -> GameCoordinate? {
        var r = coord.row + 1
        var c = coord.column
        
        while (!isCoordValid(board, coord: GameCoordinate(row: r, column: c))) {
            
            r += 1
            
            if r >= board.count {
                r = 0
                c += 1
            }
            
            if c >= board.count {
                return nil
            }
        }
        
        // TODO: ensure the coordinate is incremented
        return GameCoordinate(row: r, column: c)
    }
    
    private static func isSpaceFree(board: [[Int]], coord: GameCoordinate) -> Bool {
        if isCoordValid(board, coord: coord) {
            return board[coord.row][coord.column] == 0
        }
        return false
    }
    
    private static func isCoordValid(board: [[Int]], coord: GameCoordinate) -> Bool {
        return coord.column < board.count && coord.column >= 0 && coord.row < board.count && coord.row >= 0
    }
    
    private static func setSpaceOccupied(inout board: [[Int]], coord: GameCoordinate) {
        if isCoordValid(board, coord: coord) {
            board[coord.row][coord.column] = 1
        }
    }
    
    private static func getAllValidPatterns() -> [Pattern] {
        var patterns: [Pattern] = []
        // TODO: times 4 for each orientation
        for i in 0..<Pattern.count {
            patterns.append(Pattern(rawValue: i)!)
        }
        return patterns.sort { $0.numberOfBlocksRequired() > $1.numberOfBlocksRequired() }
    }
    
}



