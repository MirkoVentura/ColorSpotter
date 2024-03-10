import XCTest
import AVFoundation
import Combine
@testable import ColorSpotter

class CameraViewModelTests: XCTestCase {

    var cameraViewModel: CameraViewModel<CameraManagerMock>!

    override func setUpWithError() throws {
        cameraViewModel = CameraViewModel(cameraManager: CameraManagerMock())
    }

    override func tearDownWithError() throws {
        cameraViewModel = nil
    }

    func testInitialValues() {
        XCTAssertFalse(cameraViewModel.isFlashOn)
        XCTAssertFalse(cameraViewModel.showAlertError)
        XCTAssertFalse(cameraViewModel.showSettingAlert)
        XCTAssertFalse(cameraViewModel.isPermissionGranted)
        XCTAssertNil(cameraViewModel.mostCommonColor)
        XCTAssertNil(cameraViewModel.colorEx)
        XCTAssertNil(cameraViewModel.colorName)
        XCTAssertFalse(cameraViewModel.isLoading)
    }

    func testSwitchCamera() {
        let initialPosition = cameraViewModel.cameraManager.position
        cameraViewModel.switchCamera()
        XCTAssertNotEqual(initialPosition, cameraViewModel.cameraManager.position)
    }

    func testSwitchFlash() {
        let initialFlashState = cameraViewModel.isFlashOn
        cameraViewModel.switchFlash()
        XCTAssertNotEqual(initialFlashState, cameraViewModel.isFlashOn)
    }

    func testRequestCameraPermission() {
        let expectation = self.expectation(description: "Permission granted")

        cameraViewModel.requestCameraPermission()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertTrue(self.cameraViewModel.isPermissionGranted)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testCaptureImage() {
        let expectation = self.expectation(description: "Image captured")

        cameraViewModel.captureImage()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertTrue(self.cameraViewModel.isLoading)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testGetColorNameWithNilColorEx() {
        cameraViewModel.colorEx = nil
        cameraViewModel.getColorName()

        XCTAssertNil(cameraViewModel.colorName)
        XCTAssertFalse(cameraViewModel.isLoading)
    }
    
    func testGetColorNameWithFailedRequest() {
       
        cameraViewModel.colorEx = "#FFFFFF"
        
        let mockAPIService = MockAPIService()
        mockAPIService.shouldFailRequest = true
        
        cameraViewModel.apiService = mockAPIService
        
        // Crea un'expectation
        let expectation = XCTestExpectation(description: "Aspetta la fine della richiesta")
        
        // Modifica il mockAPIService o il ViewModel per chiamare fulfill sull'expectation quando la richiesta è completata.
        // Ad esempio, se hai un completion handler nel tuo ViewModel o servizio, puoi fare qualcosa del genere:
        mockAPIService.completion = {
            expectation.fulfill() // Segnala che l'operazione asincrona è completa
        }
        
        // Effettua la chiamata asincrona
        cameraViewModel.getColorName()
        
        // Aspetta che l'expectation sia soddisfatta, con un timeout.
        wait(for: [expectation], timeout: 5.0)
        
        // Esegui le asserzioni dopo che la chiamata asincrona è completata
        XCTAssertNil(cameraViewModel.colorName)
        XCTAssertFalse(cameraViewModel.isLoading)
    }
    func testStoreLastColorWhenColorAlreadyExists() {
        let existingColor = ColorData(hex: .init(value: "#FFFFFF", clean: "FFFFFF"), name: .init(value: "white", closestNamedHex: "#FFF", exactMatchName: true, distance: 0))
        cameraViewModel.lastAcquiredColor = existingColor
        cameraViewModel.storeLastColor()

        XCTAssertTrue(cameraViewModel.showAlertError)
        XCTAssertEqual(cameraViewModel.alertError.message, "Item already in list")
    }
}


