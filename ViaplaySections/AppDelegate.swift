//
//  AppDelegate.swift
//  ViaplaySections
//
//  Created by Miriam Tisander on 2025-04-09.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        updateTabBarTitleFont()
        updateNavigationTitleFont()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contentSizeCategoryChanged),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
        return true
    }
    
    @objc private func contentSizeCategoryChanged(notification: Notification) {
        updateTabBarTitleFont()
        updateNavigationTitleFont()
    }
    
    private func updateNavigationTitleFont() {
        let dynamicFont = UIFont.preferredFont(forTextStyle: .headline)
        UINavigationBar.appearance().titleTextAttributes = [.font: dynamicFont]
    }
    
    private func updateTabBarTitleFont() {
        let dynamicFont = UIFont.preferredFont(forTextStyle: .caption1)
        let attributes: [NSAttributedString.Key: Any] = [.font: dynamicFont]
        
        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .selected)
    }

}

