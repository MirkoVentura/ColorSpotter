//
//  CameraViewController.swift
//  ColorSpotter
//
//  Created by Mirko Ventura on 09/03/24.
//

import Foundation
import UIKit
import AVFoundation
import CoreGraphics


protocol CameraViewControllerDelegate: AnyObject {
    func didFinishCapturing(image: UIImage)
}

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    private var captureSession: AVCaptureSession?
    private var captureOutput: AVCapturePhotoOutput?
    weak var delegate: CameraViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        
        guard let captureSession = captureSession else { return }
        
        guard let backCamera = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            captureSession.addInput(input)
            captureOutput = AVCapturePhotoOutput()
            if let captureOutput = captureOutput {
                captureSession.addOutput(captureOutput)
                captureSession.startRunning()
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func captureImage() {
        guard let captureOutput = captureOutput else { return }
        let photoSettings = AVCapturePhotoSettings()
        captureOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(),
           let image = UIImage(data: imageData) {
            delegate?.didFinishCapturing(image: image)
        }
    }
}


extension CameraViewController {
    func findMostCommonColor(in image: UIImage, at point: CGPoint, completion: @escaping (UIColor?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let cgImage = image.cgImage,
                  let pixelData = cgImage.dataProvider?.data,
                  let pixelBuffer = CFDataGetBytePtr(pixelData) else {
                completion(nil)
                return
            }
            
            let bytesPerPixel = 4
            let pixelInfo = Int((point.y * CGFloat(cgImage.width) + point.x) * CGFloat(bytesPerPixel))
            
            let red = CGFloat(pixelBuffer[pixelInfo]) / 255.0
            let green = CGFloat(pixelBuffer[pixelInfo + 1]) / 255.0
            let blue = CGFloat(pixelBuffer[pixelInfo + 2]) / 255.0
            let alpha = CGFloat(pixelBuffer[pixelInfo + 3]) / 255.0
            
            // Create a dictionary to store counts of colors in chunks
            var colorCounts = [UIColor: Int]()
            
            // Define the chunk size (e.g., 10x10 pixels)
            let chunkSize = CGSize(width: 10, height: 10)
            
            // Iterate through pixels in the region around the target point
            let startX = max(0, Int(point.x) - Int(chunkSize.width) / 2)
            let startY = max(0, Int(point.y) - Int(chunkSize.height) / 2)
            let endX = min(cgImage.width, Int(point.x) + Int(chunkSize.width) / 2)
            let endY = min(cgImage.height, Int(point.y) + Int(chunkSize.height) / 2)
            
            for x in startX..<endX {
                for y in startY..<endY {
                    let pixelInfo = Int((y * cgImage.width + x) * bytesPerPixel)
                    
                    let r = CGFloat(pixelBuffer[pixelInfo]) / 255.0
                    let g = CGFloat(pixelBuffer[pixelInfo + 1]) / 255.0
                    let b = CGFloat(pixelBuffer[pixelInfo + 2]) / 255.0
                    let a = CGFloat(pixelBuffer[pixelInfo + 3]) / 255.0
                    
                    let color = UIColor(red: r, green: g, blue: b, alpha: a)
                    
                    // Increment count for this color in the dictionary
                    colorCounts[color, default: 0] += 1
                }
            }
            
            // Find the color with the highest count
            let mostCommonColor = colorCounts.max { $0.1 < $1.1 }?.key
            
            DispatchQueue.main.async {
                completion(mostCommonColor)
            }
        }
    }

}
