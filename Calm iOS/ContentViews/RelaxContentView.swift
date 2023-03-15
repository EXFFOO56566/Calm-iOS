//
//  RelaxContentView.swift
//  Calmish
//
//  Created by Apps4World on 9/16/20.
//  Copyright © 2020 Apps4World. All rights reserved.
//

import SwiftUI
import Apps4World

/// Shows a list of relax/meditation categories
struct RelaxContentView: View {
    
    @ObservedObject var viewModel: AppViewModel
    var didSelectCategory: (_ category: CategoryModel, _ isLocked: Bool) -> Void
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: -120) {
                ForEach(0..<viewModel.meditationCategories.count, id: \.self, content: { index in
                    meditationCategoryView(index: index)
                })
            }
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
    
    private func meditationCategoryView(index: Int) -> some View {
        let isLocked = (index >= AppConfig.freeItems.categories && !viewModel.isPremiumUser)
        let categoryModel = viewModel.meditationCategories[index]
        return MeditationCategoryView(category: categoryModel,
                                      isFirst: index == 0,
                                      isLast: index == viewModel.meditationCategories.count - 1,
                                      isLocked: isLocked, action: { item in
                                self.didSelectCategory(item, isLocked)
        }).shadow(radius: 20)
    }
}

// MARK: - Preview UI
struct RelaxContentView_Previews: PreviewProvider {
    static var previews: some View {
        RelaxContentView(viewModel: AppViewModel(), didSelectCategory: { _, _ in })
    }
}
