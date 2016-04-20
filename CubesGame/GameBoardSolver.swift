//
//  BoardSolver.swift
//  CubesGame
//
//  Created by Matt B on 4/6/16.
//  Copyright © 2016 Matt Blessed. All rights reserved.
//

import Foundation

class GameBoardSolver {
    
    static var solutions: [[GameCoordinate:PatternOptions]] = []
    
    private static var memoisedPatterns:[String:[[String]]] = [:]
    
    // Given a board, solves for every possible set of valid patterns
    // Gives an array of solutions that once applied to the board, work
    static func solve(_board: [[Int]], allSolutions: Bool, _currentSolution: [GameCoordinate:[Pattern]], inout runningSolutions: [[GameCoordinate:[Pattern]]], currentCoord: GameCoordinate) { // -> [[GameCoordinate:Pattern]]
        
        var board = _board
        var currentSolution = _currentSolution
        
        let allValidPatterns: [Pattern] = getAllValidPatterns().shuffle() // shuffle so single isnt always first
        
        if isSpaceFree(board, coord: currentCoord) {
            // try all of the possible patterns, for every pattern that fits, attempt to solve that board
            
            // placablePatterns
            var placablePatterns: [(pattern: Pattern, coords: [GameCoordinate])] = []
            
            for pattern in allValidPatterns {
                var patternCanFit = true
                let patternCoords = getCoordsPatternOccupies(board, encoding: pattern.encoding, initialCoord: currentCoord)
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
                    placablePatterns.append((pattern: pattern, coords: patternCoords))
                    
                    if !allSolutions { // if we only want one solution, one block is fine
                        break
                    }
                    
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
                
                if placablePatterns.count > 1 && allSolutions {
                    // more than one placable patterns
                    // place first in solution and spin off placablePatterns.count-1 more solving threads
                    
                    placablePatterns.removeFirst()
                    
                    for placablePattern in placablePatterns {
                        var alternativeBoard = board // will copy
                        var alterativeCurrentSolution = currentSolution
                        
                        // add to alternative current solution
                        if alterativeCurrentSolution[currentCoord] != nil {
                            alterativeCurrentSolution[currentCoord]?.append(placablePattern.pattern)
                        }
                        else {
                            alterativeCurrentSolution[currentCoord] = [placablePattern.pattern]
                        }
                        
                        for c in placablePattern.coords {
                            setSpaceOccupied(&alternativeBoard, coord: c)
                        }
                        
                        // recursively call more solving funcs with the alternative board
                        solve(alternativeBoard, allSolutions: true, _currentSolution: alterativeCurrentSolution, runningSolutions: &runningSolutions, currentCoord: currentCoord) // will attempt to increment the current coord
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
        
        // check if the current coord is free, is so then solve for the same coord
        // if not, then increment and go from there
        if isSpaceFree(board, coord: currentCoord) {
            solve(board, allSolutions: allSolutions, _currentSolution: currentSolution, runningSolutions: &runningSolutions, currentCoord: currentCoord)
        }
        else {
            // attempt to increment the currentCoord since the currentCoord spot is filled
            let nextCoord = incrementGameCoordinate(board, coord: currentCoord)
            if let nc = nextCoord {
                solve(board, allSolutions: allSolutions, _currentSolution: currentSolution, runningSolutions: &runningSolutions, currentCoord: nc)
            }
            else {
                // reached the end of the board, add my currentSolution to my solutions and return everything
                runningSolutions.append(currentSolution)
            }
        }
    }
    
    // useful for determining when no more moves are possible, ending the game
    static func canPlaceAtLeastOnePattern(board: [[Int]], patterns: [Pattern], rotationEnabled: Bool) -> Bool {
        NSLog("Starting can place at least one pattern")
        // basically meaning, can I place any one piece onto the board
        for p in patterns {
            if isPatternPlacable(board, pattern: p, rotationEnabled: rotationEnabled) {
                NSLog("Ending can place at least one pattern - true")
                return true
            }
        }
        NSLog("Starting can place at least one pattern - false")
        return false
    }
    
    static private func isPatternPlacable(board: [[Int]], pattern: Pattern, rotationEnabled: Bool) -> Bool {
        
        // all rotated encodings of that pattern
        var allEncodingsForPattern: Set<String> = []
        if rotationEnabled {
            for r in PatternRotateOptions.allRotateOptions() {
                allEncodingsForPattern.insert(pattern.rotateBy(r).encoding)
            }
        }
        else {
            allEncodingsForPattern.insert(pattern.patternOption.rotatedEncodedPattern(pattern.rotate))
        }
        
        
        var placable: Bool = true
        
        for i in 0..<board.count {
            for j in 0..<board.count {
                for e in allEncodingsForPattern {
                    placable = true
                    let coords = getCoordsPatternOccupies(board, encoding: e, initialCoord: GameCoordinate(row: i, column: j))
                    for c in coords {
                        if !isSpaceFree(board, coord: c) {
                            placable = false
                            break
                        }
                    }
                    // if at least one encoding is placable, continue
                    if placable {
                        return true
                    }
                }
            }
        }
        return false
    }
}

// MARK: Helpers

extension GameBoardSolver {
    private static func getCoordsPatternOccupies(board: [[Int]], encoding: String, initialCoord: GameCoordinate) -> [GameCoordinate] {
        var coords: [GameCoordinate] = []
        
        let rows: [[String]]
        
        if memoisedPatterns[encoding] == nil {
            let columns = encoding.componentsSeparatedByString("|")
            rows = columns.map { $0.characters.map { String($0) } }
        }
        else {
            rows = memoisedPatterns[encoding]!
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
    
    // returns the [pattern:encoding]
    private static func getAllValidPatterns() -> [Pattern] {
        // returns all of the unique patterns with all of the rotates
        var patterns: [Pattern] = []
        var encodings: Set<String> = []
        for p in PatternOptions.allPatternOptions() {
            for r in PatternRotateOptions.allRotateOptions() {
                let p = Pattern(patternOption: p, rotate: r)
                if encodings.indexOf(p.encoding) == nil {
                    // we dont have this encoding yet
                    patterns.append(p)
                    encodings.insert(p.encoding)
                }
            }
        }
        return patterns
    }
}



