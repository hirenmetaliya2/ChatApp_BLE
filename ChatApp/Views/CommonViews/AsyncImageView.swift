//
//  AsyncImageView.swift
//  ChatApp
//
//  Created by Hiren Metaliya on 29/05/25.
//

import SwiftUI

struct AsyncImageView: View {
    let url: URL
    var body: some View {
        AsyncImage(url: url){ result in
            switch result{
            case .empty:
                ProgressView()
                    .frame(width: 50, height: 65)
            case .success(let image):
                image
                    .resizable()
                    .frame(width: 50, height: 65)
                    .clipShape(Circle())
            case .failure:
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 65)
                    .clipShape(Circle())
                
            @unknown default:
                EmptyView()
            }
        }
    }
}
#Preview {
    AsyncImageView(url: URL(string:"https://unsplash.com/photos/icy-mountain-covered-white-clouds-snpFW42KR8I")!)
}
