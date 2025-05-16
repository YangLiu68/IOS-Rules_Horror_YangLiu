//
//  TimelineDiagram.swift
//  Rules Horror
//
//  Created by Tensorcraft on 2025-05-13.
//
import SwiftUI

func clearDocumentsDirectory() {
    let fileManager = FileManager.default
    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    do {
        let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [])
        for fileURL in fileURLs {
            try fileManager.removeItem(at: fileURL)
        }
        print("Documents 目录清除完成")
    } catch {
        print("清除 Documents 失败: \(error.localizedDescription)")
    }
}

struct TimelineView: View {
    @EnvironmentObject var model: NovelEngineModel
    @EnvironmentObject private var router: TabRouter
    @EnvironmentObject var audioManager: AudioPlayerManager
    @StateObject private var viewModel = TimelineViewModel()

    private var hasChapters: Bool {
        !model.engine.getNovel().chapters.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            ImmersiveTitleBar(
                title: "Timeline",
                backgroundImage: Image("titlebar"),
                trailingSystemImage: audioManager.isMuted ? "speaker.slash.fill" : "speaker.wave.1.fill"
            ) {
                if audioManager.isMuted {
                    audioManager.unmute()
                } else {
                    audioManager.mute()
                }
            }

            if hasChapters {
                TimelineGraph(viewModel: viewModel) { chapterId in
                    print("点击章节：\(chapterId)")
                    model.engine.setCursor(chapterName: chapterId, lineCount: 0)
                    model.session.reset()
                    router.selected = 0
                }
                .background(
                    Image("collection_bg")
                        .resizable()
                        .scaledToFill()
                )
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)

                    Text("暂无章节数据")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    Image("collection_bg")
                        .resizable()
                        .scaledToFill()
                )
            }
        }
        .onAppear {
            let novel = model.engine.getNovel()
            viewModel.generateTimeline(from: novel)
        }
    }
}

#Preview {
    TimelineView()
        .environmentObject(NovelEngineModel())
}
