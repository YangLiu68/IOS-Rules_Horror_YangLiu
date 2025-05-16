//
//  SettingsView.swift
//  Rules Horror
//
//  Created by Tensorcraft on 13/05/2025.
//

import SwiftUI

struct ClearDataButton: View {
    @State private var showConfirmation = false
    var clearAction: () -> Void
    
    var body: some View {
        Button(action: {
            showConfirmation = true
        }) {
            HStack {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                Text("清除所有数据")
                    .foregroundColor(.red)
                    .font(.headline)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.black.opacity(0.7))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.red, lineWidth: 1.5)
            )
            .cornerRadius(10)
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
        .confirmationDialog("你确定要清除所有游戏数据吗？", isPresented: $showConfirmation, titleVisibility: .visible) {
            Button("确认清除", role: .destructive) {
                clearAction()
            }
            Button("取消", role: .cancel) {}
        }
    }
}

struct LanguageSelectorView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage = "zh"
    
    let languages = [
        ("zh", "中文"),
        ("en", "English"),
        ("ja", "日本語")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("选择语言")
                .font(.title2)
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            ForEach(languages, id: \.0) { code, name in
                Button(action: {
                    selectedLanguage = code
                }) {
                    HStack {
                        Text(name)
                            .font(.headline)
                            .foregroundColor(selectedLanguage == code ? .orange.opacity(0.7) : .gray)
                        Spacer()
                        if selectedLanguage == code {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedLanguage == code ? .orange.opacity(0.7) : Color.gray.opacity(0.5), lineWidth: 1)
                            .background(
                                selectedLanguage == code
                                ? .orange.opacity(0.3)
                                : Color.black.opacity(0.3)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(Color.black.opacity(0.4))
        .cornerRadius(16)
        .padding()
    }
}

struct SettingsView: View {
    @EnvironmentObject var audioManager: AudioPlayerManager
    @EnvironmentObject private var model: NovelEngineModel
    let uid: String
    let syncService: RemoteSyncService

    var body: some View {
        VStack(spacing: 0) {
            ImmersiveTitleBar(
                title: "Settings",
                backgroundImage: Image("titlebar"),
                trailingSystemImage: audioManager.isMuted ? "speaker.slash.fill" : "speaker.wave.1.fill"
            ) {
                if audioManager.isMuted {
                    audioManager.unmute()
                } else {
                    audioManager.mute()
                }
            }
            
            ScrollView(.vertical) {
                VStack {
                    Image("title")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                    LanguageSelectorView()
                    Text("User ID:" + uid)
                        .foregroundColor(.gray)
                    ClearDataButton {
                        Task {
                            model.engine.reset()
                            model.session.reset()
                            clearDocumentsDirectory()
                            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                            do {
                                try await syncService.deleteRemoteCache(uid: uid)
                                print("远程数据已清除")
                            } catch {
                                print("清除远程数据失败: \(error)")
                            }
                            print("数据已清除")
                        }
                    }
                    
                }
            }
            .background(
                Image("collection_bg")
                    .resizable()
                    .scaledToFill()
            )

        }
    }
}


#Preview {
    CollectionsView()
}
