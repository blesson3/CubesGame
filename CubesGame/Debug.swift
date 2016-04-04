//  Created by Matt B on 5/27/15.

// This file contains flags to debugging followed by the
//  rest of the application.

import Foundation

enum Priority: Int {
    case Verbose = 0
    case VerboseColorful
    case VerboseColorful2
    case VerboseError
    case FatalError
}

// Custom Color Logging.

private let ESCAPE = "\u{001b}["

private let RESET_FG = ESCAPE + "fg;" // Clear any foreground color
private let RESET_BG = ESCAPE + "bg;" // Clear any background color
private let RESET = ESCAPE + ";"   // Clear any foreground or background color

private struct ColorLog {
    static func red<T>(object:T) {
        print("\(ESCAPE)fg255,0,0;\(object)\(RESET)")
    }
    
    static func green<T>(object:T) {
        print("\(ESCAPE)fg0,255,0;\(object)\(RESET)")
    }
    
    static func blue<T>(object:T) {
        print("\(ESCAPE)fg0,0,255;\(object)\(RESET)")
    }
    
    static func yellow<T>(object:T) {
        print("\(ESCAPE)fg255,255,0;\(object)\(RESET)")
    }
    
    static func purple<T>(object:T) {
        print("\(ESCAPE)fg255,0,255;\(object)\(RESET)")
    }
    
    static func cyan<T>(object:T) {
        print("\(ESCAPE)fg0,255,255;\(object)\(RESET)")
    }
}

// MARK: error logging

// Creating DateFormatters are expensive, so keep one around
private let dateFormatter = NSDateFormatter()

// Custom logging function
func MBLog(message: String, _ priority: Priority = .Verbose, file f: String = #file, function: String = #function, lineNum: Int = #line) {
    
    // log formatting
    func formatDate(date: NSDate) -> String {
        if dateFormatter.dateFormat != "yyyy-MM-dd HH:mm:ss.SSS" {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            dateFormatter.timeZone = NSTimeZone.systemTimeZone()
            dateFormatter.locale = NSLocale.currentLocale()
            dateFormatter.formatterBehavior = .BehaviorDefault
        }
        return dateFormatter.stringFromDate(date)
    }
    
    if Debug.DEBUG_LOGS {
        var file = f.componentsSeparatedByString("/").last!
        file = file.componentsSeparatedByString(".").first!
        file = colorString(file, color: RGBColor(red: 0, green: 183, blue: 53))
        
        let stringDate: String = formatDate(NSDate()) // YYYY-MM-DD hh:mm:ss.SSS
        let preMessage = colorString("\(stringDate) QuickQuestion[", color: RGBColor(red: 0, green: 125, blue: 53))+"\(file)"+colorString(" \(function)]: \(lineNum): ", color: RGBColor(red: 0, green: 125, blue: 53))
        
        switch priority {
        case .Verbose:
            print(preMessage+message) // black or default
        case .VerboseColorful:
            print(preMessage+colorString(message, color: RGBColor(red: 128, green: 255, blue: 0))) // blue
        case .VerboseColorful2:
            print(preMessage+colorString(message, color: RGBColor(red: 128, green: 0, blue: 255))) // purple
        case .VerboseError:
            print(preMessage+colorString(message, color: RGBColor(red: 255, green: 255, blue: 0))) // yellow
        case .FatalError:
            print(preMessage+colorString(message, color: RGBColor(red: 255, green: 0, blue: 0))) // red
        }
    }
}

private struct RGBColor {
    let red: Int
    let green: Int
    let blue: Int
}

private func colorString(message: String, color: RGBColor) -> String {
    return ESCAPE+"fg\(color.red),\(color.green),\(color.blue);"+message+RESET
}

@objc class Debug: NSObject {
    static let DEBUG_LOGS = true
    
    static func enableColorLogging() {
        setenv("XcodeColors", "YES", 0) // enables XCODE COLORS
    }
}


