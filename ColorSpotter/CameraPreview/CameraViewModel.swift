//
//  CameraViewModel.swift
//  ColorSpotter
//
//  Created by Mirko Ventura on 09/03/24.
//

import SwiftUI
import Combine
import Photos
import AVFoundation

class CameraViewModel: ObservableObject {
    
    @ObservedObject var cameraManager = CameraManager()
    
    @Published var isFlashOn = false
    @Published var showAlertError = false
    @Published var showSettingAlert = false
    @Published var isPermissionGranted: Bool = false
    
    @Published var capturedImage: UIImage?
    @Published var mostCommonColor: UIColor?
    @Published var colorEx: String?
    
    var alertError: AlertError!
    var session: AVCaptureSession = .init()
    private var cancelables = Set<AnyCancellable>()
    
    init() {
        session = cameraManager.session
    }
    
    deinit {
        cameraManager.stopCapturing()
    }
    
    func setupBindings() {
        cameraManager.$shouldShowAlertView.sink { [weak self] value in
            self?.alertError = self?.cameraManager.alertError
            self?.showAlertError = value
        }
        .store(in: &cancelables)
        
        cameraManager.$capturedImage.sink { [weak self] image in
            self?.capturedImage = image
            self?.mostCommonColor = image?.areaAvarage()
            self?.colorEx = self?.mostCommonColor?.toHex()
        }.store(in: &cancelables)
    }
    
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] isGranted in
            guard let self else { return }
            if isGranted {
                self.configureCamera()
                DispatchQueue.main.async {
                    self.isPermissionGranted = true
                }
            }
        }
    }
    
    func configureCamera() {
        checkForDevicePermission()
        cameraManager.configureCaptureSession()
    }
    
    func captureImage() {
        requestGalleryPermission()
          let permission = checkGalleryPermissionStatus()
          if permission.rawValue != 2 {
            cameraManager.captureImage()
          }
    }
    
    // Ask for the permission for photo library access
    func requestGalleryPermission() {
       PHPhotoLibrary.requestAuthorization { status in
         switch status {
         case .authorized:
            break
         case .denied:
            self.showSettingAlert = true
         default:
            break
         }
       }
    }
    
    func checkForDevicePermission() {
        let videoStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        DispatchQueue.main.async { [weak self] in
            if videoStatus == .authorized {
                self?.isPermissionGranted = true
            } else if videoStatus == .notDetermined {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { _ in })
            } else if videoStatus == .denied {
                self?.isPermissionGranted = false
                self?.showSettingAlert = true
            }
        }
    }
    
    func switchCamera() {
        cameraManager.position = cameraManager.position == .back ? .front : .back
        cameraManager.switchCamera()
    }
    
    func switchFlash() {
        isFlashOn.toggle()
        cameraManager.toggleTorch(tourchIsOn: isFlashOn)
    }

    func checkGalleryPermissionStatus() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }
    
    func findMostCommonColor(in image: UIImage, at point: CGPoint, completion: @escaping (UIColor?) -> Void) {
        
        DispatchQueue.global(qos: .background).async {
            
            guard let cgImage = image.cgImage,
                let pixelData = cgImage.dataProvider?.data,
                let pixelBuffer = CFDataGetBytePtr(pixelData) else {
                    completion(nil)
                    return
            }
            
            let bytesPerPixel = 4
           
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
