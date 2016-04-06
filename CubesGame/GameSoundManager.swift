//
//  GameSoundManager.swift
//  CubesGame
//
//  Created by Matt B on 4/4/16.
//  Copyright © 2016 Matt Blessed. All rights reserved.
//

import Foundation
import AVFoundation

class GameSoundManager {
    static let sharedManager = GameSoundManager()
    
    let audioPlayer1 = try! AVAudioPlayer(contentsOfURL: NSURL(string: NSBundle.mainBundle().resourcePath!+"/pop1.aiff")!)
    let audioPlayer2 = try! AVAudioPlayer(contentsOfURL: NSURL(string: NSBundle.mainBundle().resourcePath!+"/pop2.aiff")!)
    let audioPlayer3 = try! AVAudioPlayer(contentsOfURL: NSURL(string: NSBundle.mainBundle().resourcePath!+"/pop3.aiff")!)
    
    var soundEffectVariations: [AVAudioPlayer] = []
    
    func initSounds() {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            MBLog("AVAudioSession failed to properly init", .FatalError)
        }
        
        
        soundEffectVariations = [audioPlayer1, audioPlayer2, audioPlayer3]
        
        audioPlayer1.prepareToPlay()
        audioPlayer2.prepareToPlay()
        audioPlayer3.prepareToPlay()
    }
    
    func playRandomPlacementSound() {
        let random = Int.random(0...2)
        soundEffectVariations[random].play()
    }
}