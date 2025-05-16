// ChatSession.swift
// Rules Horror
//
// Updated by Tensorcraft on 14/05/2025.
//

import Foundation
import Combine

struct ChapterHistoryEntry: Codable {
    let name: String
    let messagesSnapshot: [ChatMessage]
}

final class ChatSession: ObservableObject, Codable {
    @Published var messages: [ChatMessage] = []
    @Published var currentChapterName: String = ""
    @Published var currentIndex: Int = 0
    @Published var chapterHistory: [ChapterHistoryEntry] = []

    enum CodingKeys: CodingKey {
        case messages, currentChapterName, currentIndex, chapterHistory
    }

    init() { }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.messages           = try container.decode([ChatMessage].self, forKey: .messages)
        self.currentChapterName = try container.decode(String.self,        forKey: .currentChapterName)
        self.currentIndex       = try container.decode(Int.self,           forKey: .currentIndex)
        self.chapterHistory     = try container.decode([ChapterHistoryEntry].self,
                                                       forKey: .chapterHistory)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(messages,           forKey: .messages)
        try container.encode(currentChapterName, forKey: .currentChapterName)
        try container.encode(currentIndex,       forKey: .currentIndex)
        try container.encode(chapterHistory,     forKey: .chapterHistory)
    }

    func reset() {
        messages.removeAll()
        currentChapterName = ""
        currentIndex = 0
        chapterHistory.removeAll()
    }
}
