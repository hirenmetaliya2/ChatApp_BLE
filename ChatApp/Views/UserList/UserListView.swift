//
//  ContentView.swift
//  ChatApp
//
//  Created by Hiren Metaliya on 28/05/25.
//

import SwiftUI

struct UserListView: View {
    @StateObject var bluetoothManager = BluetoothManager()
    
    //    @StateObject private var vm = UserViewModel()
    @State private var selectedUser: DiscoveredUser?
    var body: some View {
        NavigationStack{
            
            List(bluetoothManager.discoveredUsers){ user in
                Button{
                    selectedUser = user
                }label:{
                    userCell(user)
                        .foregroundStyle(.black)
                }
            }
            .toolbar{
                ToolbarItem{
                    if !bluetoothManager.isBluetoothEnabled{
                        HStack{
                            Text("Bluetooth is off")
                                .foregroundStyle(.yellow)
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.yellow)
                        }
                        .clipShape(.rect(cornerRadius: 20))
                    }
                    
                }
            }
            .navigationTitle("ChatApp")
            .navigationDestination(item: $selectedUser){ user in
                UserChatView(user: user)
            }
        }
    }
    //MARK: - User Cell
    private func userCell(_ user: DiscoveredUser) -> some View{
        HStack{
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 50, height: 65)
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(user.name)
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                Text("something")
                    .lineLimit(1)
                    .opacity(0.7)
            }
        }
        
        
        
    }
}


#Preview {
    UserListView()
}
