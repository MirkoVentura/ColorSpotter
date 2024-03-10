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
    
    static func averageColor(from pixelBuffer: CVPixelBuffer) -> UIColor? {
            CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
            defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

            guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
                return nil
            }

            let width = CVPixelBufferGetWidth(pixelBuffer)
            let height = CVPixelBufferGetHeight(pixelBuffer)
            let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)

            var sumR: UInt32 = 0
            var sumG: UInt32 = 0
            var sumB: UInt32 = 0

            for y in 0..<height {
                let row = baseAddress.advanced(by: y * bytesPerRow).assumingMemoryBound(to: UInt32.self)
                for x in 0..<width {
                    let pixel = row[x]
                    sumR += pixel & 0xff
                    sumG += (pixel >> 8) & 0xff
                    sumB += (pixel >> 16) & 0xff
                }
            }

            let totalPixels = width * height
            let averageR = CGFloat(sumR) / CGFloat(totalPixels)
            let averageG = CGFloat(sumG) / CGFloat(totalPixels)
            let averageB = CGFloat(sumB) / CGFloat(totalPixels)

            return UIColor(red: averageR / 255, green: averageG / 255, blue: averageB / 255, alpha: 1)
        }
}
