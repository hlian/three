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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
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
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.backgroundColor = UIColor.whiteColor()
        self.window!.rootViewController = root!.vc
        self.window!.makeKeyAndVisible()
        return true
    }

    func _prepareHockey() {
        let hockey = BITHockeyManager.sharedHockeyManager()
        hockey.configureWithIdentifier("404e7e5c96cd4d02a5a7a82e600fc48c")
        hockey.crashManager.crashManagerStatus = BITCrashManagerStatus.AutoSend
        hockey.startManager()
        hockey.authenticator.authenticateInstallation()
    }
}

