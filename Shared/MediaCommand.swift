//
//  MediaCommand.swift
//  MacRemote
//
//  Created by Prakhar Sharma on 29/01/26.
//

import Foundation

enum MediaCommand: Codable {
    case playPause
    case seekBackward(seconds: Int)
    case seekForward(seconds: Int)
    case setVolume(level: Double)
}
