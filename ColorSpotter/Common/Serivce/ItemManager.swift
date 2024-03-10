//
//  ItemManager.swift
//  ColorSpotter
//
//  Created by Mirko Ventura on 10/03/24.
//

import Foundation

class ItemManager {
    func loadItems() -> [ColorData] {
        if let data = UserDefaults.standard.data(forKey: "items") {
            do {
                let items : [ColorData] = try JSONDecoder().decode([ColorData].self, from: data)
                return items
            } catch {
                print("Error on decoding data:", error)
            }
        } else {
            print("no values for key 'items'")
        }
        
        return []
    }
    
    func saveItems(items: [ColorData]) {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "items")
        }
    }
}
