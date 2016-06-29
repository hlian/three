//
//  AppDelegate.swift
//  ThreeThings
//
//  Created by hao on 6/28/16.
//  Copyright © 2016 ThreeThings. All rights reserved.
//

import HockeySDK
import Localize_Swift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var root: Root?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        _prepareHockey()

        self.root = Root()
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

