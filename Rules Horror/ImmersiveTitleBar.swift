//
//  ImmersiveTitleBar.swift
//  Rules Horror
//
//  Created by Tensorcraft on 13/05/2025.
//

import SwiftUI

struct ImmersiveTitleBar: View {
    var title: String
    var backgroundImage: Image
    var trailingSystemImage: String
    var onTrailingTap: () -> Void = {}
    @Environment(\.colorScheme) private var colorScheme
    private var height: CGFloat { 60 }

    var body: some View {
        ZStack(alignment: .bottomLeading) {

            backgroundImage
                .resizable()
                .scaledToFill()
                .frame(height: height + topInset)
                .clipped()
                .ignoresSafeArea(edges: .top)

            HStack(alignment: .center) {
                Text(title)
                    .font(.system(size: 26))
                    .fontWeight(.bold)
                    .foregroundColor(.orange.opacity(0.7))

                Spacer(minLength: 0)

                Button(action: onTrailingTap) {
                    Image(systemName: trailingSystemImage)
                        .frame(width: 15, height: 15)
                        .font(.headline)
                        .foregroundColor(.orange.opacity(0.7))
                        .padding(20)
                }
            }
            .padding(.leading, 20)
            .padding(.bottom, 30)
        }
        .frame(height: height)
    }

    private var topInset: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first?
            .safeAreaInsets.top ?? 0
    }
}
