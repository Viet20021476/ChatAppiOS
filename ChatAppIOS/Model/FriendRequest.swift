//
//  FriendRequest.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 24/08/2022.
//

import Foundation
import UIKit

class FriendRequest {
    var imgAvatarLink =  ""
    var fromUser = ""
    var senderId = ""
    
    init(imgAvatarLink: String, fromUser: String, senderId: String) {
        self.imgAvatarLink = imgAvatarLink
        self.fromUser = fromUser
        self.senderId = senderId
    }
    
    init(dict: [String: Any]) {
        self.imgAvatarLink = dict["avatar"] as! String
        self.fromUser = dict["name"] as! String
        self.senderId = dict["senderId"] as! String
    }
}
