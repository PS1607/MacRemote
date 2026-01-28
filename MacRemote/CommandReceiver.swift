//
//  CommandReceiver.swift
//  MacRemote
//
//  Created by Prakhar Sharma on 29/01/26.
//

import Foundation
import Network

#if os(macOS)
    final class CommandReceiver {

        private var listener: NWListener?
        private let mediaController = MediaController()

        func start() {
            do {
                listener = try NWListener(using: .tcp, on: 5555)
            } catch {
                print("❌ Failed to start listener:", error)
                return
            }

            listener?.newConnectionHandler = { [weak self] connection in
                guard let self else { return }

                connection.start(queue: .main)
                self.receive(on: connection)
            }

            listener?.start(queue: .main)
            print("🟢 Mac receiver listening on port 5555")
        }

        private func receive(on connection: NWConnection) {
            connection.receive(
                minimumIncompleteLength: 1,
                maximumLength: 65_536
            ) { [weak self] data, _, _, error in
                guard let self else { return }

                if let error {
                    print("❌ Receive error:", error)
                    return
                }

                guard let data else {
                    print("⚠️ No data received")
                    self.receive(on: connection)
                    return
                }

                // ✅ Swift 6–correct: hop to MainActor explicitly
                Task { @MainActor in
                    guard
                        let command = try? JSONDecoder().decode(
                            MediaCommand.self,
                            from: data
                        )
                    else {
                        print("⚠️ Invalid data received")
                        return
                    }

                    print("📥 Received command:", command)

                    switch command {
                    case .playPause:
                        self.mediaController.playPause()

                    case .seekForward:
                        self.mediaController.next()

                    case .seekBackward:
                        self.mediaController.previous()

                    case .setVolume(let level):
                        self.mediaController.setVolume(level)
                    }
                }

                // Keep listening
                self.receive(on: connection)
            }
        }
    }
#endif
