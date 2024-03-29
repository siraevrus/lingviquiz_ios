//
//  ViewController.swift
//  LearnWords
//
//  Created by Сергей Крайнов on 16.02.2024.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        startButton.layer.cornerRadius = 8
        versionLabel.text = "Версия \(BuildManager.appVersion)"
    }
    
    @IBAction func startbuttonTapped(_ sender: UIButton) {
        let tabBarVC = UITabBarController()
        
        let homeVC = HomeViewController()
        let settingsVC = SettingsViewController()
        
        let homeNavVC = UINavigationController(rootViewController: homeVC)
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        
        tabBarVC.setViewControllers([homeNavVC, settingsNav], animated: false)
        
        guard let items = tabBarVC.tabBar.items else { return }
        
        let images = ["home-tab-image", "settings-tab-image"]
        
        for x in 0..<items.count {
            items[x].image = UIImage(named: images[x])
        }
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.backgroundColor = .white
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        
        tabBarVC.tabBar.tintColor = .black
        tabBarVC.tabBar.barTintColor = .white
        tabBarVC.modalPresentationStyle = .fullScreen
        
        present(tabBarVC, animated: true)
    }
    
    @IBAction func madeInButtonTapped(_ sender: UIButton) {
        if let url = URL(string: "https://onza.me") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

