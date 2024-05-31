//
//  SlidingMenuView.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 5/22/24.
//

import SwiftUI

struct SlidingMenuView<SidePanel: View, Content: View>: View {
    private let sidePanelWidth = 200.0
    private let topBarHeight = 40.0
    
    @State private var isSideMenuOpened = false
    var sidePanel: SidePanel
    var content: Content
    
    init(sidePanel: () -> SidePanel, content: () -> Content) {
        self.sidePanel = sidePanel()
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                VStack {
                    sidePanel
                        .offset(CGSize(width: isSideMenuOpened ? 0 : -50.0, height: 0))
                }
                .frame(minWidth: sidePanelWidth, maxHeight: .infinity)
                .animation(.spring(), value: isSideMenuOpened)
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                TopBarView(barHeight: topBarHeight, isSideMenuOpened: $isSideMenuOpened)
                    .background(.purple)
                
                HStack {
                    content
                }
                .frame(maxWidth: .infinity)
            }
            .background(.white)
            .shadow(radius: 1)
            .offset(CGSize(width: isSideMenuOpened ? sidePanelWidth : 0, height: 0))
        }
        .frame(maxHeight: .infinity)
        .animation(.snappy(), value: isSideMenuOpened)
    }
}

struct TopBarView: View {
    var barHeight: CGFloat = 60
    @Binding var isSideMenuOpened: Bool
    
    var body: some View {
        ZStack {
            HStack {
                HamburgerButtonView(isSideMenuOpened: $isSideMenuOpened)
                Spacer()
            }
            Text("Home")
                .font(.title.bold())
                .foregroundStyle(.white)
        }
        .padding()
        .frame(maxHeight: barHeight)
    }
}

struct HamburgerButtonView: View {
    @Binding var isSideMenuOpened: Bool
    
    var body: some View {
        Button {
            isSideMenuOpened.toggle()
        } label: {
            VStack(spacing: 5) {
                ForEach(0..<3) { _ in
                    Capsule()
                        .frame(height: 5)
                        .tint(.white)
                }
            }
            .frame(width: 30, height: 30)
            .padding(4)
        }
    }
}

#Preview {
    SlidingMenuView {
        List {
            Section {
                Label(
                    title: { Text("Label") },
                    icon: { Image(systemName: "42.circle") }
                )
                .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
            }
            
            Section("Subreddits") {
                ForEach(1..<6) { number in
                    Button {
                        print("Tapped menu button: \(number)")
                    } label: {
                        Text("Menu Item \(number)")
                    }
                    .buttonStyle(.tappablePlain)
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    } content: {
        RedditPageView(viewModel: RedditPageViewModel(postsRepository: PreviewPostsRepository(),
                                                subredditRepository: PreviewSubredditRepository()))
    }
}
