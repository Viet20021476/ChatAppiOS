//
//  User.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 11/08/2022.
//

import Foundation
import MessageKit

class User : SenderType, Comparable {
    var senderId = ""
    var email = ""
    var avatar = ""
    var displayName = ""
    var timeStamp = 0.0
    var beingInRoom = ""
    var isOnline = false
    var lastOnline = ""
    var birthDate = ""
    var phoneNumber = ""
    var feeling = ""
    var friends = [User]()
    var friendsRequest = [FriendRequest]()
    
    init(dict: [String: Any]) {
        self.senderId = dict["id"] as! String
        self.email = dict["email"] as! String
        self.avatar = dict["avatar"] as! String
        self.displayName = dict["name"] as! String
        self.timeStamp = dict["timeStamp"] as! Double
        self.beingInRoom = dict["beingInRoom"] as! String
        self.isOnline = dict["isOnline"] as! Bool
        self.lastOnline = dict["lastOnline"] as! String
        self.birthDate = dict["birthDate"] as! String
        self.phoneNumber = dict["phoneNumber"] as! String
        self.feeling = dict["feeling"] as! String
        //self.friends = dict["friends"] as! [User]
        //self.friendsRequest = dict["friendsRequest"] as! [FriendRequest]
    }
    
    init(senderId: String, displayName: String) {
        self.senderId = senderId
        self.displayName = displayName
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.senderId == rhs.senderId
    }
    
    static func < (lhs: User, rhs: User) -> Bool {
        return true
    }
    

    
}
