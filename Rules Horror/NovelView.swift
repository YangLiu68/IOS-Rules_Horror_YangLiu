// NovelView.swift
// VisualNovel
//
// Updated by Tensorcraft on 14/05/2025.
//

import SwiftUI

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}

struct NovelView: View {
    @EnvironmentObject private var model: NovelEngineModel
    @EnvironmentObject var audioManager: AudioPlayerManager
    @ObservedObject private var session: ChatSession
    @Binding var chatBackgroundImage: Image?

    init(session: ChatSession, chatBackgroundImage: Binding<Image?>) {
        self._session = ObservedObject(wrappedValue: session)
        self._chatBackgroundImage = chatBackgroundImage
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ImmersiveTitleBar(
                title: model.engine.getTitle(),
                backgroundImage: Image("titlebar"),
                trailingSystemImage: audioManager.isMuted ? "speaker.slash.fill" : "speaker.wave.1.fill"
            ) {
                if audioManager.isMuted {
                    audioManager.unmute()
                } else {
                    audioManager.mute()
                }
            }
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(session.messages.indices, id: \.self) { index in
                            ChatBubbleView(for: $session.messages[index])
                                .id(session.messages[index].id)
                        }
                    }
                }
                .background(
                    Image("collection_bg")
                        .resizable()
                        .scaledToFill()
                )
                .onChange(of: session.messages.count) { _ in
                    if let lastID = session.messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastID, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .onTapGesture { showNextMessage() }
        .onAppear { initializeProgress() }
    }

    private func initializeProgress() {
        let novel = model.engine.getNovel()
        let entryChapter = novel.currentChapter.isEmpty ? novel.entry : novel.currentChapter
        let startIndex   = novel.currentChapter.isEmpty ? 0 : novel.currentMsgIndex

        session.currentChapterName = entryChapter
        session.currentIndex       = startIndex

        model.engine.setCursor(
            chapterName: session.currentChapterName,
            lineCount: session.currentIndex
        )

        session.chapterHistory = [
            ChapterHistoryEntry(
                name: session.currentChapterName,
                messagesSnapshot: session.messages
            )
        ]

        if session.messages.isEmpty {
            showNextMessage()
        }
    }

    private func showNextMessage() {
        guard let message = model.engine.getNextMessage() else { return }
        appendChat(message)
        
        session.currentIndex += 1
        model.engine.setCursor(
            chapterName: session.currentChapterName,
            lineCount: session.currentIndex
        )
        if message.type == MessageTypeSoundEffect || message.type == MessageTypeBackgroundMusic {
            showNextMessage()
        }
        if !model.engine.hasNextMessage() && message.type != MessageTypeOptions{
            appendChat(Message(character: "System", type: MessageTypeHints, value: "ending..."))
        }
    }

    private func handleOptionTap(sourceID: UUID, optionIndex idx: Int) {
        guard let i = session.messages.firstIndex(where: { $0.id == sourceID }) else { return }
        let chosenText   = session.messages[i].options[idx]
        let nextChapter  = session.messages[i].routes[idx]
        let messageSender = session.messages[i].sender

        withAnimation {
            session.messages.remove(at: i)
        }
        let echo = ChatMessage(
            type: MessageTypeText,
            sender: messageSender,
            value: chosenText,
            isIncoming: false,
            options: [],
            routes: [],
            avatar: model.engine.getCharacter(messageSender)?.avatar ?? "",
            viewed: true
        )
        session.messages.append(echo)
        session.currentChapterName = nextChapter
        session.currentIndex = 0
        model.engine.setCursor(chapterName: nextChapter, lineCount: 0)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            showNextMessage()
        }
    }

    private func appendChat(_ message: Message) {
        let chat = ChatMessage(
            type: message.type,
            sender: message.character,
            value: message.value,
            isIncoming: model.engine.getCharacter(message.character)?.type == 1,
            options: message.options ?? [],
            routes: message.routes ?? [],
            avatar: model.engine.getCharacter(message.character)?.avatar ?? "",
            viewed: false
        )
        session.messages.append(chat)
    }
    
    private func ChatBubbleView(for omessage: Binding<ChatMessage>) -> some View {
        let message = omessage.wrappedValue
        switch message.type {
            case MessageTypeBackgroundImage:
                let base64 = contentValue(for: message)
                if let data = Data(base64Encoded: base64),
                   let uiImage = UIImage(data: data) {
                    chatBackgroundImage = Image(uiImage: uiImage)
                }
                return EmptyView().eraseToAnyView()
            
            case MessageTypeBackgroundMusic:
                if(!message.viewed) {
                    if let data = Data(base64Encoded: contentValue(for: message)) {
                        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID()).m4a")
                        try? data.write(to: tempURL)
                        audioManager.setBGM(tempURL)
                    }
                    omessage.wrappedValue.viewed = true
                }
                return EmptyView().eraseToAnyView()
            
            case MessageTypeSoundEffect:
                if(!message.viewed) {
                    if let data = Data(base64Encoded: contentValue(for: message)) {
                        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID()).m4a")
                        try? data.write(to: tempURL)
                        audioManager.playSoundEffect(tempURL)
                    }
                    omessage.wrappedValue.viewed = true
                }
                return EmptyView().eraseToAnyView()
            
            default:
                if message.type == MessageTypeUnlockCollection {
                    model.engine.unlockCollection(collectionName: message.value)
                }
                let imageData = Data(base64Encoded: model.engine.getImage(message.avatar)?.src ?? "")
                let uiImage = imageData.flatMap { UIImage(data: $0) }
                let avatar = uiImage.map { Image(uiImage: $0) } ?? Image(systemName: "person.fill")
                
                return ChatBubble(
                    message: contentValue(for: message),
                    senderName: message.sender,
                    avatarImage: avatar,
                    isFromCurrentUser: !message.isIncoming,
                    messageType: message.type,
                    options: message.options,
                    optionTapped: { idx in
                        handleOptionTap(sourceID: message.id, optionIndex: idx)
                    }
                ).eraseToAnyView()
        }
    }

    private func contentValue(for message: ChatMessage) -> String {
        switch message.type {
        case MessageTypeImage:
            return model.engine.getImage(message.value)?.src ?? ""
        case MessageTypeAudio:
            return model.engine.getAudio(message.value)?.src ?? ""
        case MessageTypeBackgroundImage:
            return model.engine.getImage(message.value)?.src ?? ""
        case MessageTypeSoundEffect:
            return model.engine.getAudio(message.value)?.src ?? ""
        case MessageTypeBackgroundMusic:
            return model.engine.getAudio(message.value)?.src ?? ""
        default:
            return message.value
        }
    }
}
