//
//  SplashView.swift
//  VisualNovel
//
//  Created by Tensorcraft on 10/05/2025.
//

import Foundation
import SwiftUI

struct SplashView: View {
    var body: some View {
        VStack {
            Image("messages")
                .resizable()
                .frame(width: 250, height: 250)
                .foregroundColor(.yellow)
            Image("title")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("collection_bg")
        )
        .foregroundColor(.white)
    }
}

#Preview {
    SplashView()
}
