//
//  NovelEngine.swift
//  VisualNovel
//
//  Created by Tensorcraft on 09/05/2025.
//

import Foundation

public class NovelEngine {
    private var novel: Novel?
    private var cursorChapter: Chapter?
    private var cursorLine: Int = 0

    public init() {}

    public func loadNovel(from path: String) {
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            self.novel = try decoder.decode(Novel.self, from: data)
            var loadedNovel = try decoder.decode(Novel.self, from: data)

            self.novel = loadedNovel
        } catch {
            print("Failed to load novel: \(error)")
        }
    }

    public func getChapters() -> [String] {
        return novel?.chapters.map { $0.name } ?? []
    }

    public func getImages() -> [String] {
        return novel?.images.map { $0.name } ?? []
    }

    public func getAudios() -> [String] {
        return novel?.audios.map { $0.name } ?? []
    }
    public func getCharacters() -> [String] {
        let names = novel?.chapters.flatMap { $0.messages.map { $0.character } } ?? []
        return Array(Set(names))
    }
    
    public func getCharacter(_ name: String) -> Character? {
        return novel?.characters.first { $0.name == name }
    }


    public func getImage(_ name: String) -> ImageResource? {
        return novel?.images.first { $0.name == name }
    }

    public func getAudio(_ name: String) -> AudioResource? {
        return novel?.audios.first { $0.name == name }
    }

    public func setCursor(chapterName: String, lineCount: Int) {
        guard var novel = self.novel,
        let index = novel.chapters.firstIndex(where: { $0.name == chapterName }) else { return }

        var chapter = novel.chapters[index]

        chapter.unlocked = true

        novel.chapters[index] = chapter

        self.cursorChapter = chapter
        self.cursorLine = min(max(0, lineCount), chapter.messages.count)

        novel.currentChapter = chapterName
        novel.currentMsgIndex = lineCount

        self.novel = novel
    }
    
    public func unlockCollection(collectionName: String) {
        guard var novel = self.novel,
              let index = novel.collections.firstIndex(where: { $0.name == collectionName }) else { return }
        var collection = novel.collections[index]
        collection.unlocked = true
        novel.collections[index] = collection
        self.novel = novel
    }
    
    public func getChapter(name: String) -> Chapter {
        return novel?.chapters.first { $0.name == name } ?? Chapter(name: "", messages: [])
    }
    
    public func getNovel() -> Novel {
        return novel ?? Novel(title: "", id: "", cover: "", author: "", entry: "", images: [], audios: [], chapters: [], characters: [], collections: [], currentChapter: "", currentMsgIndex: 0)
    }

    public func getTitle() -> String {
        return novel?.title ?? ""
    }

    public func getAuthor() -> String {
        return novel?.author ?? ""
    }

    public func getEntry() -> String {
        return novel?.entry ?? ""
    }

    public func getNextMessage() -> Message? {
        guard let chapter = cursorChapter, cursorLine < chapter.messages.count else { return nil }
        let message = chapter.messages[cursorLine]
        cursorLine += 1
        return message
    }

    public func hasNextMessage() -> Bool {
        return cursorChapter != nil && cursorLine < cursorChapter!.messages.count
    }
    
    public func save(to path: String) {
        guard let novel = self.novel else {
            print("No novel to save.")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            let data = try encoder.encode(novel)
            try data.write(to: url)
            print("Novel saved successfully to \(path)")
        } catch {
            print("Failed to save novel: \(error)")
        }
    }
    
    public func reset() {
        guard var novel = self.novel else { return }

        for i in novel.chapters.indices {
            novel.chapters[i].unlocked = false
        }

        for i in novel.collections.indices {
            novel.collections[i].unlocked = false
        }

        if let entryChapterIndex = novel.chapters.firstIndex(where: { $0.name == novel.entry }) {
            let chapter = novel.chapters[entryChapterIndex]
            self.cursorChapter = chapter
            self.cursorLine = 0

            novel.currentChapter = chapter.name
            novel.currentMsgIndex = 0
        }

        self.novel = novel
        
        self.setCursor(chapterName: novel.entry, lineCount: 0)
    }

}
