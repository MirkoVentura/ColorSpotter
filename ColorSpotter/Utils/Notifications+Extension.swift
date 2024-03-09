//
//  Notifications+Extension.swift
//  ColorSpotter
//
//  Created by Mirko Ventura on 09/03/24.
//

import Foundation
extension Notification.Name {
    static let imageCaptureFinished = Notification.Name("ImageCaptureFinished")
    static let startImageCapture = Notification.Name("StartImageCapture")
    static let stopImageCapture = Notification.Name("StopImageCapture")
}
