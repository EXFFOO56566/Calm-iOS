//
//  DashboardContentView.swift
//  Calmish
//
//  Created by Apps4World on 9/15/20.
//  Copyright © 2020 Apps4World. All rights reserved.
//

import SwiftUI
import Apps4World

/// Main dashboard screen
struct DashboardContentView: View {

    private let interstitialAds: Interstitial = Interstitial()
    @ObservedObject var viewModel: AppViewModel
    @State private var premiumImageName: String = "focus"
    @State private var showModalScreen: Bool = false
    @State private var showPremiumScreen: Bool = false
    @State private var selectedTab: TabBarItem = .relax
    @State private var showPlaylistView: Bool = false
    @State private var shouldHideTabBar: Bool = false
    @State private var selectedCategory = CategoryModel(id: "", title: "", subtitle: "") {
        didSet {
            showPlaylistView.toggle()
            viewModel.fetchPlaylist(category: selectedCategory)
        }
    }
    
    var body: some View {
        ZStack {
            /// Background view. You can add a loading view or anything while the data is loading
            Color.black.edgesIgnoringSafeArea(.all)
            
            /// After the view model finishes to fetch data, show the appropriate tab details
            if viewModel.didFetchData {
                RelaxContentView(viewModel: viewModel, didSelectCategory: { category, isLocked in
                    prepareModalScreen(category: category, isLocked: isLocked)
                }).opacity(selectedTab == .relax ? 1 : 0).animation(.easeIn)
                
                SoundsContentView(viewModel: viewModel, didSelectCategory: { category, isLocked in
                    prepareModalScreen(category: category, isLocked: isLocked)
                }).opacity(selectedTab == .sounds ? 1 : 0).animation(.easeIn)
                
                MoreContentView(viewModel: viewModel, didShowPickerView: { show in
                    shouldHideTabBar = show
                }).opacity(selectedTab == .more ? 1 : 0).animation(.easeIn)
                
                /// Custom tab bar view at the bottom of the screen
                CustomTabBarView(viewModel: viewModel) { item in
                    self.selectedTab = item
                }.offset(y: shouldHideTabBar ? 200 : 0).animation(.easeIn)
            }
        }
        
        /// Present a modal screen
        .sheet(isPresented: $showModalScreen, content: {
            /// Show premium screen
            if showPremiumScreen {
                PKDarkThemeView(title: "Go Premium", subtitle: "Unlock all content", features: ["Remove Ads", "Unlock all categories", "Unlock all sound/music items", "Get access to new content"], productIds: ["premium"], imageName: premiumImageName)
                { (error, status, productId) in
                    if status == .restored || status == .success {
                        PKManager.shared.isPremiumUser = true
                        viewModel.isPremiumUser = true
                    }
                }
            }
            
            /// Show playlist for a given category
            else {
                PlaylistContentView(viewModel: viewModel, selectedCategory: selectedCategory)
            }
        })
    }
    
    /// Show modal screen
    private func prepareModalScreen(category: CategoryModel, isLocked: Bool) {
        premiumImageName = category.title
        showPremiumScreen = isLocked
        selectedCategory = category
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            interstitialAds.showInterstitialAds()
        })
        showModalScreen.toggle()
    }
}

// MARK: - Preview UI
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardContentView(viewModel: AppViewModel())
    }
}
