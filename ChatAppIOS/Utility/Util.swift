//
//  Util.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 16/08/2022.
//

import Foundation

class Util {
    static func getStringFromDate(format: String, date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        //dateFormatter.dateFormat = "YYYY,MMM d,HH:mm:ss"
        
        return dateFormatter.string(from: date)
    }
}
