//
//  CameraViewModel.swift
//  ColorSpotter
//
//  Created by Mirko Ventura on 09/03/24.
//

import Foundation
import SwiftUI
import AVFoundation

// ViewModel
class CameraViewModel: ObservableObject {
    @Binding var lastAcquiredColor: Color
    @Binding var mostCommonColor: Color
    @Published var isAcquiringColor = false
    @Published var cameraAuthorizationGranted = AVCaptureDevice.authorizationStatus(for: .video) == .authorized

    
    init(lastAcquiredColor: Binding<Color>, mostCommonColor: Binding<Color>) {
           _lastAcquiredColor = lastAcquiredColor
           _mostCommonColor = mostCommonColor
       }
    
    func startColorAcquisition() {
        isAcquiringColor = true
    }
    
    func stopColorAcquisition() {
        isAcquiringColor = false
    }
    
    func processCapturedImage(image: UIImage) {
        // Your color analysis logic here
        // Sample color from the center of the target hole area
        let targetPoint = CGPoint(x: image.size.width / 2, y: image.size.height / 2)
        CameraViewController().findMostCommonColor(in: image, at: targetPoint) { color in
            if let color = color {
                self.lastAcquiredColor = Color(color)
                self.mostCommonColor = Color(color)
            }
        }
    }
    
    func requestCameraPermission() {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.cameraAuthorizationGranted = granted
                }
            }
        }
}
