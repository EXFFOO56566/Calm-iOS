//
//  AppDelegate.swift
//  Calmish
//
//  Created by Apps4World on 9/15/20.
//  Copyright © 2020 Apps4World. All rights reserved.
//

import UIKit
import AVKit
import Parse
import Apps4World
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Calmish.configure(purchaseCode: "CodeCanyon_Item_Purchase_Code")
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { print(error) }
        application.beginReceivingRemoteControlEvents()
        Parse.initialize(with: AppConfig.parseConfiguration)
        saveInstallationObject()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        PKManager.loadProducts(identifiers: [AppConfig.iAPProductID])
        return true
    }
    
    func saveInstallationObject() {
        if let installation = PFInstallation.current(){
            installation.saveInBackground { (success: Bool, error: Error?) in
                if !success {
                    if let parseError = error {
                        print(parseError.localizedDescription)
                    }else{
                        print("Uknown Parse error")
                    }
                }
            }
        }
    }

    // MARK: UISceneSession Lifecycle

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
}
