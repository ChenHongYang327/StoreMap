//
//  AppDelegate.swift
//  StoreMap
//
//  Created by hank.chen on 2021/11/18.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let vc = ViewController()
        let navigationVC = UINavigationController(rootViewController: vc)
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
        window?.rootViewController = navigationVC
        
        return true
    }

    

}

