//
//  MediaController.swift
//  MacRemote
//
//  Created by Prakhar Sharma on 29/01/26.
//
#if os(macOS)

import Foundation
import AppKit


final class MediaController {

    // MARK: - Supported Players

    enum Player {
        case spotify
        case music
        case vlc

        var bundleIdentifier: String {
            switch self {
            case .spotify:
                return "com.spotify.client"
            case .music:
                return "com.apple.Music"
            case .vlc:
                return "org.videolan.vlc"
            }
        }
    }

    // MARK: - Public API (called from CommandReceiver)

    func playPause() {
        if isRunning(.spotify) {
            run("tell application \"Spotify\" to playpause")
            return
        }

        if isRunning(.music) {
            run("tell application \"Music\" to playpause")
            return
        }

        if isRunning(.vlc) {
            run("tell application \"VLC\" to play")
            return
        }

        // 🌍 Global fallback (active "Now Playing" app)
        globalPlayPause()
    }

    func next() {
        if isRunning(.spotify) {
            run("tell application \"Spotify\" to next track")
            return
        }

        if isRunning(.music) {
            run("tell application \"Music\" to next track")
            return
        }

        if isRunning(.vlc) {
            run("tell application \"VLC\" to next")
            return
        }
    }

    func previous() {
        if isRunning(.spotify) {
            run("tell application \"Spotify\" to previous track")
            return
        }

        if isRunning(.music) {
            run("tell application \"Music\" to previous track")
            return
        }

        if isRunning(.vlc) {
            run("tell application \"VLC\" to previous")
            return
        }
    }

    func setVolume(_ level: Double) {
        let volume = max(0, min(100, Int(level * 100)))
        run("set volume output volume \(volume)")
    }

    // MARK: - Internals

    private func isRunning(_ player: Player) -> Bool {
        NSWorkspace.shared.runningApplications.contains {
            $0.bundleIdentifier == player.bundleIdentifier &&
            !$0.isTerminated
        }
    }

    /// Global media key play/pause (works for any app that owns Now Playing)
    private func globalPlayPause() {
        run("""
        tell application "System Events"
            key code 16
        end tell
        """)
    }

    /// Executes AppleScript safely
    private func run(_ script: String) {
        var error: NSDictionary?

        NSAppleScript(source: script)?
            .executeAndReturnError(&error)

        if let error {
            print("❌ AppleScript error:", error)
        }
    }
}

#endif
