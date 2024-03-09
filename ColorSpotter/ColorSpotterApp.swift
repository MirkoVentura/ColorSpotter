//
//  ColorSpotterApp.swift
//  ColorSpotter
//
//  Created by Mirko Ventura on 08/03/24.
//

import SwiftUI

@main
struct ColorSpotterApp: App {
    var body: some Scene {
        WindowGroup {
            CameraView(
                viewModel: .init(
                    lastAcquiredColor: .constant(.clear),
                    mostCommonColor: .constant(.clear)
                )
            )
        }
    }
}
