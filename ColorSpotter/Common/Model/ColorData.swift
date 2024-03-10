//
//  ColorData.swift
//  ColorSpotter
//
//  Created by Mirko Ventura on 10/03/24.
//

import Foundation

struct ColorData: Codable {
    let hex: ColorData.Hex
    let name: ColorData.Name
    // Aggiungi altre proprietà necessarie
}

extension ColorData {
    struct Hex: Codable {
        let value: String
        let clean: String
    }

    struct Name: Codable {
        let value, closestNamedHex: String
        let exactMatchName: Bool
        let distance: Int
        
        enum CodingKeys: String, CodingKey {
            case value
            case closestNamedHex = "closest_named_hex"
            case exactMatchName = "exact_match_name"
            case distance
        }
    }
}
