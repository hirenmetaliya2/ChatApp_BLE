//
//  UserProfile.swift
//  ChatApp
//
//  Created by Hiren Metaliya on 28/05/25.
//

import Foundation
import SwiftUI


struct UserProfile: Hashable, Identifiable{
    let id = UUID()
    var imageURL: URL
    var name: String
}


