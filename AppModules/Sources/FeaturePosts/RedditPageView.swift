//
//  RedditPageView.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 4/8/24.
//

import SwiftUI
import Combine
import Core

public struct RedditPageView: View {
    @ObservedObject var viewModel: RedditPageViewModel
    @State private var selectedViewModel: PostViewModel?
    
    public init(viewModel: RedditPageViewModel, selectedViewModel: PostViewModel? = nil) {
        self.viewModel = viewModel
        self.selectedViewModel = selectedViewModel
    }
    
    public var body: some View {
        List {
            ForEach(viewModel.postsViewModels) { item in
                PostItemView(viewModel: item)
                    .onAppear {
                        if item == viewModel.postsViewModels.last {
                            viewModel.loadMorePosts()
                        }
                    }
                    .onTapGesture {
                        selectedViewModel = item
                    }
            }
            .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
        }
        .listStyle(.plain)
        .sheet(item: $selectedViewModel) { post in
            PostDetailsView(viewModel: post)
        }
        .animation(.default, value: viewModel.postsViewModels)
    }
}

struct TimestampView: View {
    var timestamp: String
    
    var body: some View {
        HStack(spacing: 5) {
            Text("•")
                .bold()
            Text(timestamp)
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
}

struct PostHeader: View {
    @ObservedObject var viewModel: PostViewModel
    var showRedditor = false

    var body: some View {
        HStack {
            LazyImageView(image: $viewModel.icon) {
                Circle()
                    .fill(.secondary)
            }
            .frame(width: 35)
            .clipShape(Circle())
            .overlay(.red, in: Circle().stroke(style: StrokeStyle(lineWidth: 2)))
            
            HStack(alignment: .lastTextBaseline) {
                VStack(alignment: .leading) {
                    Text("r/\(viewModel.subreddit)")
                        .font(.subheadline)
                        .foregroundStyle(Color.accentColor)
                    if showRedditor {
                        Text("u/\(viewModel.author)")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }
                TimestampView(timestamp: viewModel.postedDateString)
            }
        }
        .onAppear {
            viewModel.loadIconIfNeeded()
        }
    }
}


// Display:
// 1. Upvotes
// 2. Number of Comments
// 3. Upvote action
// 4. Downvote action
struct PostActionsView: View {
    var upvotes = 0
    var numberComments = 0
    
    var body: some View {
        HStack {
            HStack {
                Button {
                    print("Upvote tapped...")
                } label: {
                    Image(systemName: "arrowshape.up")
                }
                .buttonStyle(.tappablePlain)
                
                Text("\(upvotes)")
                
                Button {
                    print("Downvote tapped...")
                } label: {
                    Image(systemName: "arrowshape.down")
                }
                .buttonStyle(.tappablePlain)
            }
            
            Color.white.opacity(0.6)
                .frame(width: 1)
                .padding(.vertical, 4)
            
            Label(
                title: { Text("\(numberComments)") },
                icon: { Image(systemName: "text.bubble") }
            )
        }
        .padding(.horizontal)
        .frame(height: 30)
        .background {
            RoundedRectangle(cornerSize: CGSize(width: 20, height: 10))
                .foregroundStyle(.white.opacity(0.25))
        }
    }
}

struct PhotoContentView: View {
    @ObservedObject var viewModel: PostViewModel
    
    var body: some View {
        VStack {
            postImage
                .frame(maxWidth: .infinity, maxHeight: 300)
                .cornerRadius(20)
        }
        .background(
            RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                .foregroundStyle(.secondary)
        )
        .onAppear {
            viewModel.loadPostImageIfNeeded()
        }
    }
    
    @ViewBuilder var postImage: some View {
        if let size = viewModel.imageSize {
            LazyImageView(image: $viewModel.image) {
                Color.secondary
            }
            .frame(height: min(size.height / 3, 300))
        } else {
            LazyImageView(image: $viewModel.image) {
                Color.secondary
            }
        }
    }
}

struct PostContentView: View {
    var viewModel: PostViewModel
    var showActions = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            PostHeader(viewModel: viewModel)
            
            Text(viewModel.attributedTitle)
                .font(.title3.bold())
            
            Text(viewModel.attributedBody)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(10)
            
            if viewModel.postHint == "image" {
                PhotoContentView(viewModel: viewModel)
            }
            
            if showActions {
                PostActionsView(upvotes: viewModel.ups - viewModel.downs, numberComments: viewModel.numComments)
            }
        }
    }
}

struct PostItemView: View {
    var viewModel: PostViewModel
    @State private var isHovering = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            if isHovering {
                RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                    .foregroundStyle(.white.opacity(0.05))
            }
            
            HStack {
                PostContentView(viewModel: viewModel)
                Spacer()
            }
            #if os(macOS)
            .padding()
            #endif
        }
//        #if os(macOS)
//        .onChange(of: isHovering) {
//            DispatchQueue.main.async {
//                if isHovering {
//                    NSCursor.pointingHand.push()
//                } else {
//                    NSCursor.pop()
//                }
//            }
//        }
//        .onHover { hovering in
//            isHovering = hovering
//        }
//        #endif
    }
}

#Preview {
    RedditPageView(viewModel:
                    RedditPageViewModel(
                        postsRepository: .preview, subredditRepository: .preview, commentsRepository: .preview, redditorRepository: .preview
                    )
    )
}
