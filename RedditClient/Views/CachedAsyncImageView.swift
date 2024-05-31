//
//  CachedAsyncImageView.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 5/2/24.
//

import SwiftUI

struct LazyImageView<Placeholder: View>: View {
    @Binding var image: PlatformImage?
    @ViewBuilder var placeholder: Placeholder
    var contentMode: ContentMode = .fit
    
    var body: some View {
        if let image {
            Image(platformImage: image)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } else {
            placeholder
        }
    }
}

extension Image {
    init(platformImage: PlatformImage) {
        #if os(macOS)
        self.init(nsImage: platformImage)
        #else
        self.init(uiImage: platformImage)
        #endif
    }
}
