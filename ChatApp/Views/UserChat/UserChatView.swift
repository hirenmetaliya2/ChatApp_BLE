import SwiftUI
import UIKit
import CoreBluetooth

struct UserChatView: View {
    @Environment(\.dismiss) var dismiss
    let user: DiscoveredUser
    @StateObject var bluetoothManager = BluetoothManager()
    @State private var newMessage: String = ""
    @State private var scrollToBottom = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack {
                            ForEach(bluetoothManager.receivedMessages) { message in
                                ChatBubbleView(message: message)
                                    .id(message.id)
                            }
                        }
                    }
                    .onChange(of: bluetoothManager.receivedMessages.count) { _ in
                        if let lastMessage = bluetoothManager.receivedMessages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                HStack {
                    Button {
                        // Add attachment functionality here
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 25))
                            .padding(.bottom, 2)
                            .foregroundStyle(.black)
                    }
                    
                    TextField("Type a message...", text: $newMessage)
                        .padding()
                        .frame(width: 300, height: 35)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(15)
                        .onSubmit {
                            sendMessage()
                        }
                    
                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "paperplane.circle.fill")
                            .font(.system(size: 33))
                            .foregroundStyle(.black)
                    }
                }
                .padding(.horizontal)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .foregroundStyle(.black)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 0) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 65)
                            .clipShape(Circle())
                            .scaleEffect(0.675)
                        Text(user.name)
                            .fontWeight(.bold)
                    }
                }
            }
        }
    }
    
    private func sendMessage() {
        guard !newMessage.isEmpty else { return }
        let message = Message(text: newMessage, senderID: DeviceID.shared.deviceID)
        bluetoothManager.sendMessage(message)
        newMessage = ""
    }
}

#Preview {
    UserChatView(user: DiscoveredUser(id: UUID(), peripheral: nil, name: "Dummy User", lastSeen: Date()))
}
