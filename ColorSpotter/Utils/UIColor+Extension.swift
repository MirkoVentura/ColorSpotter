//
//  UIColor+Extension.swift
//  ColorSpotter
//
//  Created by Mirko Ventura on 09/03/24.
//

import UIKit

extension UIColor {
    func toHex() -> String {
        guard let components = cgColor.components else {
            return ""
        }
        
        let red = Int(components[0] * 255.0)
        let green = Int(components[1] * 255.0)
        let blue = Int(components[2] * 255.0)
        
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}
