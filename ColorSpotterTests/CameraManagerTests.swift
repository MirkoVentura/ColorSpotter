import XCTest
@testable import ColorSpotter

class CameraManagerTests: XCTestCase {

    var cameraManager: CameraManager!

    override func setUp() {
        super.setUp()
        cameraManager = CameraManager()
    }

    override func tearDown() {
        cameraManager = nil
        super.tearDown()
    }

    func testConfigureCaptureSession() {
        // Test session configuration
        cameraManager.configureCaptureSession()
        XCTAssertEqual(cameraManager.status, .configured)
        XCTAssertTrue(cameraManager.session.isRunning)
    }

    func testStartCapturing() {
        // Test starting capturing when configured
        cameraManager.status = .configured
        cameraManager.startCapturing()
        XCTAssertTrue(cameraManager.session.isRunning)

        // Test starting capturing when unconfigured or unauthorized
        cameraManager.status = .unconfigured
        cameraManager.startCapturing()
        XCTAssertTrue(cameraManager.shouldShowAlertView)

        cameraManager.status = .unauthorized
        cameraManager.startCapturing()
        XCTAssertTrue(cameraManager.shouldShowAlertView)
    }

    func testStopCapturing() {
        // Test stopping capturing
        cameraManager.status = .configured
        cameraManager.startCapturing()
        XCTAssertTrue(cameraManager.session.isRunning)

        cameraManager.stopCapturing()
        XCTAssertFalse(cameraManager.session.isRunning)
    }

    func testToggleTorch() {
        // Test toggling torch
        cameraManager.toggleTorch(tourchIsOn: true)
        XCTAssertEqual(cameraManager.flashMode, .on)

        cameraManager.toggleTorch(tourchIsOn: false)
        XCTAssertEqual(cameraManager.flashMode, .off)
    }

    // Add more test cases for other functionalities as needed...
}
