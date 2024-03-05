//
//  BuildManager.swift
//  LearnWords
//
//  Created by Сергей Крайнов on 04.03.2024.
//

import Foundation

final class BuildManager {
    static var appVersion: String {
        guard let infoDictionary = Bundle.main.infoDictionary,
              let appVersion = infoDictionary["CFBundleShortVersionString"] as? String else {
            fatalError("Could not retrieve app version from Info.plist")
        }
        return appVersion
    }
    
    static var buildNumber: String {
        guard let infoDictionary = Bundle.main.infoDictionary,
              let buildNumber = infoDictionary["CFBundleVersion"] as? String else {
            fatalError("Could not retrieve build number from Info.plist")
        }
        return buildNumber
    }
}
