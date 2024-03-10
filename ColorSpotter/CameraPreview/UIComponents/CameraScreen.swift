//
//  CameraScreen.swift
//  ColorSpotter
//
//  Created by Mirko Ventura on 09/03/24.
//

import SwiftUI

struct CameraScreen: View {
    @ObservedObject var viewModel = CameraViewModel()
    @State private var navigateToNewView = false

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 0) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.blue)
                                    .frame(width: 100, height: 100, alignment: .leading)
                            } else {
                                Rectangle()
                                    .fill(Color(uiColor: viewModel.mostCommonColor ?? .green))
                                    .frame(width: 100, height: 100, alignment: .leading)
                            }
                            
                            VStack (alignment: .leading) {
                                Text(viewModel.colorName ?? "Color Name").bold()
                                if viewModel.isLoading {
                                    HStack {
                                        Text("Loading ...")
                                        ProgressView()
                                    }
                                } else {
                                    Text(viewModel.colorEx ?? "")
                                }
                            }
                            
                            VStack(alignment: .trailing) {
                                Button(action: {
                                    viewModel.storeLastColor()
                                }) {
                                    Text("Save color")
                                }
                                Button(action: {
                                    navigateToNewView = true
                                }) {
                                    Text("Go to List")
                                }
                            }.frame(maxWidth: .infinity)

                        }
                        .padding(8)
                        .frame(maxWidth: .infinity, maxHeight: 120, alignment: .leading)
                        
                        ZStack {
                            CameraPreview(session: viewModel.session)
                            
                            VisualEffectView(effect: UIBlurEffect(style: .regular))
                                .ignoresSafeArea()
                            
                            // Circle with clear background
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 300, height: 300)
                                .overlay(
                                    Circle()
                                        .fill(Color.white.opacity(0.5))
                                        .frame(width: 150, height: 150)
                                )
                                .blendMode(.destinationOut)
                                .alert(isPresented: $viewModel.showAlertError) {
                                    Alert(title: Text(viewModel.alertError.title), message: Text(viewModel.alertError.message), dismissButton: .default(Text(viewModel.alertError.primaryButtonTitle), action: {
                                        viewModel.alertError.primaryAction?()
                                    }))
                                }
                                .alert(isPresented: $viewModel.showSettingAlert) {
                                    Alert(title: Text("Warning"), message: Text("Application doesn't have all permissions to use camera and microphone, please change privacy settings."), dismissButton: .default(Text("Go to settings"), action: {
                                        self.openSettings()
                                    }))
                                }
                        }
                        
                        HStack {
                            IconButton(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash.fill") {
                                viewModel.switchFlash()
                            }
                            
                            IconButton(systemName: "camera.rotate.fill") { viewModel.switchCamera() }
                            
                            // Aggiungi il bottone di cattura e l'azione associata
                            Button(action: {
                                viewModel.captureImage()
                            }) {
                                Text("Start Acquiring")
                            }
                            .disabled(viewModel.isLoading)
                            .padding(20)
                        }
                        .padding(20)
                        
                    }
                }
                
                .onAppear {
                    viewModel.requestCameraPermission()
                }
                // Use NavigationLink with a boolean binding to control navigation
                .background(
                                   NavigationLink("", destination: ColorListView(), isActive: $navigateToNewView)
                                       .opacity(0)
                               )
            }
        }
    }
    

    func openSettings() {
        let settingsUrl = URL(string: UIApplication.openSettingsURLString)
        if let url = settingsUrl {
            UIApplication.shared.open(url, options: [:])
        }
    }
}

struct CameraScreen_Previews: PreviewProvider {
    static var previews: some View {
        CameraScreen()
    }
}
