//
//  PhotoCollectionViewCell.swift
//  EmotionPhoto
//
//  Created by Maurício Marques on 5/21/18.
//  Copyright © 2018 mauricio.marques. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PhotoCollectionViewCell"
    
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.setupViewConfigurations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PhotoCollectionViewCell {
    
    func setup(withPhoto photo: UIImage) {
        self.imageView.image = photo
    }
    
}

extension PhotoCollectionViewCell {
    
    func setupViewConfigurations() {
        self.buildViewHierarchy()
        self.setupConstraints()
        self.configureViews()
    }
    
    func buildViewHierarchy() {
        self.contentView.addSubview(self.imageView)
    }
    
    func setupConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.imageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
        self.imageView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
        self.imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
    }
    
    func configureViews() {
        self.imageView.contentMode = .scaleAspectFit
    }
    
}
