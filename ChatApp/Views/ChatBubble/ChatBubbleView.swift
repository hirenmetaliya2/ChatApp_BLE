//
//  ChatBubbleView.swift
//  ChatApp
//
//  Created by Hiren Metaliya on 29/05/25.
//

import SwiftUI

struct ChatBubbleView: View {
    let message: Message

    var body: some View {
        HStack {
            if message.isSentByCurrentUser {
                Spacer()
            }

            Text(message.text)
                .padding(10)
                .background(message.isSentByCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(message.isSentByCurrentUser ? .white : .black)
                .cornerRadius(16)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: message.isSentByCurrentUser ? .trailing : .leading)
                .padding(message.isSentByCurrentUser ? .trailing : .leading)

            if !message.isSentByCurrentUser {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
