//
//  AppConfig.swift
//  Calmish
//
//  Created by Apps4World on 9/15/20.
//  Copyright © 2020 Apps4World. All rights reserved.
//

import SwiftUI
import Parse
import Foundation
import Apps4World

/// Basic app configurations
class AppConfig: NSObject {

    /// This is the AdMob Interstitial ad id
    static let adMobAdID: String = "ca-app-pub-7597138854328701/5921460921"
    
    /// Number of free items for non-premium users. Number of categories and sounds to be accessed for free
    static let freeItems: (categories: Int, sounds: Int) = (3, 5)
    
    /// Support URLs
    static let contactURL: URL = URL(string: "http://apps4world.com/")!
    static let instagramURL: URL = URL(string: "https://instagram.com/instagram")!
    
    /// Generic app content
    static let pushNotification: String = "It's time to relax and meditate"
    
    /// Parse configuration
    static let parseConfiguration = ParseClientConfiguration {
        $0.applicationId = "S5xkqUjBNqEqru9rHn4xRz64ZIdsMLubozvc31gx"
        $0.clientKey = "bvGcw87G5ewHWgAOZes7pHwX7FJDHZUgrCUdPwuk"
        $0.server = "https://parseapi.back4app.com"
    }
    
    /// In-App Purchase product identifier. Must be a `Non-Consumable` product
    static let iAPProductID: String = "premium"
}

// MARK: - Default categories in case there is an issue to get database data

/// Meditation Categories
enum MeditationCategory: String, CaseIterable {
    case focus = "focus"
    case selfLove = "self love"
    case reduceStress = "reduce stress"
    case gratitude = "gratitude"
    
    var subtitle: String {
        switch self {
        case .focus:
            return "unlock your potential"
        case .selfLove:
            return "love & accept yourself"
        case .reduceStress:
            return "learn to control yourself"
        case .gratitude:
            return "be grateful for what you have"
        }
    }
    
    /// This returns an array of category models made of `MeditationCategory`
    static var categoryModels: [CategoryModel] {
        var models = [CategoryModel]()
        MeditationCategory.allCases.forEach { (category) in
            models.append(CategoryModel(id: category.rawValue, title: category.rawValue, subtitle: category.subtitle))
        }
        return models
    }
    
    /// Default local playlist items
    var playlist: [String] {
        switch self {
        case .focus:
            return ["Focus Meditation - No words", "Guided Focus Meditation - Male"]
        default:
            break
        }
        return []
    }
}

/// Sounds Categories
enum SoundCategory: String, CaseIterable {
    case sleep = "sleep sounds"
    case focus = "focus music"
    case nature = "nature sounds"
    case zen = "zen music"
    case brainWaves = "brainwaves"
    case uplifting = "uplifting"
    
    /// This returns an array of category models made of `SoundCategory`
    static var categoryModels: [CategoryModel] {
        var models = [CategoryModel]()
        SoundCategory.allCases.forEach { (category) in
            models.append(CategoryModel(id: category.rawValue, title: category.rawValue, subtitle: nil))
        }
        return models
    }
    
    /// Default local playlist items
    var playlist: [String] {
        switch self {
        case .sleep:
            return ["Relaxing Sleep", "Yoga relaxation", "Peaceful Night"]
        case .focus:
            return ["Immediate focus", "Relaxing Focus Music"]
        case .nature:
            return ["Birds", "Fire", "Rain", "Ocean"]
        case .zen:
            return ["Zen Spa music", "Yoga Zen Oasis"]
        case .brainWaves:
            return [] /// You can add sounds here. It's left empty on purpose to demo the Empty state for playlist screen
        case .uplifting:
            return ["Uplifting Piano", "Summer Chill Electro"]
        }
    }
}


