//
//  CameraManager.swift
//  ColorSpotter
//
//  Created by Mirko Ventura on 09/03/24.
//

import Photos
import SwiftUI
import AVFoundation

enum Status {
    case configured
    case unconfigured
    case unauthorized
    case failed
}

protocol CameraManaging: ObservableObject {
    var capturedImage: UIImage? { get set }
    var flashMode: AVCaptureDevice.FlashMode { get set }
    var status: Status { get set }
    var shouldShowAlertView: Bool { get set }
    var alertError: AlertError { get set }
    var position: AVCaptureDevice.Position {get set}
    var session: AVCaptureSession { get set}
    
    func configureCaptureSession()
    func startCapturing()
    func stopCapturing()
    func toggleTorch(tourchIsOn: Bool)
    func switchCamera()
    func captureImage()
}


class CameraManager: ObservableObject, CameraManaging {
    
    @Published var capturedImage: UIImage? = nil
    @Published var flashMode: AVCaptureDevice.FlashMode = .off
    
    @Published var status = Status.unconfigured
    @Published var shouldShowAlertView = false
    
    var session: AVCaptureSession = AVCaptureSession()
    let photoOutput = AVCapturePhotoOutput()
    var videoDeviceInput: AVCaptureDeviceInput?
    var position: AVCaptureDevice.Position = .back
    
    private var cameraDelegate: CameraDelegate?
    var alertError: AlertError = AlertError()
    
    // Communicate with the session and other session objects with this queue.
    private let sessionQueue = DispatchQueue(label: "com.mirkoventura.sessionQueue")
    
    func configureCaptureSession() {
        sessionQueue.async { [weak self] in
            guard let self, self.status == .unconfigured else { return }
            
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo
            
            // Add video input.
            self.setupVideoInput()
            
            // Add the photo output.
            self.setupPhotoOutput()
            
            self.session.commitConfiguration()
            self.startCapturing()
        }
    }
    
    private func setupVideoInput() {
        do {
            let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
            guard let camera else {
                print("CameraManager: Video device is unavailable.")
                status = .unconfigured
                session.commitConfiguration()
                return
            }
            
            let videoInput = try AVCaptureDeviceInput(device: camera)
            
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
                videoDeviceInput = videoInput
                status = .configured
            } else {
                print("CameraManager: Couldn't add video device input to the session.")
                status = .unconfigured
                session.commitConfiguration()
                return
            }
        } catch {
            print("CameraManager: Couldn't create video device input: \(error)")
            status = .failed
            session.commitConfiguration()
            return
        }
    }
    
    private func setupPhotoOutput() {
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            //photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.maxPhotoQualityPrioritization = .quality // work for ios 15.6 and the older versions
//            if position == .back {
//                photoOutput.maxPhotoDimensions = .init(width: 4032, height: 3024) // for ios 16.0*
//            }
            status = .configured
        } else {
            print("CameraManager: Could not add photo output to the session")
            status = .failed
            session.commitConfiguration()
            return
        }
    }
    
    func startCapturing() {
        if status == .configured {
            self.session.startRunning()
        } else if status == .unconfigured || status == .unauthorized {
            DispatchQueue.main.async {
                self.alertError = AlertError(title: "Camera Error", message: "Camera configuration failed. Either your device camera is not available or its missing permissions", primaryButtonTitle: "ok", secondaryButtonTitle: nil, primaryAction: nil, secondaryAction: nil)
                self.shouldShowAlertView = true
            }
        }
    }
    
    func stopCapturing() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    func toggleTorch(tourchIsOn: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                flashMode = tourchIsOn ? .on : .off
                if tourchIsOn {
                    try device.setTorchModeOn(level: 1.0)
                } else {
                    device.torchMode = .off
                }
                device.unlockForConfiguration()
            } catch {
                print("Failed to set torch mode: \(error).")
            }
        } else {
            print("Torch not available for this device.")
        }
    }
    
    func setFocusOnTap(devicePoint: CGPoint) {
        guard let cameraDevice = self.videoDeviceInput?.device else { return }
        do {
            try cameraDevice.lockForConfiguration()
            if cameraDevice.isFocusModeSupported(.autoFocus) {
                cameraDevice.focusMode = .autoFocus
                cameraDevice.focusPointOfInterest = devicePoint
            }
            cameraDevice.exposurePointOfInterest = devicePoint
            cameraDevice.exposureMode = .autoExpose
            cameraDevice.isSubjectAreaChangeMonitoringEnabled = true
            cameraDevice.unlockForConfiguration()
        } catch {
            print("Failed to configure focus: \(error)")
        }
    }
    
    func switchCamera() {
        guard let videoDeviceInput else { return }
        
        // Remove the current video input
        session.removeInput(videoDeviceInput)
        
        // Add the new video input
        setupVideoInput()
    }
    
    func captureImage() {
       sessionQueue.async { [weak self] in
          guard let self else { return }
      
          // Configure photo capture settings
          var photoSettings = AVCapturePhotoSettings()
      
          // Capture HEIC photos when supported
          if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
             photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
          }
      
          // Sets the flash mode for the capture
           if ((self.videoDeviceInput?.device.isFlashAvailable) != nil) {
             photoSettings.flashMode = self.flashMode
          }
           
//           if self.position == .back {
//               photoSettings.maxPhotoDimensions = (AVCaptureDevice.Format.supportedMaxPhotoDimensions
//           }
      
          // Specify photo quality and preview format
          if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
             photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
          }

          photoSettings.photoQualityPrioritization = .quality
      
          if let videoConnection = photoOutput.connection(with: .video),
             videoConnection.isVideoOrientationSupported {
             videoConnection.videoOrientation = .portrait
          }
      
          cameraDelegate = CameraDelegate { [weak self] image in
              if let imageToCrop = image {
                  self?.capturedImage = imageToCrop.croppedToCircle()
              } else {
                  self?.capturedImage = image
              }
              
          }
      
          if let cameraDelegate {
             // Capture the photo with delegate
             self.photoOutput.capturePhoto(with: photoSettings, delegate: cameraDelegate)
          }
       }
    }
}

class CameraDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    
    private let completion: (UIImage?) -> Void
    
    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            print("CameraManager: Error while capturing photo: \(error)")
            completion(nil)
            return
        }
        
        if let imageData = photo.fileDataRepresentation(), let capturedImage = UIImage(data: imageData) {
            completion(capturedImage)
        } else {
            print("CameraManager: Image not fetched.")
        }
    }

}
