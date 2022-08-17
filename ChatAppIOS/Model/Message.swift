//
//  Message.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 12/08/2022.
//

import Foundation
import MessageKit

class Message : MessageType {
    var sender: SenderType
    var senderId = ""
    var receiverId: String = ""
    var messageId: String = ""
    var senderName = ""
    
    var sentDate: Date = Date()
    var strSentDate = ""
    
    var kind: MessageKind
    var type = ""
    var textContent = ""
    var isSeen = false
    var downloadURL = ""
    
    init(sender: SenderType, messageId: String, senderId: String, receiverId: String, strSentDate: String, kind: MessageKind, type: String, textContent: String, sentDate: Date, downloadURL: String, isSeen: Bool) {
        self.sender = sender
        self.messageId = messageId
        self.senderId = senderId
        self.receiverId = receiverId
        self.strSentDate = strSentDate
        self.kind = kind
        self.type = type
        self.textContent = textContent
        self.sentDate = sentDate
        self.downloadURL = downloadURL
        self.isSeen = isSeen
    }
    
    init(dict: [String: Any]) {
        self.messageId = dict["messageId"] as! String
        self.senderId = dict["senderId"] as! String
        self.senderName = dict["senderName"] as! String
        self.receiverId = dict["receiverId"] as! String
        self.strSentDate = dict["strSentDate"] as! String
        self.type = dict["type"] as! String
        self.textContent = dict["textContent"] as! String
        self.downloadURL = dict["downloadURL"] as! String
        self.isSeen = dict["isSeen"] as! Bool
        
        self.sender = User(dict: ["id": "userId", "email": "email", "avatar": "avatar", "name": "name", "timeStamp": 0.0, "beingInRoom": "room", "isOnline": false, "lastOnline": "", "birthDate": "", "phoneNumber": "", "feeling": ""])
        self.kind = .text("")
                
    }
}

extension MessageKind {
    var msgKind: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}
