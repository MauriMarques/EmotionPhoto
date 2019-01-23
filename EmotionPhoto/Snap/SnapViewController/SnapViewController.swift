//
//  SnapViewController.swift
//  EmotionPhoto
//
//  Created by mauricio.marques on 26/04/18.
//  Copyright © 2018 mauricio.marques. All rights reserved.
//

import UIKit
import Vision
import VideoToolbox

class SnapViewController: UIViewController {

    private let snapHandler = AVSnapHandler()
    private let faceDetector = FaceDetector()
    private let emotionClassifier = EmotionClassifier()
    private var picturesTaken = 0
    private var hasHappyFacesOnLoop = false
    private var isTakingPicture = false
    private var pictures = [UIImage]()
    private var emotions = [Emotion]()
    
    private lazy var doneButton = { () -> UIButton in
        let bt = UIButton(type: .system)
        bt.setTitle("OK", for: .normal)
        bt.setTitleColor(.gray, for: .normal)
        bt.addTarget(self, action: #selector(didTapDoneButton), for: UIControl.Event.touchUpInside)
        bt.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        return bt
    }()
    
    private lazy var emoticonLabel = { () -> UILabel in
        let lb = UILabel()
        lb.textAlignment = .center
        return lb
    }()
    
}

extension SnapViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSnap()
        self.setupFaceDetector()
        self.setupDoneButton()
        self.setupEmoticonLabel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.snapHandler.stopCaptureSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.snapHandler.resumeCaptureSession()
    }
    
}

extension SnapViewController {
    
    @objc private func didTapDoneButton() {
        let photosCollectionViewController = PhotosCollectionViewController(photos: self.pictures)
        self.navigationController?.pushViewController(photosCollectionViewController, animated: true)
    }
    
}

extension SnapViewController {
    
    private func setupSnap() {
        self.snapHandler.delegate = self
        self.snapHandler.setupCaptureSession(forView: self.view)
    }
    
    private func setupFaceDetector() {
        self.faceDetector.delegate = self
    }
    
    private func setupDoneButton() {
        self.view.addSubview(self.doneButton)
        self.doneButton.translatesAutoresizingMaskIntoConstraints = false
        self.doneButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -32).isActive = true
        self.doneButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -32).isActive = true
        self.doneButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        self.doneButton.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        self.doneButton.layer.cornerRadius = 50.0 / 2
        self.doneButton.clipsToBounds = true
    }
    
    private func setupEmoticonLabel() {
        self.view.addSubview(self.emoticonLabel)
        self.emoticonLabel.translatesAutoresizingMaskIntoConstraints = false
        self.emoticonLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.emoticonLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 200).isActive = true
        self.emoticonLabel.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
        self.emoticonLabel.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
    }
    
}

extension SnapViewController: AVSnapHandlerDelegate {
    
    func didReceiveImageOutput(_ imageOutput: CIImage) {
        if !self.isTakingPicture {
            self.faceDetector.detectFaceOn(imageOutput)
        }
    }
    
}

extension SnapViewController: FaceDetectorDelegate {
    func didStartDetectingFaces() {
        self.hasHappyFacesOnLoop = true
        self.emotions.removeAll()
    }
    
    func didDetectFaceWithResult(_ faceResult: FaceDetectionResult) {
        switch faceResult {
        case .success(let faceImage):
            self.classifyImage(faceImage)
        case .error:
            self.hasHappyFacesOnLoop = false
        }
    }
    
    func didFinishDetectingFacesOnImage(_ image: CGImage, observationsCount: Int) {
        if self.hasHappyFacesOnLoop {
            DispatchQueue.main.async {
                self.picturesTaken += 1
                let observationString = observationsCount > 1 ? "\(observationsCount) people" : "1 person"
                print("take picture n-\(self.picturesTaken) with \(observationString)")
                self.takePicture(image)
                self.hasHappyFacesOnLoop = false
            }
        } else {
            print("Don`t take, they are angry")
            self.hasHappyFacesOnLoop = false
        }
        
        DispatchQueue.main.async {
            var string = ""
            for emotion in self.emotions {
                string.append(emotion.emoticon)
                string.append(" ")
            }
            
            self.emoticonLabel.text = string
        }
    }
}

extension SnapViewController {
    
    private func classifyImage(_ faceImage: CGImage) {
        self.emotionClassifier.classify(cgImage: faceImage, completion: { emotion in
            self.emotions.append(emotion)
            switch emotion {
            case .happy:
                return
            default:
                self.hasHappyFacesOnLoop = false
            }
        })
    }
    
}

extension SnapViewController {
    
    private func takePicture(_ cgImage: CGImage) {
        self.isTakingPicture = true
        
        self.pictures.append(UIImage(cgImage: cgImage))
        
        self.presentFlashWithFinishAction {
            self.isTakingPicture = false
        }
    }
    
    private func presentFlashWithFinishAction(_ finishAction: @escaping () -> ()) {
        let flashView = UIView()
        flashView.backgroundColor = UIColor.white.withAlphaComponent(1.0)
        flashView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(flashView)
        
        flashView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        flashView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        flashView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        flashView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        UIView.animate(withDuration: 0.6, animations: {
            flashView.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        }) { (value) in
            flashView.removeFromSuperview()
            finishAction()
        }
    }
    
}
