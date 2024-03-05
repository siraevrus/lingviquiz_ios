//
//  SwitchTableViewCell.swift
//  LearnWords
//
//  Created by Сергей Крайнов on 19.02.2024.
//

import UIKit

enum UserDefaultsKey: String {
    case soundSwitchState
    case vibrationSwitchState
}

class SwitchTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "SwitchTableViewCell"
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()
    
    let switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    var switchValueChangedHandler: ((Bool) -> Void)?
    var userDefaultsKey: UserDefaultsKey?
    let defaults = UserDefaults.standard
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.backgroundColor = .white
        contentView.addSubview(label)
        contentView.addSubview(switchControl)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        if let key = userDefaultsKey {
            defaults.set(sender.isOn, forKey: key.rawValue)
        }
        switchValueChangedHandler?(sender.isOn)
    }
    
    func configure(for row: Int) {
        switch row {
        case 0:
            label.text = "Выключить звук"
            userDefaultsKey = .soundSwitchState
        case 1:
            label.text = "Отключить вибрацию"
            userDefaultsKey = .vibrationSwitchState
        default:
            break
        }
        
        // Загружаем предыдущее состояние свитчера из UserDefaults и устанавливаем его
        if let key = userDefaultsKey {
            switchControl.isOn = defaults.bool(forKey: key.rawValue)
        }
        
        // Устанавливаем обработчик изменения состояния свитчера
        switchControl.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
    }
}
