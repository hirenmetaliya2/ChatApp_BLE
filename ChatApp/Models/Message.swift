//
//  Message.swift
//  ChatApp
//
//  Created by Hiren Metaliya on 29/05/25.
//
import Foundation

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isSentByCurrentUser: Bool
}

