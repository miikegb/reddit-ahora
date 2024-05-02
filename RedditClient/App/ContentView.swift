//
//  ContentView.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 3/26/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MainPostsView(
            viewModel: PostsViewModel(
                postsRepository: RedditPostsRepository(
                    fetcher: HttpClient(config: .default)
                )
            )
        )
        .cornerRadius(5)
        .padding()
    }
}


#Preview {
    ContentView()
}
