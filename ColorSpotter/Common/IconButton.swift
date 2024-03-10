//
//  IconButton.swift
//  ColorSpotter
//
//  Created by Mirko Ventura on 09/03/24.
//

import SwiftUI

struct IconButton: View {
    var systemName: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .foregroundColor(Color.gray.opacity(0.2))
                .frame(width: 45, height: 45, alignment: .center)
                .overlay(
                    Image(systemName: systemName)
                        .foregroundColor(.white))
        }
    }
}

#Preview {
    IconButton(systemName: "camera.rotate.fill") {}
}
