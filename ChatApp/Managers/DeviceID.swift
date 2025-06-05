//
//  DeviceID.swift
//  ChatApp
//
//  Created by Hiren Metaliya on 05/06/25.
//

import Foundation

final class DeviceID {
    static let shared = DeviceID()
    
    private init() {
        if UserDefaults.standard.string(forKey: "deviceID") == nil {
            let newID = UUID().uuidString
            UserDefaults.standard.set(newID, forKey: "deviceID")
        }
    }
    
    var deviceID: String {
        return UserDefaults.standard.string(forKey: "deviceID")!
    }
}
