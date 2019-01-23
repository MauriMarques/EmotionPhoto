//
//  PhotosCollectionViewController.swift
//  EmotionPhoto
//
//  Created by Maurício Marques on 5/21/18.
//  Copyright © 2018 mauricio.marques. All rights reserved.
//

import Foundation
import UIKit

/// Photos collection view controller class
public class PhotosCollectionViewController: UIViewController {
    
    private let gridLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width/3.0, height: 150.0)
        layout.sectionInset = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0)
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 20.0
        layout.scrollDirection = .vertical
        return layout
    }()
    
    private let previewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        layout.sectionInset = .zero
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.scrollDirection = .horizontal
        return layout
    }()
    
    private let collectionView: UICollectionView
    
    private let photos: [UIImage]
    
    /// Init that receive the photos to be displayed
    ///
    /// - Parameter photos: UIImage array with the images to be displayed in the collection view
    public init(photos: [UIImage]) {
        self.photos = photos
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.gridLayout)
        super.init(nibName: nil, bundle: nil)
        self.setupViewConfigurations()
    }
    
    /// :nodoc:
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PhotosCollectionViewController {
    
    func setupViewConfigurations() {
        self.buildViewHierarchy()
        self.setupConstraints()
        self.configureViews()
    }
    
    func buildViewHierarchy() {
        self.view.addSubview(self.collectionView)
    }
    
    func setupConstraints() {
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    func configureViews() {
        self.collectionView.backgroundColor = .white
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
    }
    
}

extension PhotosCollectionViewController {

    private func setNavbarHidden(_ hidden: Bool? = nil) {
        if let hidden = hidden {
            self.navigationController?.setNavigationBarHidden(hidden, animated: true)
        } else {
            guard let isNavBarHidden = self.navigationController?.isNavigationBarHidden else { return }
            self.navigationController?.setNavigationBarHidden(!isNavBarHidden, animated: true)
        }
    }
    
}

extension PhotosCollectionViewController: UICollectionViewDataSource {
    
    /// :nodoc:
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /// :nodoc:
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    /// :nodoc:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell {
            cell.setup(withPhoto: self.photos[indexPath.item])
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
}

extension PhotosCollectionViewController: UICollectionViewDelegate {
    
    /// :nodoc:
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.collectionView.collectionViewLayout == self.gridLayout {
            self.collectionView.setCollectionViewLayout(self.previewLayout, animated: true) { (value) in
                self.collectionView.isPagingEnabled = true
                self.collectionView.backgroundColor = .black
            }
        } else {
            self.collectionView.setCollectionViewLayout(self.gridLayout, animated: true) { (value) in
                self.collectionView.isPagingEnabled = false
                self.collectionView.backgroundColor = .white
            }
        }
    }
    
}


