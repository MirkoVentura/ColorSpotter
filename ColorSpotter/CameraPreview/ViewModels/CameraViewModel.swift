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

class CameraViewModel<Manager>: ObservableObject where Manager: CameraManaging {
    @Published var cameraManager: Manager
    
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
    var lastAcquiredColor: ColorData?
    let itemManager = ItemManager()
    var apiService: ApiServiceProtocol = APIService()

    init(cameraManager: Manager) {
        self.cameraManager = cameraManager
        session = cameraManager.session
        setupBindings()
    }

    deinit {
        cameraManager.stopCapturing()
    }
    
    func setupBindings() {
        (cameraManager as? CameraManager)?.$shouldShowAlertView.sink { [weak self] value in
            self?.alertError = self?.cameraManager.alertError
            self?.showAlertError = value
        }
        .store(in: &cancelables)
        
        (cameraManager as? CameraManager)?.$capturedImage
            .sink { [weak self] image in
            self?.mostCommonColor = image?.areaAvarage()
            self?.colorEx = self?.mostCommonColor?.toHex()
            if self?.colorEx != self?.lastAcquiredColor?.hex.value {
                self?.getColorName()
            }
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
        cameraManager.captureImage()
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
    
    func getColorName() {

        if let colorEx = self.colorEx {
            let exCode = colorEx.replacingOccurrences(of: "#", with: "")
            self.isLoading = true
            if let url = URL(string: "https://www.thecolorapi.com/id?hex=\(exCode)") {
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
                        self.lastAcquiredColor = colorData
                        // Utilizza il ColorData decodificato qui
                    })
                    .store(in: &cancelables)
            }
        }
    }
    
    func storeLastColor() {
        var items: [ColorData] = itemManager.loadItems()
        if let lastColor = self.lastAcquiredColor {
            
            if items.contains(where: { $0.name.value == lastColor.name.value}) {
                self.alertError = AlertError()
                self.alertError.message = "Item already in list"
                self.showAlertError = true
                return
            }
            
            items.append(lastColor)
            itemManager.saveItems(items: items)
            
            self.alertError = AlertError()
            self.alertError.message = "Color Stored correctly"
            self.showAlertError = true
        }
    }
}
