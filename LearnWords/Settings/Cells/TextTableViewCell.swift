//
//  TextTableViewCell.swift
//  LearnWords
//
//  Created by Сергей Крайнов on 19.02.2024.
//

import UIKit

class TextTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "TextTableViewCell"
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Сброс цвета лейбла перед повторным использованием ячейки
        label.textColor = .black
    }
    
    func configure(for row: Int) {
        switch row {
        case 0:
            label.text = "Обратная связь"
        case 1:
            label.text = "Помощь"
        case 2:
            label.text = "О приложении"
        case 3:
            label.text = "Сбросить прогресс"
        default:
            break
        }
    }
    
    func configure(with word: WordModel) {
        label.text = word.word
        if word.know == false {
            label.textColor = UIColor(red: 65/255, green: 165/255, blue: 238/255, alpha: 1)
        }
    }
}
