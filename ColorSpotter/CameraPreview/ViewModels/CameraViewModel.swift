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
    
    @Published var mostCommonColor: UIColor?
    @Published var colorEx: String?
    @Published var colorName: String?
    @Published var isLoading: Bool = false
    
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
        
        cameraManager.$capturedImage
            .sink { [weak self] image in
            self?.mostCommonColor = image?.areaAvarage()
            self?.colorEx = self?.mostCommonColor?.toHex()
            self?.isLoading = false
            self?.getColorName()
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
        isLoading = true
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
    
    func getColorName() {
        let apiService = APIService()

        if let colorEx = self.colorEx {
            let exCode = colorEx.replacingOccurrences(of: "#", with: "")
            self.isLoading = true
            if let url = URL(string: "https://www.thecolorapi.com/id?hex=\(exCode)") {
                print(url)
                apiService.fetchData(from: url)
                    .receive(on: DispatchQueue.main)
                    .flatMap { data -> AnyPublisher<ColorData, Error> in
                        do {
                            let colorData = try JSONDecoder().decode(ColorData.self, from: data)
                            return Just(colorData)
                                .setFailureType(to: Error.self)
                                .eraseToAnyPublisher()
                        } catch {
                            return Fail(error: error).eraseToAnyPublisher()
                        }
                    }
                    .sink(receiveCompletion: { completion in
                        self.isLoading = false
                        switch completion {
                        case .finished:
                            print("Richiesta completata con successo")
                        case .failure(let error):
                            print("Errore durante la richiesta: \(error)")
                        }
                    }, receiveValue: { colorData in
                        print("ColorData decodificato: \(colorData)")
                        self.colorName = colorData.name.value
                        // Utilizza il ColorData decodificato qui
                    })
                    .store(in: &cancelables)
            }
        }
    }
}
