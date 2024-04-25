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
            }
        }
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
    var post: Link
    
    var body: some View {
        VStack {
            if let imageUrl = post.urlOverridenByDest {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image.image?.resizable()
                }
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
            } else {
                EmptyView()
            }
        }
    }
}

struct PostItemView: View {
    var post: Link
    
    var body: some View {
        VStack(alignment: .leading) {
            PostHeader(post: post)
            
            HStack {
                Text(post.title)
                    .font(.title)
            }
            .padding(.bottom)
            
            Text(post.selftext)
            PhotoContentView(post: post)
        }
        .padding(.vertical)
    }
}

#Preview {
    MainPostsView(viewModel: PostsViewModel(postsRepository: PreviewPostsRepository()))
}
