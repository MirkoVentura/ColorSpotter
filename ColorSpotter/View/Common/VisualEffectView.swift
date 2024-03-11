//
//  VisualEffectView.swift
//  ColorSpotter
//
//  Created by Mirko Ventura on 09/03/24.
//

import SwiftUI


struct VisualEffectView: UIViewRepresentable {
    let effect: UIVisualEffect
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: effect)
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}
