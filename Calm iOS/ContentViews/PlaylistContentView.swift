//
//  PlaylistContentView.swift
//  Calmish
//
//  Created by Apps4World on 9/16/20.
//  Copyright © 2020 Apps4World. All rights reserved.
//

import SwiftUI
import Apps4World

/// Shows a list of music/sound items for a given category
struct PlaylistContentView: View {
    
    @ObservedObject var viewModel: AppViewModel
    var selectedCategory: CategoryModel
    
    var body: some View {
        ZStack {
            VStack {
                headerView
                soundsListView
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    /// Shows the image header and category title/stubtitle
    private var headerView: some View {
        ZStack {
            ZStack {
                VStack {
                    RemoteImage(imageUrl: selectedCategory.title.isEmpty ? "focus" : selectedCategory.title)
                        .frame(width: UIScreen.main.bounds.width, height: 300).clipped().overlay(Color.black.opacity(0.3))
                    Spacer()
                }
                VStack {
                    Text(selectedCategory.title.capitalized).font(.largeTitle).bold().foregroundColor(.white)
                    if selectedCategory.subtitle != nil {
                        Text(selectedCategory.subtitle!).font(.headline).foregroundColor(.white).opacity(0.75)
                    }
                }
            }.edgesIgnoringSafeArea(.top)
        }.frame(height: 200)
    }
    
    /// Shows the list of sounds/music
    private var soundsListView: some View {
        let playlist = viewModel.playlistItems[selectedCategory.title]
        return VStack {
            if playlist?.count ?? 0 == 0 {
                VStack {
                    Spacer()
                    Text(viewModel.playlistLoadingStatus.title).font(.title).bold()
                    Text(viewModel.playlistLoadingStatus.subtitle).font(.headline).fontWeight(.medium)
                    Spacer()
                }.opacity(0.7)
            } else {
                List {
                    ForEach(0..<(playlist?.count ?? 0), id: \.self, content: { index in
                        HStack {
                            Button(action: {
                                viewModel.playSoundItem(withTitle: playlist![index])
                            }, label: {
                                Image(systemName: "\(playlist![index] == viewModel.currentlyPlaying ? "stop" : "play").circle.fill")
                                    .resizable().aspectRatio(contentMode: .fit)
                                    .foregroundColor(playlist![index] == viewModel.currentlyPlaying ? Color(#colorLiteral(red: 0.08938691978, green: 0.6745098233, blue: 0.9686274529, alpha: 1)) : .black)
                                    .frame(height: 45)
                            })
                            Text(playlist![index]).padding(.leading, 20).lineLimit(1)
                            Spacer(minLength: 0.1)
                        }.padding()
                    })
                }
            }
        }.frame(width: UIScreen.main.bounds.width).background(Color.white)
    }
}

// MARK: - Preview UI
struct PlaylistContentView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistContentView(viewModel: AppViewModel(), selectedCategory: CategoryModel(id: "1", title: MeditationCategory.focus.rawValue, subtitle: MeditationCategory.focus.subtitle))
    }
}
