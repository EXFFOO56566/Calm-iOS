//
//  MeditationCategoryView.swift
//  Calmish
//
//  Created by Apps4World on 9/15/20.
//  Copyright © 2020 Apps4World. All rights reserved.
//

import SwiftUI
import Apps4World

/// Meditation shaped category view
struct MeditationCategoryView: View {
    var category: CategoryModel
    var isFirst: Bool
    var isLast: Bool
    var isLocked: Bool
    var action: (_ item: CategoryModel) -> Void
    
    var body: some View {
        ZStack {
            RemoteImage(imageUrl: category.title)
                .frame(width: UIScreen.main.bounds.width, height: 400)
                .overlay(Color.black.opacity(isLocked ? 0.5 : 0.3))
                .mask(CategoryShape(isFirstCategory: isFirst, isLastCategory: isLast))
            Button(action: {
                self.action(self.category)
            }, label: {
                VStack {
                    if isLocked {
                        Image(systemName: "lock").resizable().aspectRatio(contentMode: .fit)
                            .frame(width: 20).accentColor(.white)
                    }
                    Text(category.title.capitalized).font(.largeTitle).bold().foregroundColor(.white)
                    if category.subtitle != nil {
                        Text(category.subtitle!).font(.headline).foregroundColor(.white).opacity(0.75)
                    }
                }
            })
        }.contentShape(CategoryShape(isFirstCategory: isFirst, isLastCategory: isLast))
    }
}

/// Custom shape to mask the image for category
struct CategoryShape: Shape {
    var isFirstCategory: Bool = false
    var isLastCategory: Bool = false
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: isLastCategory ? rect.maxY : rect.maxY - 120))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: isFirstCategory ? 0 : 120))
        return path
    }
}

// MARK: - Preview UI
struct MeditationCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        MeditationCategoryView(category: CategoryModel(id: "1", title: "focus", subtitle: "stay focused"),
                               isFirst: false, isLast: false, isLocked: true, action: { _ in })
    }
}
