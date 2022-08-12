//
//  User.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 11/08/2022.
//

import Foundation

class User {
    var id = ""
    var email = ""
    var avatar = ""
    var name = ""
    
    init(dict: [String: Any]) {
        self.id = dict["id"] as! String
        self.email = dict["email"] as! String
        self.avatar = dict["avatar"] as! String
        self.name = dict["name"] as! String
    }
}
