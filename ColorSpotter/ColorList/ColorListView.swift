//
//  ColorListView.swift
//  ColorSpotter
//
//  Created by Mirko Ventura on 10/03/24.
//

import SwiftUI

struct ColorListView: View {
    @StateObject private var viewModel = ColorListViewModel()
        
        var body: some View {

                VStack {
                    List {
                        ForEach(viewModel.items) { item in
                            HStack {
                                VStack {
                                    Text(item.name.value)
                                    Text(item.hex.value)
                                }
                                Rectangle()
                                    .fill(Color(hex: item.hex.value))
                            }.contextMenu {
                                    Button(action: {
                                        viewModel.deleteItem(item)
                                    }) {
                                        Text("Delete")
                                        Image(systemName: "trash")
                                    }
                                }
                        }
                        .onDelete(perform: viewModel.deleteItems)
                    }
                }
                .onAppear() {
                    viewModel.loadItems()
                }
                .navigationBarTitle("List of Items")
                .navigationBarItems(trailing:
                    Button(action: {
                    // Add a new item to the list
                    // Toggle the sort order
                    viewModel.isAscendingOrder.toggle()
                    // Sort the items based on the current sort order
                    viewModel.sortItems()
                    }) {
                        Image(systemName: viewModel.isAscendingOrder ? "arrow.up" : "arrow.down")
                    }
                )
        }
}

#Preview {
    ColorListView()
}
