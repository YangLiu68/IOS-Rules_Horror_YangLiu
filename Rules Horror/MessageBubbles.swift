//
//  VoiceMessageView.swift
//  Rules Horror
//
//  Created by Tensorcraft on 12/05/2025.
//

import SwiftUI
import Combine


struct VoiceMessageView: View {
    let base64Audio: String
    let id = UUID()
    let isComing: Bool
    @State private var duration: TimeInterval = 0
    @State private var currentTime: TimeInterval = 0
    @State private var isPlaying = false
    @State private var timer: AnyCancellable?
    @EnvironmentObject var audioManager: AudioPlayerManager

    private var audioURL: URL? {
        guard let data = Data(base64Encoded: base64Audio) else { return nil }
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(id).m4a")
        try? data.write(to: tempURL)
        return tempURL
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.white)
            Text("\(timeString(currentTime))/\(timeString(duration))")
                .font(.caption.monospacedDigit())
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(isComing ? 0.2 : 0.6))
        .cornerRadius(16)
        .frame(maxWidth: 160)
        .onTapGesture { handleTap() }
        .onAppear {
            if let url = audioURL { duration = audioManager.getDuration(audioURL: url) }
        }
        .onReceive(audioManager.playbackFinished) { finishedID in
            guard finishedID == id else { return }
            stopUI()
        }
    }

    private var iconName: String { isPlaying ? "pause.circle" : "play.circle" }

    private func handleTap() {
        guard let url = audioURL else { return }

        if isPlaying {
            audioManager.pause()
            stopTimer()
            isPlaying = false
        } else if audioManager.isPaused(id: id) {
            audioManager.resume()
            startTimer()
            isPlaying = true
        } else {
            audioManager.play(audioURL: url, id: id) { stopUI() }
            currentTime = 0
            startTimer()
            isPlaying = true
        }
    }
    private func startTimer() {
        timer?.cancel()
        timer = Timer.publish(every: 0.2, on: .main, in: .common)
            .autoconnect()
            .sink { _ in currentTime = audioManager.currentTime(id: id) }
    }
    private func stopTimer() { timer?.cancel() }
    private func stopUI() {
        stopTimer()
        isPlaying = false
        currentTime = 0
    }
    private func timeString(_ t: TimeInterval) -> String {
        String(format: "%02d:%02d", Int(t) / 60, Int(t) % 60)
    }
}


struct ChatBubble: View {
    @EnvironmentObject var audioManager: AudioPlayerManager
    let message: String
    let senderName: String
    let avatarImage: Image
    let isFromCurrentUser: Bool
    let messageType: Int
    let options: [String]
    @State private var isShining = false
    let optionTapped: ((Int) -> Void)?

    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if messageType <= 3 {
                if !isFromCurrentUser {
                    avatarImage
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .foregroundColor(Color.white)
                } else {
                    Spacer(minLength: 40)
                }
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                if messageType < 3 {
                    Text(senderName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                if messageType == 0 {
                    Text(message)
                        .padding(10)
                        .background(isFromCurrentUser ? Color.gray.opacity(0.6) : Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .frame(maxWidth: 250, alignment: isFromCurrentUser ? .trailing : .leading)
                } else if messageType == 1 {
                    if let imageData = Data(base64Encoded: message),
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(minWidth: 200, minHeight: 200)
                                .frame(maxWidth: 300, maxHeight: 300)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(isFromCurrentUser ? Color.gray.opacity(0.6) : Color.gray.opacity(0.2), lineWidth: 2)
                                )
                                .cornerRadius(10)
                        } else {
                            Image(systemName: "xmark.octagon")
                                .resizable()
                                .scaledToFit()
                                .frame(minWidth: 200, minHeight: 200)
                                .frame(maxWidth: 300, maxHeight: 300)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(isFromCurrentUser ? Color.gray.opacity(0.6) : Color.gray.opacity(0.2), lineWidth: 2)
                                )
                                .cornerRadius(10)
                        }
                } else if messageType == 2 {
                    VoiceMessageView(base64Audio: message, isComing: !isFromCurrentUser)
                } else if messageType == 3{
                    ForEach(options.indices, id: \.self) { index in
                        Text(options[index])
                            .padding(10)
                            .background(Color.red.opacity(0.4))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .frame(maxWidth: 250, alignment: .trailing)
                            .opacity(isShining ? 1.0 : 0.6)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isShining)
                            .onAppear {
                                        isShining = true
                                    }
                            .onTapGesture {
                                optionTapped?(index)
                            }
                    }
                } else if messageType == 4 {
                    Text(message)
                        .foregroundColor(.gray)
                } else if messageType == 8 {
                    Text("Unclocked Collection: " + message)
                        .foregroundColor(.gray)
                }
            }
            if messageType <= 3 {
                if isFromCurrentUser {
                    avatarImage
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .foregroundColor(Color.white)
                } else {
                    Spacer(minLength: 40)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
