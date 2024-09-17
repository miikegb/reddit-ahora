//
//  RedditPageView.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 4/8/24.
//

import SwiftUI
import Combine
import Core

fileprivate enum K {
    static let loadingNewPostsThreshold = 5
}

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
                    .task {
                        if item == viewModel.postsViewModels.suffix(K.loadingNewPostsThreshold).first {
                            await viewModel.loadPosts()
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
        .task {
            await viewModel.loadPosts()
        }
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
            .frame(width: 25)
            .clipShape(Circle())
            .overlay(.red, in: Circle().stroke(style: StrokeStyle(lineWidth: 1)))
            
            HStack(alignment: .lastTextBaseline) {
                VStack(alignment: .leading) {
                    Text("r/\(viewModel.subreddit)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(white: 0.2))
                    if showRedditor {
                        Text("u/\(viewModel.author)")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }
                TimestampView(timestamp: viewModel.postedDateString)
            }
        }
        .task {
            await viewModel.loadIconIfNeeded()
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
                
                Divider()
                    .padding(.horizontal, 2)
                
                Button {
                    print("Downvote tapped...")
                } label: {
                    Image(systemName: "arrowshape.down")
                }
                .buttonStyle(.tappablePlain)
            }
            .foregroundStyle(Color(white: 0.2))
            .capsuleBorder()
            
            Color.white.opacity(0.6)
                .frame(width: 1)
                .padding(.vertical, 4)
            
            HStack(spacing: 10) {
                Image(systemName: "bubble")
                Text("\(numberComments)")
            }
            .frame(maxHeight: .infinity)
            .foregroundStyle(Color(white: 0.2))
            .capsuleBorder()
        }
        .font(.system(size: 14))
        .frame(height: 30)
        .background {
            RoundedRectangle(cornerSize: CGSize(width: 20, height: 10))
                .foregroundStyle(.white.opacity(0.25))
        }
    }
}

struct CapsuleBorderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay {
                Capsule(style: .continuous).stroke(lineWidth: 1).foregroundStyle(Color(white: 0.9))
            }
    }
}

extension View {
    func capsuleBorder() -> some View {
        self
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .modifier(CapsuleBorderModifier())
    }
}

struct PhotoContentView: View {
    @ObservedObject var viewModel: PostViewModel
    
    var body: some View {
        VStack {
            postImage
//                .frame(maxHeight: .infinity)
                .cornerRadius(20)
        }
//        .background(
//            RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
//                .foregroundStyle(.secondary)
//        )
        .task {
            await viewModel.loadPostImageIfNeeded()
        }
    }
    
    @ViewBuilder var postImage: some View {
        if let size = viewModel.imageSize {
            LazyImageView(image: $viewModel.image, contentMode: .fill) {
                Color.secondary
            }
//            .frame(maxWidth: .infinity)
            .frame(maxHeight: min(size.height / 3, 400))
//            .frame(height: size.height / 3)
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
                .font(.system(size: 17.0, weight: .semibold))
            
            Text(viewModel.attributedBody)
                .font(.system(size: 12))
                .foregroundStyle(Color(white: 0.2))
                .lineLimit(4)
            
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
//    @State private var isHovering = false
    
    var body: some View {
        let _ = Self._printChanges()
        
        ZStack(alignment: .leading) {
//            if isHovering {
//                RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
//                    .foregroundStyle(.white.opacity(0.05))
//            }
            
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
