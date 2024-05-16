//
//  MainPostsView.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 4/8/24.
//

import SwiftUI

struct MainPostsView: View {
    @ObservedObject var viewModel: PostsViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.posts) { post in
                PostItemView(post: post)
                    .onAppear {
                        if post == viewModel.posts.last {
                            viewModel.loadMorePosts()
                        }
                    }
            }
        }
        .animation(.easeIn, value: viewModel.posts)
        .padding(.horizontal)
    }
}

struct PostHeader: View {
    var post: Link
    private let timestampFormatter = TimestampFormatter()
    
    var body: some View {
        HStack {
            Circle()
                .fill(.gray)
                .stroke(TintShapeStyle(), style: StrokeStyle(lineWidth: 2))
                .tint(.white)
                .frame(width: 35)
            VStack(alignment: .leading) {
                Text("u/\(post.author)")
                    .font(.subheadline)
                    .foregroundStyle(Color.accentColor)
                Text(timestampFormatter(from: post.created))
                    .font(.footnote)
            }
        }
    }
}

struct PhotoContentView: View {
    var photoUrl: String
    
    var body: some View {
        VStack {
            CachedAsyncImageView(imageUrl: photoUrl)
                .frame(maxWidth: .infinity, maxHeight: 500)
                .cornerRadius(20)
        }
    }
}

struct PostItemView: View {
    var post: Link
    
    var body: some View {
        VStack(alignment: .leading) {
            PostHeader(post: post)
            
            MarkdownText(styled: post.styledTitle, fallback: post.title)
                .font(.title2)
                .padding(.bottom)
            
            MarkdownText(styled: post.styledText, fallback: post.selftext)
                .lineLimit(5)
            
            if post.postHint == "image" {
                PhotoContentView(photoUrl: post.url)
            }
        }
        .padding(.vertical)
    }
}

struct MarkdownText: View {
    var styled: AttributedString?
    var fallback: String
    var body: some View {
        if let styledText = styled {
            Text(styledText)
        } else {
            Text(fallback)
        }
    }
}

#Preview {
    MainPostsView(viewModel: PostsViewModel(postsRepository: PreviewPostsRepository()))
}
