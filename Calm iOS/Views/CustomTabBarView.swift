//
//  CustomTabBarView.swift
//  Calmish
//
//  Created by Apps4World on 9/15/20.
//  Copyright © 2020 Apps4World. All rights reserved.
//

import SwiftUI

/// Tab bar item types that reflects the name and image
enum TabBarItem: String, CaseIterable {
    case relax, sounds, more
    
    var image: Image {
        switch self {
        case .relax:
            return Image(self.rawValue)
        case .sounds:
            return Image(systemName: "music.note.list")
        case .more:
            return Image(systemName: "gear")
        }
    }
}

/// This will construct a custom tab bar view at the bottom of the screen
struct CustomTabBarView: View {
    
    @ObservedObject var viewModel: AppViewModel
    @State var selectedTabBarItem: TabBarItem = .relax
    private let generator = UINotificationFeedbackGenerator()
    var didSelectItem: (_ item: TabBarItem) -> Void
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                /// This is the orange player view with song title
                createPlayerView()
                
                /// Tab bar items
                ZStack {
                    RoundedRectangle(cornerRadius: 36).frame(height: 65)
                    
                    /// This stack will create some invisible tabs just to get the accurate dimension for a tab
                    HStack {
                        ForEach(0..<TabBarItem.allCases.count, content: { index in
                            self.createTabBarItemBackground(type: TabBarItem.allCases[index])
                        })
                        createPlayButtonview().opacity(0)
                    }.foregroundColor(.white).padding(.leading, 12).padding(.trailing, 12)
                    
                    /// Tabs with title and image
                    HStack {
                        ForEach(0..<TabBarItem.allCases.count, content: { index in
                            self.createTabBarItem(type: TabBarItem.allCases[index])
                        })
                        createPlayButtonview()
                    }.padding(.leading, 10).padding(.trailing, 10)
                }
            }
        }.foregroundColor(Color(#colorLiteral(red: 0.08938691978, green: 0.6745098233, blue: 0.9686274529, alpha: 1))).padding().edgesIgnoringSafeArea(.bottom)
    }
    
    /// Player view for currently playing song
    private func createPlayerView() -> some View {
        VStack {
            if viewModel.currentlyPlaying == "" {
                EmptyView()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 20).foregroundColor(Color(#colorLiteral(red: 0.9898365132, green: 0.7097655388, blue: 0.1709118151, alpha: 1))).frame(height: 50)
                    (
                        Text("Now Playing: ").font(.system(size: 14)).fontWeight(.light) +
                        Text(viewModel.currentlyPlaying).font(.system(size: 15))
                    ).lineLimit(1).foregroundColor(.black).padding().offset(y: -7)
                }.padding(EdgeInsets(top: 0, leading: 40, bottom: -25, trailing: 40))
            }
        }
    }
    
    /// Play/Pause button on the tab bar
    private func createPlayButtonview() -> some View {
        VStack {
            if viewModel.currentlyPlaying == "" {
                EmptyView()
            } else {
                Button(action: {
                    viewModel.playSoundItem(withTitle: "")
                    generator.notificationOccurred(.success)
                }, label: {
                    Image(systemName: "stop.circle.fill").resizable().aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                }).frame(width: 35, height: 35)
            }
        }
    }
    
    /// Tab bar item
    private func createTabBarItem(type: TabBarItem) -> some View {
        let isSelectedItem = selectedTabBarItem == type
        return Button(action: {
            generator.notificationOccurred(.success)
            self.selectedTabBarItem = type
            self.didSelectItem(type)
        }, label: {
            HStack {
                type.image
                Text(type.rawValue.capitalized)
            }.foregroundColor(isSelectedItem ? .black : .white).opacity(isSelectedItem ? 1.0 : 0.5)
        }).frame(maxWidth: .infinity)
    }
    
    /// White background for the tab bar item
    private func createTabBarItemBackground(type: TabBarItem) -> some View {
        RoundedRectangle(cornerRadius: 36).frame(height: 45).opacity(selectedTabBarItem == type ? 1 : 0)
    }
}

// MARK: - Preview UI
struct CustomTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBarView(viewModel: AppViewModel(), didSelectItem: { item in })
    }
}
