//
//  CameraView.swift
//  ColorSpotter
//
//  Created by Mirko Ventura on 09/03/24.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @ObservedObject var viewModel: CameraViewModel
    
    var body: some View {
        VStack {
            // Information Box
            HStack {
               Circle()
                    .stroke(Color.blue, lineWidth: 2)
                    .frame(width: 50, height: 50)
                    .background(viewModel.mostCommonColor)
                VStack {
                    Text("Color Name:")
                    Text("\(viewModel.mostCommonColor.description)")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 80)
            .border(.black)
            .padding(16)
            

            
            // Check auth status for video
            if viewModel.cameraAuthorizationGranted {
                // L'utente ha già autorizzato l'accesso alla fotocamera
                cameraPreview
            } else {
                // La richiesta di autorizzazione non è stata ancora effettuata
                Button("Request Access to Camera") {
                    viewModel.requestCameraPermission()
                }
            }
            
            // Start/Stop Button
            Button(action: {
                if viewModel.isAcquiringColor {
                    viewModel.stopColorAcquisition()
                } else {
                    viewModel.startColorAcquisition()
                }
            }) {
                Text(viewModel.isAcquiringColor ? "Stop Color Acquisition" : "Start Color Acquisition")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
    
    var cameraPreview: some View {
        ZStack {
            CameraPreview(lastAcquiredColor: viewModel.$lastAcquiredColor)
                .onReceive(NotificationCenter.default.publisher(for: .imageCaptureFinished)) { notification in
                    guard let userInfo = notification.userInfo as? [String: UIImage],
                          let image = userInfo["image"] else { return }
                    self.viewModel.processCapturedImage(image: image)
                }
            Color.black.opacity(0.5)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 150, height: 150)
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


#Preview {
    CameraView(
        viewModel: .init(
            lastAcquiredColor: .constant(.clear),
            mostCommonColor: .constant(.clear)
        )
    )
}
