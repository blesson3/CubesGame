//
//  GameManager.swift
//  CubesGame
//
//  Created by Matt B on 4/3/16.
//  Copyright © 2016 Matt Blessed. All rights reserved.
//

import Foundation
import UIKit
import Fabric
import Crashlytics

class GameManager {
    static let sharedManager = GameManager()
    
    var globalPieceSizePlusCushion: CGFloat {
        return globalPieceSize+globalPieceCushion
    }
    
    var globalPieceSize: CGFloat = 0.0
    var globalPieceCushion: CGFloat = 0.0
    
    // if this is changed from (3), the algorithm for piece placement within the slide needs changing
    var sliderPageSize: Int = 3
    
    private var sessionStartDate: NSDate = NSDate()
    
    func trackSessionStart() {
        sessionStartDate = NSDate()
    }
    
    func trackSessionWin() {
        let interval = NSDate().timeIntervalSinceDate(sessionStartDate)
        Answers.logCustomEventWithName("SessionWon", customAttributes: ["TimeInSession":interval])
    }
    
    func trackSessionLose() {
        let interval = NSDate().timeIntervalSinceDate(sessionStartDate)
        Answers.logCustomEventWithName("SessionLost", customAttributes: ["TimeInSession":interval])
    }
    
    func trackSessionNotFinished() {
        let interval = NSDate().timeIntervalSinceDate(sessionStartDate)
        if interval > 3 {
            Answers.logCustomEventWithName("UnfinishedSession", customAttributes: ["TimeInSession":interval])
        }
    }
}

// Global helper function

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}