//
//  UserViewModel.swift
//  ChatApp
//
//  Created by Hiren Metaliya on 29/05/25.
//

import Foundation

class UserViewModel: ObservableObject {
    @Published var users: [UserProfile] = []
    
    init(){
        self.loadUsers()
    }
    
    private func loadUsers(){
        users = [
            UserProfile(imageURL: URL(string:"https://media.istockphoto.com/id/1341288649/photo/75mpix-panorama-of-beautiful-mount-ama-dablam-in-himalayas-nepal.jpg?s=2048x2048&w=is&k=20&c=tYXX52oUSiV5_FPTEyReC8XoY1tx4hPhDBvfZNtzg8w=")!, name: "Meet"),
            UserProfile(imageURL: URL(string: "https://unsplash.com/photos/icy-mountain-covered-white-clouds-snpFW42KR8I")!, name: "Jeet")
        ]
    }
}
