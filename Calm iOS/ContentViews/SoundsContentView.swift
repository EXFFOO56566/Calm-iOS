//
//  SoundsContentView.swift
//  Calmish
//
//  Created by Apps4World on 9/16/20.
//  Copyright © 2020 Apps4World. All rights reserved.
//

import SwiftUI
import Apps4World

/// Shows a list of sound categories
struct SoundsContentView: View {
    
    @ObservedObject var viewModel: AppViewModel
    @State private var selectedSoundCategory: CategoryModel?
    var didSelectCategory: (_ category: CategoryModel, _ isLocked: Bool) -> Void
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                ForEach(0..<viewModel.soundCategories.count, id: \.self, content: { row in
                    HStack {
                        ForEach(0..<self.viewModel.soundCategories[row].count, id: \.self, content: { item in
                            soundCategory(row: row, item: item)
                        })
                    }.padding(.leading, 10).padding(.trailing, 10)
                })
                Spacer(minLength: 80)
            }
        }
        .background(RemoteImage(imageUrl: "focus").overlay(Color.black.opacity(0.4)).edgesIgnoringSafeArea(.all))
        .frame(maxWidth: UIScreen.main.bounds.width)
    }
    
    /// Sound category item for index
    private func soundCategory(row: Int, item: Int) -> some View {
        let currentItem = viewModel.soundCategories[row][item]
        let flatMapItems = viewModel.soundCategories.reduce([], +)
        let isLocked = (flatMapItems.firstIndex(where: { $0.title == currentItem.title }) ?? 0 >= AppConfig.freeItems.categories && !viewModel.isPremiumUser)
        return ZStack {
            RemoteImage(imageUrl: viewModel.soundCategories[row][item].title).layoutPriority(0)
                .overlay(Color.black.opacity(isLocked ? 0.5 : 0))
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.9), Color.black.opacity(0), Color.black.opacity(0)]), startPoint: .bottom, endPoint: .top).layoutPriority(1)
            VStack {
                Spacer()
                if isLocked {
                    Image(systemName: "lock").resizable().aspectRatio(contentMode: .fit)
                        .frame(width: 20).foregroundColor(.white)
                }
                Text(viewModel.soundCategories[row][item].title.capitalized).bold().lineLimit(1).minimumScaleFactor(0.5)
                    .foregroundColor(.white)
            }.padding()
        }
        .opacity(selectedSoundCategory?.title ?? "" == viewModel.soundCategories[row][item].title ? 0.4 : 1)
        .frame(height: 220).clipped().cornerRadius(20).padding().shadow(radius: 10)
        .onTapGesture {
            selectedSoundCategory = viewModel.soundCategories[row][item]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.selectedSoundCategory = nil
                self.didSelectCategory(self.viewModel.soundCategories[row][item], isLocked)
            }
        }
    }
}

// MARK: - Preview UI
struct SoundsContentView_Previews: PreviewProvider {
    static var previews: some View {
        SoundsContentView(viewModel: AppViewModel(), didSelectCategory: { _, _ in })
    }
}
