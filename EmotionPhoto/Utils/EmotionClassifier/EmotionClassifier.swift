//
//  EmotionClassifier.swift
//  EmotionPhoto
//
//  Created by mauricio.marques on 08/05/18.
//  Copyright © 2018 mauricio.marques. All rights reserved.
//

import Foundation
import CoreML
import Vision

/// Emotions enum representation
public enum Emotion: String {
    ///
    case angry = "Angry"
    ///
    case disgust = "Disgust"
    ///
    case fear = "Fear"
    ///
    case happy = "Happy"
    ///
    case neutral = "Neutral"
    ///
    case sad = "Sad"
    ///
    case surprise = "Surprise"
    ///
    case none
    
    /// Variable that represents an emoticon unicode a enum case
    public var emoticon: String {
        switch self {
        case .angry:
            return "\u{1F621}"
        case .disgust:
            return "\u{1F616}"
        case .fear:
            return "\u{1F628}"
        case .happy:
            return "\u{1F604}"
        case .neutral:
            return "\u{1F610}"
        case .sad:
            return "\u{1F61E}"
        case .surprise:
            return "\u{1F631}"
        case .none:
            return ""
        }
    }
}

/// Class which is responsible to use the CNNEmotions model classifier to classify emotions from given images
final public class EmotionClassifier {
    
    private var model: VNCoreMLModel?
    
    /// Init method that loads the CNNEmotions model as a VNCoreMLModel
    public init() {
        do {
            self.model = try VNCoreMLModel(for: CNNEmotions().model)
        } catch {
            self.model = nil
        }
    }
    
    /// Method that effectivelly return an Emotion result given an image
    ///
    /// - Parameters:
    ///   - cgImage: CGImage instance to be used in the emotion classifier
    ///   - completion: The completion block that passes a Emotion case
    public func classify(cgImage: CGImage, completion: @escaping (Emotion) -> ()) {
        guard let model = self.model else {
            return
        }
        
        let mlRequest = VNCoreMLRequest(model: model) { (request, error) in
            if  let observations = request.results as? [VNClassificationObservation],
                let confidence = observations.first?.confidence,
                confidence >= 0.8,
                let identifier = observations.first?.identifier,
                let emotion = Emotion(rawValue: identifier) {
                completion(emotion)
            } else {
                completion(.none)
            }
        }
    
        let handler = VNImageRequestHandler(ciImage: CIImage(cgImage: cgImage))
        try? handler.perform([mlRequest])
    }
    
}
