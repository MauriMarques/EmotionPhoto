//
//  AVSnapHandler.swift
//  EmotionPhoto
//
//  Created by mauricio.marques on 26/04/18.
//  Copyright © 2018 mauricio.marques. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

/// AVSnapHandler delegate to informe about the image to be outputed
public protocol AVSnapHandlerDelegate: class {
    /// method that informs the delegate when a image is received from the camera
    func didReceiveImageOutput(_ imageOutput: CIImage)
}

/// Class which is responsible of dealing with the AVFoundation API and capture images from the device camera
final public class AVSnapHandler: NSObject {
    
    /// AVSnapHandlerDelegate instace
    public weak var delegate: AVSnapHandlerDelegate?
    private var captureSession: AVCaptureSession?
}

public extension AVSnapHandler {
    
    /// Method for seting up a view to be used to display the images captured in the session
    ///
    /// - Parameter view: View to be used to display the images captured in the session
    public func setupCaptureSession(forView view: UIView) {
        let captureSession = AVCaptureSession()
        
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType:AVMediaType.video, position: .front).devices
        
        do {
            if let captureDevice = availableDevices.first {
                captureSession.addInput(try AVCaptureDeviceInput(device: captureDevice))
            }
        } catch {
            print(error.localizedDescription)
        }
        
        let captureOutput = AVCaptureVideoDataOutput()
        captureSession.addOutput(captureOutput)
        
        captureOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
        self.captureSession = captureSession
    }
    
    
    /// Method to stop the captured session run
    public func stopCaptureSession() {
        self.captureSession?.stopRunning()
    }
    
    /// Method to start the captured session run
    public func resumeCaptureSession() {
        self.captureSession?.startRunning()
    }
}

extension AVSnapHandler: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    /// :nodoc:
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(sampleBuffer)
        let ciImage = CIImage(cvImageBuffer: pixelBuffer!)
        
        //leftMirrored for front camera
        let ciImageWithOrientation = ciImage.oriented(forExifOrientation: Int32(UIImage.Orientation.leftMirrored.rawValue))
        
        self.delegate?.didReceiveImageOutput(ciImageWithOrientation)
    }
    
}
