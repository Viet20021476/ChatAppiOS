//
//  User.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 11/08/2022.
//

import Foundation
import MessageKit

class User : SenderType {
    var senderId = ""
    var email = ""
    var avatar = ""
    var displayName = ""
    var timeStamp = 0.0
    
    init(dict: [String: Any]) {
        self.senderId = dict["id"] as! String
        self.email = dict["email"] as! String
        self.avatar = dict["avatar"] as! String
        self.displayName = dict["name"] as! String
        self.timeStamp = dict["timeStamp"] as! Double
    }
    
    init(senderId: String, displayName: String) {
        self.senderId = senderId
        self.displayName = displayName
    }
}
