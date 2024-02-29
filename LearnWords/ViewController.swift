//
//  ViewController.swift
//  LearnWords
//
//  Created by Сергей Крайнов on 16.02.2024.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        startButton.layer.cornerRadius = 8
    }
    
    @IBAction func startbuttonTapped(_ sender: UIButton) {
        let tabBarVC = UITabBarController()
        
        let homeVC = HomeViewController()
        homeVC.title = "Home"
        let settingsVC = SettingsViewController()
        settingsVC.title = "Settings"
        
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
            appearance.configureWithOpaqueBackground()
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        
        tabBarVC.tabBar.tintColor = .black
        tabBarVC.modalPresentationStyle = .fullScreen
        
        present(tabBarVC, animated: true)
    }
}

