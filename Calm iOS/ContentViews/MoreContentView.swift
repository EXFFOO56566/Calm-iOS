//
//  MoreContentView.swift
//  Calmish
//
//  Created by Apps4World on 9/18/20.
//  Copyright © 2020 Apps4World. All rights reserved.
//

import SwiftUI
import StoreKit
import Apps4World

/// Show more features for the app
struct MoreContentView: View {
    
    enum DatePickerType { case none, dateTime }
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: AppViewModel
    @State private var scheduleDate: Date = Date()
    @State private var pickerType: DatePickerType = .none
    var didShowPickerView: (_ show: Bool) -> Void
    
    var body: some View {
        ZStack {
            RemoteImage(imageUrl: "gratitude").overlay(Color.black.opacity(0.65)).edgesIgnoringSafeArea(.all)
            VStack {
                headerView
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        VStack(alignment: .leading, spacing: 12) {
                            self.pushNotifications.padding(.top, 25)
                            self.socialMedia(title: "See our Instagram", icon: "ig_icon", bg: "ig_bg", action: {
                                UIApplication.shared.open(AppConfig.instagramURL, options: [:], completionHandler: nil)
                            })
                            
                            Color.white.frame(height: 1).opacity(0.5)
                            self.socialMedia(title: "Rate this app", icon: "star.fill", bg: "self love", action: {
                                SKStoreReviewController.requestReview()
                            })
                            
                            Color.white.frame(height: 1).opacity(0.5)
                            VStack(alignment: .leading) {
                                self.supportItem(title: "Restore Purchases", icon: "arrow.down.circle.fill", action: {
                                    PKManager.restorePurchases { (_) in
                                        self.presentationMode.wrappedValue.dismiss()
                                    }
                                })
                                self.supportItem(title: "Contact us", icon: "phone.fill", action: {
                                    UIApplication.shared.open(AppConfig.contactURL, options: [:], completionHandler: nil)
                                }).padding(.bottom, 40)
                            }.padding(.top, 25)
                        }
                        Spacer(minLength: 100)
                    }
                }
            }
            .padding(20)
            .foregroundColor(.white)
            .edgesIgnoringSafeArea(.bottom)
            .frame(maxWidth: UIScreen.main.bounds.width)
            pickerFooterView.offset(y: pickerType == .none ? 450 : 0).animation(.spring()).frame(maxWidth: UIScreen.main.bounds.width)
        }
        .frame(maxWidth: UIScreen.main.bounds.width)
    }
    
    private var headerView: some View {
        HStack {
            Text("Settings").font(.largeTitle).bold()
            Spacer()
        }
    }
    
    private var pushNotifications: some View {
        VStack(alignment: .leading)  {
            HStack(spacing: 20) {
                Image(systemName: "bell.fill").resizable().frame(width: 25, height: 25)
                Text("Local Notifications").font(.system(size: 18))
                Toggle(isOn: $viewModel.pushNotificationsStatus.onChange({ (status) in
                    self.savePushNotificationsStatus(status)
                }), label: { Text("") }).padding(.trailing, 5)
            }.padding(.bottom, 20)
            Color.white.frame(height: 1).opacity(0.5)
        }
    }
    
    private func socialMedia(title: String, icon: String, bg: String, action: @escaping () -> Void) -> some View {
        Button(action: { action() }, label: {
            ZStack {
                Image(bg).resizable().renderingMode(.original)
                    .aspectRatio(contentMode: .fill).frame(height: 150)
                    .overlay(Color.black.opacity(0.3))
                VStack(alignment: .leading)  {
                    HStack(spacing: 20) {
                        if UIImage(named: icon) == nil {
                            Image(systemName: icon).resizable().aspectRatio(contentMode: .fit).frame(width: 30)
                        } else {
                            Image(icon).resizable().aspectRatio(contentMode: .fit).frame(width: 30)
                        }
                        Text(title).font(.system(size: 18)).bold()
                    }
                }
            }
        })
        .cornerRadius(15)
        .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
    }
    
    private func supportItem(title: String, icon: String, action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading)  {
            HStack(spacing: 20) {
                Image(systemName: icon).resizable().aspectRatio(contentMode: .fit).frame(width: 25)
                Text(title).font(.system(size: 18))
            }.padding(.bottom, 20)
        }.onTapGesture {
            action()
        }
    }
    
    var pickerFooterView: some View {
        VStack {
            if pickerType != .none {
                Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5))
                    .edgesIgnoringSafeArea(.top)
                    .onTapGesture {
                        pickerType = .none
                        didShowPickerView(false)
                        if !viewModel.didSetupPushNotifications {
                            viewModel.pushNotificationsStatus = false
                            savePushNotificationsStatus(false)
                        }
                    }
                ZStack {
                    Color.white.layoutPriority(0).frame(width: UIScreen.main.bounds.width).cornerRadius(20)
                    if pickerType == .dateTime {
                        VStack {
                            VStack {
                                Text("Daily Reminder").font(.title).bold()
                                Text("Choose your daily reminder time")
                            }.layoutPriority(0).padding(.top, 20)
                            dailyTimePicker.layoutPriority(1)
                            Button(action: {
                                pickerType = .none
                                viewModel.setupPushNotificationsReminder()
                                didShowPickerView(false)
                            }, label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10).frame(height: 50)
                                    Text("Setup Daily Notifications").bold().foregroundColor(.white)
                                }
                            }).padding()
                        }
                    }
                }
            }
        }
    }
    
    var dailyTimePicker: some View {
        DatePicker(selection: $scheduleDate.onChange({ (date) in
            self.viewModel.selectedPushNotificationsReminderDate(date)
        }), in: viewModel.dateRange, displayedComponents: .hourAndMinute) {
            EmptyView()
        }.datePickerStyle(WheelDatePickerStyle()).labelsHidden()
    }
    
    private func savePushNotificationsStatus(_ state: Bool) {
        func requestPushNotificationsPermissions() {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                if settings.authorizationStatus != .authorized {
                    self.presentationMode.wrappedValue.dismiss()
                    DispatchQueue.main.async {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    }
                }
            }
        }
        
        if state {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, _) in
                if granted {
                    pickerType = .dateTime
                    didShowPickerView(true)
                } else { requestPushNotificationsPermissions() }
            }
        } else {
            self.presentationMode.wrappedValue.dismiss()
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
    }
}

// MARK: - Preview UI
struct MoreContentView_Previews: PreviewProvider {
    static var previews: some View {
        MoreContentView(viewModel: AppViewModel(), didShowPickerView: { _ in })
    }
}

// MARK: - Determine if a given binding object has changed
extension Binding {
    /// Helps us monitor changes on a binding object. For example when user selected a certain segment from segmented control or picker
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
        })
    }
}
