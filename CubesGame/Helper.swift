//
//  Helper.swift
//  CubesGame
//
//  Created by Matt B on 4/6/16.
//  Copyright © 2016 Matt Blessed. All rights reserved.
//

import Foundation
import UIKit

// Convenience
func displayError(msg: String) {
    MBLog("Global displayed error: "+msg)
    
    showAlert(title: "Error", message: msg, style: .Alert, buttons: [(title: "Close", style: .Cancel)]) { (title) -> () in
        // nothing...
    }
}

// Convenience
 func showAlert(title title: String, message msg: String) {
    showAlert(title: title, message: msg, style: .Alert, buttons: [(title: "OK", style: .Cancel)]) { (title) -> () in
        // nothing...
    }
}

 func showAlert(title title: String, message: String?, style: UIAlertControllerStyle, buttons: [(title:String, style:UIAlertActionStyle)], buttonPressed: (title: String?)->() ) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
    
    for b in buttons {
        alertController.addAction(UIAlertAction(title: b.title, style: b.style, handler: { (action) -> Void in
            buttonPressed(title: action.title)
        }))
    }
    if style == .ActionSheet {
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            // will dismiss automatically
        }))
    }
    
    alertController.show()
}

// MARK: displaying errors

 func showError(error: NSError, file: String = #file, function: String = #function, lineNum: Int = #line) {
    showError(error.localizedDescription, file: file, function: function, lineNum: lineNum)
}

 func showError(message: String, file: String = #file, function: String = #function, lineNum: Int = #line) {
    MBLog(message, file: file, function: function, lineNum: lineNum)
    showAlert(title: "Error", message: message)
}