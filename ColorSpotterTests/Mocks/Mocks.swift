//
//  Mocks.swift
//  ColorSpotterTests
//
//  Created by Mirko Ventura on 10/03/24.
//

import Foundation
import AVFoundation
import Combine
@testable import ColorSpotter
import UIKit

class MockAPIService: ApiServiceProtocol {
    var shouldFailRequest = false
    var completion: (() -> Void)?

    func fetchData(from url: URL) -> AnyPublisher<Data, Error> {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.completion?()
        }
        if shouldFailRequest {
            // Simulazione di un errore durante la richiesta
            return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
        } else {
            let existingColor = ColorData(hex: .init(value: "#FFFFFF", clean: "FFFFFF"), name: .init(value: "white", closestNamedHex: "#FFF", exactMatchName: true, distance: 0))
            // Simulazione del recupero dei dati con successo
            if let encoded = try? JSONEncoder().encode(existingColor) {
                return Just(encoded).setFailureType(to: Error.self).eraseToAnyPublisher()
            } else {
                return Just(Data()).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
                
        }
    }
}


class CameraManagerMock: CameraManaging {
    
    @Published var capturedImage: UIImage? = nil
    @Published var flashMode: AVCaptureDevice.FlashMode = .off
    @Published var status = Status.unconfigured
    @Published var shouldShowAlertView = false
    var position: AVCaptureDevice.Position = .back
    var alertError: AlertError = AlertError()
    var session: AVCaptureSession = .init()
    
    var positionHasChanged: Bool = false
    var torchIsTogled: Bool = false

    func configureCaptureSession() {
        status = .configured
    }

    func startCapturing() {
        // Simula l'avvio della cattura
    }

    func stopCapturing() {
        // Simula la fermata della cattura
    }

    func toggleTorch(tourchIsOn: Bool) {
        // Simula l'attivazione del torch
        self.flashMode = tourchIsOn ? .on : .off
    }

    func switchCamera() {
        // Simula il cambio della camera
        positionHasChanged = true
    }

    func captureImage() {
        // Simula la cattura di un'immagine
        self.capturedImage = UIImage() // Restituisce un'immagine vuota o un'immagine mock
    }
}


class ItemManagerMock: ItemManageble {
    private var memoryItems: [ColorData]  = [.init(hex: .init(value: "#FFFFFF", clean: "#FFF"), name: .init(value: "White", closestNamedHex: "#FFF", exactMatchName: true, distance: 0))]
    
    func loadItems() -> [ColorSpotter.ColorData] {
        return memoryItems
    }
    
    func saveItems(items: [ColorSpotter.ColorData]) {
        items.forEach { color in
            if !self.memoryItems.contains(where: {$0.name.value == color.name.value}) {
                self.memoryItems.append(color)
            }
        }
    }
    
    
}
