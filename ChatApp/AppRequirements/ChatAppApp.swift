//
//  ChatAppApp.swift
//  ChatApp
//
//  Created by Hiren Metaliya on 28/05/25.
//

import SwiftUI

@main
struct ChatAppApp: App {
    
    init(){
        _ = DeviceID.shared
    }
    var body: some Scene {
        WindowGroup {
            UserListView()
        }
    }
}
