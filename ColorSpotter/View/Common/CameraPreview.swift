//
//  CameraPreview.swift
//  ColorSpotter
//
//  Created by Mirko Ventura on 09/03/24.
//

import SwiftUI
import AVFoundation // To access the camera related swift classes and methods
import Photos

struct CameraPreview: UIViewRepresentable { // for attaching AVCaptureVideoPreviewLayer to SwiftUI View
    
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.backgroundColor = .black
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspect
        view.videoPreviewLayer.connection?.videoOrientation = .portrait
        

        return view
    }
    
    public func updateUIView(_ uiView: VideoPreviewView, context: Context) { }
    
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
             AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
}
