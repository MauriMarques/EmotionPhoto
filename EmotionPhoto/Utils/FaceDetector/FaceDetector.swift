//
//  FaceDetector.swift
//  EmotionPhoto
//
//  Created by Maurício Marques on 5/13/18.
//  Copyright © 2018 mauricio.marques. All rights reserved.
//

import Foundation
import Vision

/// FaceDetector delegate protocol to inform about the start, detections and finish of the face detector instance
public protocol FaceDetectorDelegate: class {
    /// method that inform the delegate when the detection with Vision has started
    func didStartDetectingFaces()
    /// method that ifnorm the delegate when a face is detected
    func didDetectFaceWithResult(_ faceResult: FaceDetectionResult)
    /// method that inform the delegate when the detection with Vision has finished
    func didFinishDetectingFacesOnImage(_ image: CGImage, observationsCount: Int)
}

/// Face detection result enum
public enum FaceDetectionResult {
    /// case that represents a successful face detection, with the detection`s image as parameter
    case success(CGImage)
    /// case that represents a error while detecting some face
    case error
}

/// Class which is responsible of dealing with the Vision API and detect faces from CIImage instances
final public class FaceDetector {
    
    /// FaceDetectorDelegate instace
    public weak var delegate: FaceDetectorDelegate?
    private var currentInterval: Int = 0
    private let maxInterval: Int = 10
    
    /// Method that perform the face detection given an CIImage instance
    ///
    /// - Parameter ciImage: CIImage instance to detect faces from
    public func detectFaceOn(_ ciImage: CIImage) {
        let faceDetectionRequest = VNDetectFaceRectanglesRequest { (request, error) in
            guard let observations = request.results as? [VNFaceObservation], observations.count > 0 else {
                self.delegate?.didDetectFaceWithResult(.error)
                return
            }
            
            self.delegate?.didStartDetectingFaces()
            
            guard let cgImage = FaceDetector.convertCIImageToCGImage(ciImage) else { return }
            
            for face in observations {
                let width = face.boundingBox.width * CGFloat(cgImage.width)
                let height = face.boundingBox.height * CGFloat(cgImage.height)
                let x = face.boundingBox.origin.x * CGFloat(cgImage.width)
                let y = (1 - face.boundingBox.origin.y) * CGFloat(cgImage.height) - height
                
                let croppingRect = CGRect(x: x, y: y, width: width, height: height)
                if let faceImage = cgImage.cropping(to: croppingRect) {
                    self.delegate?.didDetectFaceWithResult(.success(faceImage))
                } else {
                    self.delegate?.didDetectFaceWithResult(.error)
                }
            }
            
            self.delegate?.didFinishDetectingFacesOnImage(cgImage, observationsCount: observations.count)
        }
        
        if self.currentInterval == self.maxInterval {
            try? VNImageRequestHandler(ciImage: ciImage, options: [:]).perform([faceDetectionRequest])
            self.currentInterval = 0
        } else {
            self.currentInterval += 1
        }
    }
    
    static func convertCIImageToCGImage(_ inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        return context.createCGImage(inputImage, from: inputImage.extent)
    }
}
