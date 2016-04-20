//
//  GamePiece.swift
//  CubesGame
//
//  Created by Matt B on 4/3/16.
//  Copyright © 2016 Matt Blessed. All rights reserved.
//

import Foundation
import UIKit

class GamePiece: UIView {
    
    static let defaultBackgroundColor: UIColor = UIColor(red: 79.0/255.0, green: 79.0/255.0, blue: 79.0/255.0, alpha: 1.0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    init() {
        let frame = CGRect(x: 0, y: 0, width: GameManager.sharedManager.globalPieceSize, height: GameManager.sharedManager.globalPieceSize)
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        self.userInteractionEnabled = false
        self.backgroundColor = GamePiece.defaultBackgroundColor
        self.layer.cornerRadius = 4 // 3.2
    }
}

