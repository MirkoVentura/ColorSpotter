//
//  ColorListViewModel.swift
//  ColorSpotter
//
//  Created by Mirko Ventura on 10/03/24.
//

import Foundation
class ColorListViewModel: ObservableObject {
    @Published var items: [ColorData] = []
    @Published var isAscendingOrder = true
    let itemManager = ItemManager()
    
    func loadItems() {
        self.items = itemManager.loadItems()
        sortItems()
    }
    func addItem(newItem: ColorData) {
        items.append(newItem)
        itemManager.saveItems(items: items)
    }
    
    func deleteItem(_ item: ColorData) {
        if let index = items.firstIndex(where: { $0.hex.value == item.hex.value }) {
            items.remove(at: index)
            itemManager.saveItems(items: items)
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        itemManager.saveItems(items: items)
    }
    
    
    func sortItems() {
        if isAscendingOrder {
            items.sort(by: { $0.name.value < $1.name.value })
        } else {
            items.sort(by: { $0.name.value > $1.name.value })
        }
    }
}

