//
//  SettingsViewController.swift
//  LearnWords
//
//  Created by Сергей Крайнов on 16.02.2024.
//

import UIKit

class SettingsViewController: UIViewController {
    let madeInLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Сделано в onza.me"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    let versionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "version"
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .black.withAlphaComponent(0.35)
        return label
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let sections = ["Основные", "Дополнительно"]
    let mainItems = ["Выключить звук", "Отключить вибрацию"]
    let additionalItems = ["Обратная связь", "Помощь", "О приложении", "Сбросить прогресс"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupTableView()
        
        versionLabel.text = "Версия \(BuildManager.appVersion)"
    }
    
    private func showDeleteAlertWithConfirmation() {
        let alertController = UIAlertController(title: "Вы уверены что хотите сбросить прогресс?", message: nil, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Да", style: .default) { (_) in
            PlistManager.shared.deleteAllPlists()
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (_) in
            print("Вы нажали 'Отмена'")
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.reuseIdentifier)
        tableView.register(TextTableViewCell.self, forCellReuseIdentifier: TextTableViewCell.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.isScrollEnabled = false
        
        view.addSubview(tableView)
        view.addSubview(madeInLabel)
        view.addSubview(versionLabel)
        
        NSLayoutConstraint.activate([
            versionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            versionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            
            madeInLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            madeInLabel.bottomAnchor.constraint(equalTo: versionLabel.topAnchor, constant: -10),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: madeInLabel.topAnchor, constant: -10),
        ])
    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return mainItems.count
        } else {
            return additionalItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.reuseIdentifier, for: indexPath) as! SwitchTableViewCell
            cell.configure(for: indexPath.row)
            cell.selectionStyle = .none
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: TextTableViewCell.reuseIdentifier, for: indexPath) as! TextTableViewCell
            cell.configure(for: indexPath.row)
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear // Цвет фона заголовка
        
        let label = UILabel()
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        label.textColor = .black // Цвет текста заголовка
        label.font = UIFont.boldSystemFont(ofSize: 28) // Настройте шрифт по вашему желанию
        label.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            tableView.deselectRow(at: indexPath, animated: false)
            let cell = tableView.cellForRow(at: indexPath)
            UIView.animate(withDuration: 0.5, animations: {
                cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.5) {
                    cell?.transform = CGAffineTransform.identity
                }
            }
            switch indexPath.row {
            case 0:
                // Handle "Обратная связь"
                print("Обратная связь")
            case 1:
                // Handle "Помощь"
                print("Помощь")
            case 2:
                if let url = URL(string: "https://LingvoQuiz@onza.me") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            case 3:
                showDeleteAlertWithConfirmation()
            default:
                break
            }
        }
    }
}
