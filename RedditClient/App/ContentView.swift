//
//  ContentView.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 3/26/24.
//

import SwiftUI

struct HighlightStyle: ButtonStyle {
    var isHighlighted: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 5)
            .padding(.horizontal)
            .background(isHighlighted ? Color(white: 1, opacity: 0.15) : Color(white: 1, opacity: 0))
            .foregroundStyle(.primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct HoverButton: View {
    @State private var isHovering = false
    var title: String
    var action: () -> ()
    
    var body: some View {
        Button(action: action, label: {
            HStack(alignment: .top) {
                Text(title)
                    .font(.title2)
            }
        })
        .buttonStyle(HighlightStyle(isHighlighted: isHovering))
        .onHover {
            isHovering = $0
        }
    }
}

struct NavigationContainer<SidePanel: View, Content: View>: View {
    @Environment(\.runningEnvironment.runningOnPhone) private var runningOnPhone
    
    var sidePanel: SidePanel
    var content: Content
    
    init(_ sidePanel: () -> SidePanel, content: () -> Content) {
        self.sidePanel = sidePanel()
        self.content = content()
    }
    
    var body: some View {
        if runningOnPhone {
            SlidingMenuView {
                sidePanel
            } content: {
                content
            }
        } else {
            NavigationSplitView {
                sidePanel
            } detail: {
                content
            }
        }
    }
}

struct ContentView: View {
    @Environment(\.dependencies.postsViewModel) private var postsViewModel
    @Environment(\.dependencies.subredditRepository) private var subredditRepository
    @EnvironmentObject private var navigationModel: NavigationModel
    
    private var predefinedSubreddits: [RedditPage] = [
        .home,
        .subreddit(name: "apple"),
        .subreddit(name: "ios")
    ]
    
    var body: some View {
        NavigationContainer {
            List(predefinedSubreddits, selection: $navigationModel.selectedSubreddit) { sub in
                NavigationLink(sub.title, value: sub)
                    .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
            }
            .navigationTitle("Subreddits")
        } content: {
            RedditPageView(viewModel: postsViewModel)
        }
        .navigationSplitViewStyle(.prominentDetail)
    }
}

#Preview {
    ContentView()
        .environmentObject(NavigationModel(columnVisibility: .detailOnly))
}
