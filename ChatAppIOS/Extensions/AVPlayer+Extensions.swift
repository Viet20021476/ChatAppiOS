//
//  AVPlayer+Extensions.swift
//  CustomVideoPlayer
//
//  Created by Huy Nguyen on 7/4/21.
//

import AVFoundation

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
