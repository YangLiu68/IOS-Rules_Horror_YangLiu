//
//  MainView.swift
//  Rules Horror
//
//  Created by Tensorcraft on 12/05/2025.
//

import SwiftUI

final class TabRouter: ObservableObject {
    /// 当前选中的 tab 索引
    @Published var selected: Int = 0
}


struct TabView: View {
    @StateObject private var router = TabRouter()
    @EnvironmentObject var model: NovelEngineModel
    @State private var chatBackground: Image? = Image("collection_bg")
    private let uid: String
    private let syncService: RemoteSyncService

    init(uid: String, syncService: RemoteSyncService) {
        self.uid = uid
        self.syncService = syncService
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch router.selected {
                case 0:
                    NovelView(session: model.session, chatBackgroundImage: $chatBackground)
                        .onAppear {
                            if chatBackground == nil {
                                chatBackground = Image("collection_bg")
                            }
                        }
                case 1:
                    TimelineView()
                case 2:
                    CollectionsView()
                case 3:
                    SettingsView(uid: uid, syncService: RemoteSyncService())
                default:
                    Text("Internal Error")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))

            HStack {
                tabButton(imageName: "messages", index: 0)
                Spacer()
                tabButton(imageName: "timeline", index: 1)
                Spacer()
                tabButton(imageName: "collections", index: 2)
                Spacer()
                tabButton(imageName: "settings", index: 3)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 10)
            .background(
                Image("banner")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 70)
                    .frame(maxWidth: .infinity)
                    .clipped()
            )
        }
        .ignoresSafeArea(edges: .bottom)
        .environmentObject(router)
        .environmentObject(AudioPlayerManager.shared)
    }

    private func tabButton(imageName: String, index: Int) -> some View {
        Button(action: {
            router.selected = index
        }) {
            Image(imageName)
                .renderingMode(.original)
                .resizable()
                .frame(width: 50, height: 50)
                .opacity(router.selected == index ? 1.0 : 0.6)
        }
    }
}

struct MainView: View {
    let uid: String
    let syncService: RemoteSyncService
    var body: some View {
        TabView(uid: AuthManager.shared.uid ?? "", syncService: RemoteSyncService())
    }
}
