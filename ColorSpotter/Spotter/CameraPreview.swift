//
//  CameraPreview.swift
//  ColorSpotter
//
//  Created by Mirko Ventura on 09/03/24.
//

import UIKit
import SwiftUI

struct CameraPreview: UIViewControllerRepresentable {
    @Binding var lastAcquiredColor: Color
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(lastAcquiredColor: $lastAcquiredColor)
    }
    
    class Coordinator: NSObject, CameraViewControllerDelegate {
        @Binding var lastAcquiredColor: Color
        
        init(lastAcquiredColor: Binding<Color>) {
            _lastAcquiredColor = lastAcquiredColor
        }
        
        func didFinishCapturing(image: UIImage) {
            NotificationCenter.default.post(name: .imageCaptureFinished, object: nil, userInfo: ["image": image])
        }
    }
}

