//
//  UIImage+Extension.swift
//  ColorSpotter
//
//  Created by Mirko Ventura on 10/03/24.
//

import UIKit

extension UIImage {
    func croppedToSquare() -> UIImage? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        
        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
        let cropSize = min(imageSize.width, imageSize.height)
        let cropRect = CGRect(
            x: (imageSize.width - cropSize) / 2,
            y: (imageSize.height - cropSize) / 2,
            width: cropSize,
            height: cropSize
        )
        
        if let croppedCGImage = cgImage.cropping(to: cropRect) {
            return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
        }
        
        return nil
    }
    
    func croppedToCircle() -> UIImage? {
            guard let cgImage = self.cgImage else {
                return nil
            }
            
            let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
            let minDimension = min(imageSize.width, imageSize.height)
            let circleDiameter = min(minDimension, 300) // Diametro del cerchio
            let circleRadius = circleDiameter / 2 // Raggio del cerchio
            let circleCenter = CGPoint(x: imageSize.width / 2, y: imageSize.height / 2) // Centro del cerchio
            
            UIGraphicsBeginImageContextWithOptions(CGSize(width: circleDiameter, height: circleDiameter), false, 0.0)
            defer { UIGraphicsEndImageContext() }
            
            guard let context = UIGraphicsGetCurrentContext() else {
                return nil
            }
            
            context.saveGState()
            let clippingPath = UIBezierPath(roundedRect: CGRect(origin: .zero, size: CGSize(width: circleDiameter, height: circleDiameter)), cornerRadius: circleRadius)
            clippingPath.addClip()
            
            // Disegna l'immagine all'interno del cerchio
            let imageRect = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
            context.translateBy(x: circleRadius - circleCenter.x, y: circleRadius - circleCenter.y)
            context.draw(cgImage, in: imageRect)
            
            context.restoreGState()
            
            return UIGraphicsGetImageFromCurrentImageContext()
        }

    func pixelBuffer() -> CVPixelBuffer? {
            guard let cgImage = self.cgImage else {
                return nil
            }

            let options: [String: Any] = [
                kCVPixelBufferCGImageCompatibilityKey as String: true,
                kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
            ]

            var pixelBuffer: CVPixelBuffer?
            let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                              Int(self.size.width),
                                              Int(self.size.height),
                                              kCVPixelFormatType_32ARGB,
                                              options as CFDictionary,
                                              &pixelBuffer)

            guard let buffer = pixelBuffer, status == kCVReturnSuccess else {
                return nil
            }

            CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
            let pixelData = CVPixelBufferGetBaseAddress(buffer)

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: pixelData,
                                    width: Int(self.size.width),
                                    height: Int(self.size.height),
                                    bitsPerComponent: 8,
                                    bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                    space: colorSpace,
                                    bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

            guard let cgContext = context, let cgImageCopy = cgImage.copy() else {
                return nil
            }

            cgContext.draw(cgImageCopy, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
            CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))

            return buffer
        }
    
    func mostCommonColor() -> UIColor? {
            guard let cgImage = self.cgImage else { return nil }
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let width = cgImage.width
            let height = cgImage.height
            let bytesPerPixel = 4
            let bytesPerRow = bytesPerPixel * width
            let bitsPerComponent = 8
            let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
            
            guard let context = CGContext(data: nil,
                                          width: width,
                                          height: height,
                                          bitsPerComponent: bitsPerComponent,
                                          bytesPerRow: bytesPerRow,
                                          space: colorSpace,
                                          bitmapInfo: bitmapInfo) else {
                return nil
            }
            
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            
            guard let pixelBuffer = context.data?.assumingMemoryBound(to: UInt32.self) else { return nil }
            
            var colorCount: [UIColor: Int] = [:]
            
            for y in 0..<height {
                for x in 0..<width {
                    let offset = y * width + x
                    let color = pixelBuffer[offset]
                    let red = CGFloat((color >> 16) & 0xFF) / 255.0
                    let green = CGFloat((color >> 8) & 0xFF) / 255.0
                    let blue = CGFloat(color & 0xFF) / 255.0
                    let alpha = CGFloat((color >> 24) & 0xFF) / 255.0
                    let currentColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
                    if let count = colorCount[currentColor] {
                        colorCount[currentColor] = count + 1
                    } else {
                        colorCount[currentColor] = 1
                    }
                }
            }
            
            if let mostCommonColor = colorCount.max(by: { $0.value < $1.value })?.key {
                return mostCommonColor
            }
            
            return nil
        }
    
    func areaAvarage() -> UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }

        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]), let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])

        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: CIFormat.RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: 1.0)
    }
}


