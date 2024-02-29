//
//  HomeCollectionViewCell.swift
//  LearnWords
//
//  Created by Сергей Крайнов on 19.02.2024.
//

import UIKit

enum DictionaryType {
    case englishWords
    case russianWords
}

class HomeCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "HomeCell"
    
    var dictionaryType: DictionaryType?
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        contentView.backgroundColor = .clear
        
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            imageView.widthAnchor.constraint(equalToConstant: 58),
            imageView.heightAnchor.constraint(equalToConstant: 38),
            
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
        ])
    }
    
    func setupDesign(for dictionaryType: DictionaryType) {
        switch dictionaryType {
        case .englishWords:
            imageView.image = UIImage(named: "us-flag")
            label.text = "Русско - английские слова"
        case .russianWords:
            imageView.image = UIImage(named: "rus-flag")
            label.text = "Англо - русские слова"
        }
    }
}
