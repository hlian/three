//
//  AppDelegate.swift
//  ThreeThings
//
//  Created by hao on 6/28/16.
//  Copyright © 2016 ThreeThings. All rights reserved.
//

import HockeySDK
import Localize_Swift
import SQLite
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var root: Root?
    var facts: Facts?
    var db: Connection?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        _prepareHockey()

        do {
            self.db = try connect()
        } catch {
            fatalError("unable to connect to database: \(error)")
        }

        do {
            self.facts = try Facts(db: db!)
        } catch {
            fatalError("unable to set up facts: \(error)")
        }

        self.root = Root(db: db)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.backgroundColor = UIColor.white
        self.window!.rootViewController = root!.vc
        self.window!.makeKeyAndVisible()
        return true
    }

    func _prepareHockey() {
        let hockey = BITHockeyManager.shared()
        hockey.configure(withIdentifier: "404e7e5c96cd4d02a5a7a82e600fc48c")
        hockey.crashManager.crashManagerStatus = BITCrashManagerStatus.autoSend
        hockey.start()
        hockey.authenticator.authenticateInstallation()
    }
}

