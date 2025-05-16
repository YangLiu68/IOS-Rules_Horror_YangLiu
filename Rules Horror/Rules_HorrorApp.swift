//
//  Rules_HorrorApp.swift
//  Rules Horror
//
//  Created by Tensorcraft on 12/05/2025.
//
import SwiftUI
import SwiftData
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Combine

class NovelEngineModel: ObservableObject {
    @Published var engine: NovelEngine = NovelEngine()
    @Published var nodes: [TimelineNode] = []
    @Published var session = ChatSession()

    private let engineFileName = "novel_save.json"
    private let sessionFileName = "session_save.json"
    @Published var userID: String?
    private let remote = RemoteSyncService()
    private var syncTask: Task<Void, Never>?
    private var cancellable: AnyCancellable?

    init() {
        // 1️⃣ 监听登录状态，登录后立即同步
        cancellable = AuthManager.shared.$uid
            .sink { [weak self] uid in
                guard let self, let uid else { return }
                self.syncTask?.cancel()
                self.syncTask = Task { await self.syncWithCloud(uid: uid) }
            }

        loadNovel()
        loadSession()
    }

    // 先做一次“谁新谁赢”的合并策略
    private func syncWithCloud(uid: String) async {
        do {
            let localEngineURL = localURL(for: engineFileName)
            let localSessionURL = localURL(for: sessionFileName)

            let localDate = try? FileManager.default
                .attributesOfItem(atPath: localEngineURL.path)[.modificationDate] as? Date

            if let remoteSnap = try await remote.fetch(uid: uid) {
                // 远程较新 → 覆盖本地
                print("local:")
                print(localDate)
                print("remote:")
                print(remoteSnap.updatedAt)
                if localDate == nil || remoteSnap.updatedAt > localDate! {
                    try remoteSnap.engine.write(to: localEngineURL, options: .atomic)
                    try remoteSnap.session.write(to: localSessionURL, options: .atomic)
                    self.loadNovel()
                    self.loadSession()
                }
            }

            // 无论远程是否覆盖本地，最后再把当前最新本地状态推上去
            try await remote.push(uid: uid,
                                  engineData: Data(contentsOf: localEngineURL),
                                  sessionData: Data(contentsOf: localSessionURL))
        } catch {
            print("Cloud sync error:", error)
        }
    }

    // 把你的 URL 拼装提取一下以免重复
    private func localURL(for file: String) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent(file)
    }

    func saveProgress() {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        let engineURL = dir.appendingPathComponent(engineFileName)
        do {
            try engine.save(to: engineURL.path)
        } catch {
            print("Failed to save engine:", error)
        }

        let sessionURL = dir.appendingPathComponent(sessionFileName)
        do {
            session.messages.removeAll{$0.type == MessageTypeSoundEffect}
            let data = try JSONEncoder().encode(session)
            try data.write(to: sessionURL, options: .atomic)
        } catch {
            print("Failed to save session:", error)
        }
        if let uid = AuthManager.shared.uid {
            Task {
                do {
                    let eURL = localURL(for: engineFileName)
                    let sURL = localURL(for: sessionFileName)
                    try await remote.push(uid: uid,
                                          engineData: Data(contentsOf: eURL),
                                          sessionData: Data(contentsOf: sURL))
                } catch { print("Push failed:", error) }
            }
        }
    }

    func loadNovel() {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let engineURL = dir.appendingPathComponent(engineFileName)
        if FileManager.default.fileExists(atPath: engineURL.path) {
            engine.loadNovel(from: engineURL.path)
        } else if let bundlePath = Bundle.main.path(forResource: "novel", ofType: "json") {
            engine.loadNovel(from: bundlePath)
        }
    }

    func loadSession() {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let sessionURL = dir.appendingPathComponent(sessionFileName)
        guard FileManager.default.fileExists(atPath: sessionURL.path) else {
            return
        }
        do {
            let data = try Data(contentsOf: sessionURL)
            let decoded = try JSONDecoder().decode(ChatSession.self, from: data)
            self.session = decoded
        } catch {
            print("Failed to load session:", error)
        }
    }
}

@main
struct Rules_HorrorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    @State private var isActive = false
    @StateObject private var novelModel = NovelEngineModel()

    var body: some Scene {
        WindowGroup {
            if isActive {
                MainView(uid: AuthManager.shared.uid ?? "", syncService: RemoteSyncService())
                    .environmentObject(novelModel)
            } else {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isActive = true
                            }
                        }
                    }
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background || newPhase == .inactive {
                novelModel.saveProgress()
            }
        }
    }
}
