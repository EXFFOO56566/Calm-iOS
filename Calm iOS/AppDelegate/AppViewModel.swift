//
//  AppViewModel.swift
//  Calmish
//
//  Created by Apps4World on 9/15/20.
//  Copyright © 2020 Apps4World. All rights reserved.
//

import AVKit
import Foundation
import Apps4World
import UserNotifications

/// This is the view model for the app
public class AppViewModel: ObservableObject {
    
    // MARK: - Private implementation
    private let dataManager = AppManager()
    private var soundCategoriesArray = [CategoryModel]()
    private var pushNotificationsDate: Date?
    
    /// Create a 2D array from sounds category to represent into a grid
    private func createTableSoundCategories() {
        if let firstItem = soundCategoriesArray.first {
            var array = [CategoryModel]()
            array.append(firstItem)
            if soundCategoriesArray.count > 1 { array.append(soundCategoriesArray[1]) }
            soundCategories.append(array)
            soundCategoriesArray.removeAll { (category) -> Bool in
                array.contains(where: { $0.title == category.title })
            }
            createTableSoundCategories()
        }
    }
    
    // MARK: - Public implementation
    init() {
        fetchData()
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { (_) in
            self.currentlyPlaying = ""
        }
    }
    
    /// Update the UI when data was fetched
    @Published var didFetchData: Bool = false
    
    /// Categories for `Relax/Meditation` tab
    @Published var meditationCategories = [CategoryModel]()

    /// Categories for `Sounds` tab
    @Published var soundCategories = [[CategoryModel]]()
    
    /// Playlist items for a given category
    @Published var playlistItems = [String: [String]]()
    
    /// Currently playing item
    @Published var currentlyPlaying: String = ""
    
    /// Verify is user is a premium user
    @Published var isPremiumUser: Bool = PKManager.shared.isPremiumUser
    
    /// Indicates the push notifications permissions/status
    @Published var pushNotificationsStatus: Bool = false
    
    /// This is the status while fetching playlist data
    @Published var playlistLoadingStatus: (title: String, subtitle: String) = ("please wait", "loading playlist")
    
    /// Indicates when push notifications date was setup
    var didSetupPushNotifications: Bool = false
    
    /// Play a sound/music for a given name/title
    func playSoundItem(withTitle title: String) {
        if currentlyPlaying == title { currentlyPlaying = "" } else {
            currentlyPlaying = title
        }
        
        if currentlyPlaying == "" {
            PlayerManager.shared.stop()
        } else {
            PlayerManager.shared.play(item: currentlyPlaying)
        }
    }
    
    /// Date range for the push notifications picker
    var dateRange: ClosedRange<Date> {
        var startDateComponents = DateComponents()
        var endDateComponents = DateComponents()
        startDateComponents.hour = 0
        endDateComponents.hour = 23
        return Calendar.current.date(from: startDateComponents)!...Calendar.current.date(from: endDateComponents)!
    }
    
    /// This must be called as soon as the app launches, to start fetching the data
    func fetchData() {
        fetchPushNotificationsStatus()
        dataManager.fetchDatabaseData(completion: { meditation, sounds in
            self.meditationCategories = meditation
            self.soundCategoriesArray = sounds
            self.createTableSoundCategories()
            self.didFetchData = true
        })
    }
    
    /// Fetch songs/music for a given category
    func fetchPlaylist(category: CategoryModel) {
        playlistLoadingStatus = ("please wait", "loading playlist")
        dataManager.fetchPlaylist(category: category) { (playlistItems) in
            self.playlistItems[category.title] = playlistItems
            if playlistItems.count == 0 {
                self.playlistLoadingStatus = ("Oh no!", "Nothing to see here")
            }
        }
    }
    
    /// Fetch push notifications settings
    func fetchPushNotificationsStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized { self.pushNotificationsStatus = true }
        }
    }
    
    /// Setup push notification daily reminder
    func setupPushNotificationsReminder() {
        func removeNotificationsIfNeeded() {
            UNUserNotificationCenter.current().getPendingNotificationRequests { (request) in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm a"
                request.forEach { (request) in
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [request.identifier])
                }
            }
        }
        
        guard let date = pushNotificationsDate else { return }
        removeNotificationsIfNeeded()
        let content = UNMutableNotificationContent()
        content.title = AppConfig.pushNotification
        content.sound = .default
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let errorMessage = error?.localizedDescription {
                print("NOTIFICATION ERROR: \(errorMessage)")
            } else {
                self.didSetupPushNotifications = true
            }
        }
    }
    
    func selectedPushNotificationsReminderDate(_ date: Date?) {
        pushNotificationsDate = date
    }
}
