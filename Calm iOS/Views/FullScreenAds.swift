//
//  FullScreenAds.swift
//  Calmish
//
//  Created by Apps4World on 9/18/20.
//  Copyright © 2020 Apps4World. All rights reserved.
//

import Foundation
import Apps4World
import GoogleMobileAds

// MARK: - Google AdMob Interstitial - Support class
class Interstitial: NSObject, GADInterstitialDelegate{
    var interstitial = GADInterstitial(adUnitID: AppConfig.adMobAdID)
    
    /// Default initializer of interstitial class
    override init() {
        super.init()
        loadInterstitial()
    }
    
    /// Request AdMob Interstitial ads
    func loadInterstitial() {
        self.interstitial.load(GADRequest())
        self.interstitial.delegate = self
    }
    
    func showInterstitialAds() {
        if self.interstitial.isReady && !PKManager.shared.isPremiumUser {
            let root = UIApplication.shared.windows.first?.rootViewController
            guard let controller = root?.presentedViewController else {
                return
            }
            self.interstitial.present(fromRootViewController: controller)
        }
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        self.interstitial = GADInterstitial(adUnitID: AppConfig.adMobAdID)
        loadInterstitial()
    }
}
