//
//  SplashScreen.swift
//  ColorSpotter
//
//  Created by Mirko Ventura on 23/07/24.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        Color.blue
            .edgesIgnoringSafeArea(.all)
            .overlay(
                Text("Loading...")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            )
    }
}

extension AnyTransition {
    static var moveUpwards: AnyTransition {
        AnyTransition.move(edge: .top)
            .combined(with: .opacity)
    }
    
    static var moveAndFade: AnyTransition {
            let insertion = AnyTransition.opacity
            let removal = AnyTransition.move(edge: .top)
            return .asymmetric(insertion: insertion, removal: removal)
        }

        static var moveAndFadeOutOnly: AnyTransition {
            let insertion = AnyTransition.identity // no animation when entering
            let removal = AnyTransition.move(edge: .bottom)
                .combined(with: .opacity)
            return .asymmetric(insertion: insertion, removal: removal)
        }
}

struct MainSplashScreen: View {
    @State private var isLoading: Bool = true

    var body: some View {
        ZStack {
            // Main content view
            VStack {
                CameraScreenView()
            }

            // Splash screen
            if isLoading {
                SplashScreen()
                    .transition(.moveAndFade)
                    .zIndex(1) // Ensure it is on top of the main content
            }
        }
        .onAppear {
            // Simulate loading completion after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.isLoading = false
                }
            }
        }
        .animation(.easeOut(duration: 0.5), value: isLoading)
    }
}


#Preview {
    SplashScreen()
}
