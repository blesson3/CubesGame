//
//  UIView-Extensions.swift
//  QuickQuestion
//
//  Created by Matt B on 1/20/16.
//  Copyright © 2016 Matt Blessed. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    //    - (UIImage *) imageWithView:(UIView *)view
    //    {
    //    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    //    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    //
    //    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    //
    //    UIGraphicsEndImageContext();
    //
    //    return img;
    //    }
    
    static func imageWithView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img
    }
    
    static func captureScreen(view: UIView) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0);
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image
    }
}