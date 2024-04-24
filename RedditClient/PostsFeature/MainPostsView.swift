//
//  MainPostsView.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 4/8/24.
//

import SwiftUI

struct PostHeader: View {
    var post: Link
    
    var body: some View {
        HStack {
            Circle()
                .fill(.gray)
                .stroke(TintShapeStyle(), style: StrokeStyle(lineWidth: 2))
                .tint(.white)
                .frame(width: 25)
            Text("u/\(post.author)")
                .font(.subheadline)
                .foregroundStyle(Color.accentColor)
        }
    }
}

struct PhotoContentView: View {
    var post: Link
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: post.urlOverridenByDest)) { image in
                image.image?.resizable()
            }
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
        }
    }
}

struct PostItemView: View {
    var post: Link
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                PostHeader(post: post)
                HStack {
                    Text(post.title)
                        .font(.title)
                }
                Text(post.selftext)
                PhotoContentView(post: post)
            }
        }
    }
}

struct MainPostsView: View {
    @State private var posts: [Link] = [
        Link(id: "12345", name: "Link preview name", author: "author", title: "Interesting sample title", selftext: "The selftext of this post", created: .now, createdUtc: .now, ups: 100, downs: 0, numComments: 50, subreddit: "pics", permalink: "r/pics/comment/preview-link", pinned: false, urlOverridenByDest: "https://i.redd.it/i5bwv00qlitc1.jpeg")
    ]
    
    var body: some View {
        List {
            ForEach(posts) { post in
                PostItemView(post: post)
            }
        }
    }
}

#Preview {
    MainPostsView()
}
