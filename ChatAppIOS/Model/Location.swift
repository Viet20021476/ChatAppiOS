//
//  Location.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 22/08/2022.
//

import UIKit
import Foundation
import MessageKit
import CoreLocation

class Location: LocationItem {
    var location: CLLocation
    var size: CGSize
    
    init(location: CLLocation, size: CGSize) {
        self.location = location
        self.size = size
    }
}
