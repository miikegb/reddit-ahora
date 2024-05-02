//
//  CachedAsyncImageView.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 5/2/24.
//

import SwiftUI

struct CachedAsyncImageView: View {
    var imageUrl: String
    private let cacheManager = ImageCacheManager()
    @State private var image: NSImage?
    
    init(imageUrl: String) {
        self.imageUrl = imageUrl
        self.image = cacheManager.getImage(with: imageUrl)
    }
    
    var body: some View {
        VStack {
            if let image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                EmptyView()
            }
        }
        .frame(height: 500)
        .onReceive(cacheManager.loadImage(with: imageUrl)) { platformImage in
            if image == nil {
                image = platformImage
            }
        }
    }
}

