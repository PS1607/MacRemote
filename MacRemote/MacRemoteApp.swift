//
//  MacRemoteApp.swift
//  MacRemote
//
//  Created by Prakhar Sharma on 29/01/26.
//

import SwiftUI

@main
struct MacRemoteApp: App {

    #if os(macOS)
    private let receiver = CommandReceiver()
    #endif

    init() {
        #if os(macOS)
        receiver.start()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
