//
//  ColorListViewModelTests.swift
//  ColorSpotterTests
//
//  Created by Mirko Ventura on 11/03/24.
//

import Foundation
import XCTest
@testable import ColorSpotter // Importa il modulo della tua app

class ColorListViewModelTests: XCTestCase {

    var viewModel: ColorListViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = ColorListViewModel()
        viewModel.itemManager = ItemManagerMock()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // Test per verificare l'aggiunta di un nuovo elemento
    func testAddItem() {
        // Arrange
        let newItem = ColorData(hex: .init(value: "#FF0000", clean: "FF0000"), name: .init(value: "Red", closestNamedHex: "#FF0000", exactMatchName: true, distance: 0))
        
        // Act
        viewModel.addItem(newItem: newItem)
        
        // Assert
        XCTAssertEqual(viewModel.items.count, 1)
        XCTAssertEqual(viewModel.items.first?.name.value, "Red")
        XCTAssertEqual(viewModel.items.first?.hex.value, "#FF0000")
    }

    // Test per verificare la cancellazione di un elemento
    func testDeleteItem() {
        // Arrange
        let newItem = ColorData(hex: .init(value: "#FF0000", clean: "FF0000"), name: .init(value: "Red", closestNamedHex: "#FF0000", exactMatchName: true, distance: 0))
        
        // Act
        viewModel.addItem(newItem: newItem)
        
        // Act
        viewModel.deleteItem(newItem)
        
        // Assert
        XCTAssertEqual(viewModel.items.count, 0)
    }

    // Test per verificare la cancellazione di più elementi
    func testDeleteItems() {
        // Arrange
        let newItem1 = ColorData(hex: .init(value: "#FF0000", clean: "FF0000"), name: .init(value: "Red", closestNamedHex: "#FF0000", exactMatchName: true, distance: 0))
        
        let newItem2 = ColorData(hex: .init(value: "#0000FF", clean: "0000FF"), name: .init(value: "Blue", closestNamedHex: "#0000FF", exactMatchName: true, distance: 0))
        
        viewModel.addItem(newItem: newItem1)
        viewModel.addItem(newItem: newItem2)
        
        // Act
        viewModel.deleteItems(at: IndexSet([0, 1]))
        
        // Assert
        XCTAssertTrue(viewModel.items.isEmpty)
    }

    // Test per verificare l'ordinamento degli elementi in ordine ascendente
    func testSortItemsAscending() {
        // Arrange
        let newItem1 = ColorData(hex: .init(value: "#FF0000", clean: "FF0000"), name: .init(value: "Red", closestNamedHex: "#FF0000", exactMatchName: true, distance: 0))
        
        let newItem2 = ColorData(hex: .init(value: "#0000FF", clean: "0000FF"), name: .init(value: "Blue", closestNamedHex: "#0000FF", exactMatchName: true, distance: 0))
        
        viewModel.addItem(newItem: newItem2)
        viewModel.addItem(newItem: newItem1)
        
        // Act
        viewModel.isAscendingOrder = true
        viewModel.sortItems()
        
        // Assert
        XCTAssertEqual(viewModel.items.first?.name.value, "Blue")
    }

    // Test per verificare l'ordinamento degli elementi in ordine discendente
    func testSortItemsDescending() {
        // Arrange
        let newItem1 = ColorData(hex: .init(value: "#FF0000", clean: "FF0000"), name: .init(value: "Red", closestNamedHex: "#FF0000", exactMatchName: true, distance: 0))
        
        let newItem2 = ColorData(hex: .init(value: "#0000FF", clean: "0000FF"), name: .init(value: "Blue", closestNamedHex: "#0000FF", exactMatchName: true, distance: 0))
        
        viewModel.addItem(newItem: newItem1)
        viewModel.addItem(newItem: newItem2)
        
        // Act
        viewModel.isAscendingOrder = false
        viewModel.sortItems()
        
        // Assert
        XCTAssertEqual(viewModel.items.first?.name.value, "Red")
    }
}
