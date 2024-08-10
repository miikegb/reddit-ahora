//
//  PostDetailsView.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 6/2/24.
//

import SwiftUI
import Core

struct PostDetailsView: View {
    @ObservedObject var viewModel: PostViewModel
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8.0) {
                    PostHeader(viewModel: viewModel, showRedditor: true)
                    
                    Text(viewModel.attributedTitle)
                        .font(.title3.bold())
                    
                    Text(viewModel.attributedBody)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if viewModel.postHint == "image" {
                        PhotoContentView(viewModel: viewModel)
                    }
                }
                
                LazyVStack {
                    ForEach(viewModel.comments, id: \.id) {
                        CommentView(viewModel: $0)
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadComments()
        }
        .padding()
    }
}

struct CommentView: View {
    @ObservedObject var viewModel: CommentViewModel
    
    var body: some View {
        VStack {
            HStack {
                LazyImageView(image: $viewModel.avatar) {
                    Circle()
                        .fill(.purple)
                }
                .frame(width: 30, height: 30)
                .clipShape(Circle())
                .overlay(.purple, in: Circle().stroke(style: StrokeStyle(lineWidth: 2)))

                Text(viewModel.author)
                    .font(.subheadline)
                    .foregroundStyle(Color.accentColor)
                Text(viewModel.postedDateString)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            HStack {
                Text(viewModel.attributedBody)
                    .font(.footnote)
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.top)
        .onAppear {
            viewModel.loadAuthorAvatar()
        }
    }
}

#Preview {
    PostDetailsView(viewModel:
                        PostViewModel(post: PreviewData.previewPosts[0],
                                      subredditRepository: .preview,
                                      commentsRepo: .preview,
                                      redditorRepo: .preview)
    )
}
