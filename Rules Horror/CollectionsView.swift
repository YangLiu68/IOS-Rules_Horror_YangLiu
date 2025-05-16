//
//  CollectionsView.swift
//  Rules Horror
//
//  Created by Tensorcraft on 13/05/2025.
//

import SwiftUI

struct Item: Identifiable {
    let id = UUID()
    let image: UIImage
    let title: String
    let description: String
}

struct CollectionsView: View {
    @EnvironmentObject var model: NovelEngineModel
    @EnvironmentObject var audioManager: AudioPlayerManager
    @State private var unlockedItems: [Item] = []

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 0) {
            ImmersiveTitleBar(
                title: "Collections",
                backgroundImage: Image("titlebar"),
                trailingSystemImage: audioManager.isMuted ? "speaker.slash.fill" : "speaker.wave.1.fill"
            ) {
                if audioManager.isMuted {
                    audioManager.unmute()
                } else {
                    audioManager.mute()
                }
            }

            ScrollView {
                if unlockedItems.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "lock.shield")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)

                        Text("All collections are currently locked")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(unlockedItems) { item in
                            VStack(alignment: .leading, spacing: 8) {
                                Image(uiImage: item.image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipped()

                                Text(item.title)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .lineLimit(1)

                                Text(item.description)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(
                Image("collection_bg")
                    .resizable()
                    .scaledToFill()
            )
        }
        .onAppear {
            refreshUnlockedItems()
        }
        .onReceive(model.$engine) { _ in
            refreshUnlockedItems()
        }
    }

    private func refreshUnlockedItems() {
        unlockedItems = model.engine.getNovel().collections
            .filter { $0.unlocked}
            .compactMap { collection in
                guard let data = Data(base64Encoded: model.engine.getImage(collection.src)?.src ?? ""),
                      let image = UIImage(data: data) else {
                    return nil
                }
                return Item(image: image, title: collection.name, description: collection.desc)
            }
    }
}

#Preview {
    CollectionsView()
}
