//
//  Media.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 17/08/2022.
//

import Foundation
import MessageKit
import UIKit

class Media: MediaItem {
    var url: URL?
    
    var image: UIImage?
    
    var placeholderImage: UIImage
    
    var size: CGSize
    
    init(url: URL, image: UIImage, placeholderImage: UIImage, size: CGSize) {
        self.url = url
        self.image = image
        self.placeholderImage = placeholderImage
        self.size = size
    }
    
    
}
