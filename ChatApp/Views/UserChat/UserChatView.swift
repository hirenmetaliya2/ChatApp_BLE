//
//  UserChatView.swift
//  ChatApp
//
//  Created by Hiren Metaliya on 29/05/25.
//

import SwiftUI
import UIKit
import CoreBluetooth

struct UserChatView: View {
    @Environment(\.dismiss) var dismiss
    let user: DiscoveredUser
    let messages: [Message] = [
            Message(text: "Hey!", isSentByCurrentUser: false),
            Message(text: "Hi, how are you?", isSentByCurrentUser: true),
            Message(text: "Doing great. What about you?", isSentByCurrentUser: false),
            Message(text: "Same here!", isSentByCurrentUser: true)
        ]
    @State private var newMessage: String = ""
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack{
                    ForEach(messages){ message in
                        ChatBubbleView(message: message)
                    }
                }
            }
                .navigationBarBackButtonHidden(true)
                .toolbar{
                    ToolbarItem(placement: .navigationBarLeading){
                        Button{
                            dismiss()
                        }label:{
                            Image(systemName: "chevron.backward")
                                .foregroundStyle(.black)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading){
                        HStack(spacing: 0){
//                            AsyncImageView(url: user.imageURL)
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
            Spacer()
                HStack{
                    Button{
                        
                    }label: {
                        Image(systemName: "plus")
                            .font(.system(size: 25))
                            .padding(.bottom, 2)
                            .foregroundStyle(.black)
                    }
                    Spacer()
                    TextField("Type a message...", text: $newMessage)
                        .padding()
                        .frame(width: 300, height: 35)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(15)
                    Spacer()
                }
//                .padding(.horizontal, 80)
                .padding(.horizontal)
            
            
        }
        
    }
}
extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

#Preview {
    
        UserChatView(user: DiscoveredUser(id: UUID(), peripheral: nil, name: "Dummy User", lastSeen: Date()))
        
    
}
