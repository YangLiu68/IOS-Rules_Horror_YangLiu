//
//  Models.swift
//  VisualNovel
//
//  Created by Tensorcraft on 09/05/2025.
//

import Foundation
import SwiftUICore

let MessageTypeText = 0
let MessageTypeImage = 1
let MessageTypeAudio = 2
let MessageTypeOptions = 3
let MessageTypeHints = 4
let MessageTypeBackgroundMusic = 5
let MessageTypeBackgroundImage = 6
let MessageTypeSoundEffect = 7
let MessageTypeUnlockCollection = 8

public struct ImageResource: Codable {
    public var name: String
    public var src: String
}

public struct AudioResource: Codable {
    public var name: String
    public var src: String
}

public struct Character: Codable {
    public var name: String
    public var avatar: String
    public var type: Int
    public var status: [String]?
    public var statusValues: [Int]?
}

public struct Message: Codable {
    public var character: String
    public var type: Int
    public var value: String
    public var options: [String]?
    public var routes: [String]?
}

public struct Collection: Codable {
    public var name: String
    public var src: String
    public var desc: String
    public var unlocked: Bool
}

public struct Chapter: Codable {
    public var name: String
    public var messages: [Message]
    public var unlocked: Bool?
    public var end: Bool?
}

public struct Novel: Codable {
    public var title: String
    public var id: String
    public var cover: String
    public var author: String
    public var entry: String
    public var images: [ImageResource]
    public var audios: [AudioResource]
    public var chapters: [Chapter]
    public var characters: [Character]
    public var collections: [Collection]
    public var currentChapter: String
    public var currentMsgIndex: Int
}

struct NovelPreview: Identifiable {
    let id: String
    let title: String
    let author: String
    let cover: Image
}

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    var type: Int
    var sender: String
    var value: String
    var isIncoming: Bool
    var options: [String]
    var routes: [String]
    var avatar: String
    var viewed: Bool

    init(
        id: UUID = UUID(),
        type: Int,
        sender: String,
        value: String,
        isIncoming: Bool,
        options: [String] = [],
        routes: [String] = [],
        avatar: String = "",
        viewed: Bool = false
    ) {
        self.id = id
        self.type = type
        self.sender = sender
        self.value = value
        self.isIncoming = isIncoming
        self.options = options
        self.routes = routes
        self.avatar = avatar
        self.viewed = viewed
    }
}
