//
//  Audio.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 23/08/2022.
//

import Foundation
import UIKit
import MessageKit

class Audio : AudioItem {
    var url: URL
    
    var duration: Float = 0.0
    
    var size: CGSize
    
    init(url: URL, duration: Float, size: CGSize) {
        self.url = url
        self.duration = duration
        self.size = size
    }
}
