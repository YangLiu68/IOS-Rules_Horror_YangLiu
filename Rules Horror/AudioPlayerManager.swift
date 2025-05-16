//
//  AudioPlayerManager.swift
//  Rules Horror
//
//  Created by Tensorcraft on 12/05/2025.
//

import SwiftUI
import Foundation
import AVFoundation
import Combine

final class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {

    static let shared = AudioPlayerManager()
    
    let playbackFinished = PassthroughSubject<UUID, Never>()

    func currentTime(id: UUID) -> TimeInterval {
        currentPlayingID == id ? (mainPlayer?.currentTime ?? 0) : 0
    }

    @Published private(set) var currentPlayingID: UUID?
    @Published var isMuted: Bool = false {
        didSet {
            updateVolumeForAllPlayers()
        }
    }

    private var mainPlayer: AVAudioPlayer?
    private var bgmPlayer: AVAudioPlayer?
    private var sfxPlayers: [AVAudioPlayer] = []

    private var mainFinishCallback: (() -> Void)?

    private override init() {
        super.init()
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[AudioPlayerManager] Failed to set audio session:", error)
        }
    }

    // MARK: - Mute Control
    func mute() {
        isMuted = true
    }

    func unmute() {
        isMuted = false
    }

    private func updateVolumeForAllPlayers() {
        let volume: Float = isMuted ? 0 : 1
        mainPlayer?.volume = volume
        bgmPlayer?.volume = volume
        for player in sfxPlayers {
            player.volume = volume
        }
    }

    // MARK: - Main
    func play(audioURL: URL, id: UUID, onFinish: @escaping () -> Void) {
        stop()
        do {
            let player = try AVAudioPlayer(contentsOf: audioURL)
            player.delegate = self
            player.volume = isMuted ? 0 : 1
            mainPlayer = player
            mainFinishCallback = onFinish
            currentPlayingID = id
            player.prepareToPlay()
            player.play()
        } catch {
            print("[AudioPlayerManager] Main play failed:", error)
        }
    }

    func pause() {
        mainPlayer?.pause()
    }

    func resume() {
        mainPlayer?.play()
    }

    func stop() {
        mainPlayer?.stop()
        mainPlayer = nil
        currentPlayingID = nil
        mainFinishCallback?()
    }

    func isPlaying(id: UUID) -> Bool {
        currentPlayingID == id && mainPlayer?.isPlaying == true
    }

    func isPaused(id: UUID) -> Bool {
        currentPlayingID == id && mainPlayer?.isPlaying == false && mainPlayer != nil
    }

    func getDuration(audioURL: URL) -> TimeInterval {
        (try? AVAudioPlayer(contentsOf: audioURL).duration) ?? 0
    }

    // MARK: - BGM
    func setBGM(_ url: URL) {
        stopBGM()
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.delegate = self
            player.volume = isMuted ? 0 : 1
            bgmPlayer = player
            player.prepareToPlay()
            player.play()
        } catch {
            print("[AudioPlayerManager] BGM play failed:", error)
        }
    }

    func stopBGM(fadeOutDuration: TimeInterval? = nil) {
        guard let player = bgmPlayer else { return }
        if let fade = fadeOutDuration, fade > 0 {
            let step: TimeInterval = 0.1
            var remainingTime = fade
            Timer.scheduledTimer(withTimeInterval: step, repeats: true) { timer in
                remainingTime -= step
                player.volume = max(0, Float(remainingTime / fade))
                if remainingTime <= 0 {
                    timer.invalidate()
                    player.stop()
                }
            }
        } else {
            player.stop()
        }
        bgmPlayer = nil
    }

    // MARK: - SFX
    func playSoundEffect(_ url: URL) {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.volume = isMuted ? 0 : 1
            sfxPlayers.append(player)
            player.prepareToPlay()
            player.play()
        } catch {
            print("[AudioPlayerManager] SFX play failed:", error)
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if player === mainPlayer {
            mainFinishCallback?()
            if let id = currentPlayingID {
                playbackFinished.send(id)
            }
            currentPlayingID = nil
            mainPlayer = nil
            return
        }

        if let index = sfxPlayers.firstIndex(where: { $0 === player }) {
            sfxPlayers.remove(at: index)
            return
        }

        if player === bgmPlayer {
            bgmPlayer = nil
        }
    }
}
