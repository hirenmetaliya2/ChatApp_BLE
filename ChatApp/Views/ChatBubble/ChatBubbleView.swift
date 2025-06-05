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
            if message.senderID == DeviceID.shared.deviceID {
                Spacer()
            }
            Text(message.text)
                .padding(10)
                .background(message.senderID == DeviceID.shared.deviceID ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(message.senderID == DeviceID.shared.deviceID ? .white : .black)
                .cornerRadius(16)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: message.senderID == DeviceID.shared.deviceID ? .trailing : .leading)
                .padding(message.senderID == DeviceID.shared.deviceID ? .trailing : .leading)

            if !(message.senderID == DeviceID.shared.deviceID) {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
