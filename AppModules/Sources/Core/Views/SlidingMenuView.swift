//
//  SlidingMenuView.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 5/22/24.
//

import SwiftUI

fileprivate extension CGFloat {
    static let sidePanelWidth = 300.0
    static let sidePanelScaleFactor = 0.95
}

public struct SlidingMenuView<SidePanel: View, Content: View>: View {
    private let topBarHeight = 40.0
    
    @State private var isSideMenuOpened = false
    @State private var isDragging = false
    @State private var offsetX = 0.0
    @ViewBuilder var sidePanel: SidePanel
    @ViewBuilder var content: Content
    
    public init(@ViewBuilder sidePanel: () -> SidePanel, @ViewBuilder content: () -> Content) {
        self.sidePanel = sidePanel()
        self.content = content()
    }
    
    public var body: some View {
        ZStack {
            HStack(spacing: 0) {
                VStack {
                    sidePanel
                        .scaleEffect(sidePanelScale)
                }
                .frame(minWidth: .sidePanelWidth, maxHeight: .infinity)
                .animation(.snappy(), value: isSideMenuOpened)
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                TopBarView(barHeight: topBarHeight, isSideMenuOpened: $isSideMenuOpened)
                    .background(Color.white)
                
                HStack {
                    content
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(Color(white: 0.95))
            .shadow(radius: 1)
            .offset(CGSize(width: contentOffsetX, height: 0))
        }
        .gesture(drag, isEnabled: true)
        .frame(maxHeight: .infinity)
        .animation(.snappy(), value: isSideMenuOpened)
        .animation(.snappy(), value: isDragging)
    }
    
    private var drag: some Gesture {
        DragGesture(coordinateSpace: .local)
            .onEnded { value in
                isSideMenuOpened = value.predictedEndLocation.x > 200
                isDragging = false
            }
            .onChanged { value in
                isDragging = true
                offsetX = value.startLocation.x - value.location.x
            }
    }

    private var contentOffsetX: CGFloat {
        if isDragging {
            let limit = isSideMenuOpened ? CGFloat.sidePanelWidth : 0
            return max(0, limit - offsetX)
        }
        if isSideMenuOpened {
            return .sidePanelWidth
        }
        return .zero
    }
    
    private var sidePanelScale: CGSize {
        let scale = if isDragging {
            isSideMenuOpened ?
            1.0 - (1.0 - .sidePanelScaleFactor) * (1.0 - percentage) :
                .sidePanelScaleFactor + (1.0 - .sidePanelScaleFactor) * percentage
        } else {
            isSideMenuOpened ? 1.0 : .sidePanelScaleFactor + (1.0 - .sidePanelScaleFactor) * percentage
        }
        return CGSize(width: scale, height: scale)
    }
    
    private var percentage: CGFloat {
        if isDragging {
            1.0 - abs(.sidePanelWidth - contentOffsetX) / .sidePanelWidth
        } else {
            isSideMenuOpened ? 1.0 : .zero
        }
    }
}

struct TopBarView: View {
    var barHeight: CGFloat = 60
    @Binding var isSideMenuOpened: Bool
    @State private var secondaryMenuOpen = false
    
    var body: some View {
        ZStack {
            HStack {
                HamburgerButtonView(isSideMenuOpened: $isSideMenuOpened)
                Text("Home")
                    .font(.title.bold())
                    .foregroundStyle(.orange)
                Button {
                    secondaryMenuOpen.toggle()
                } label: {
                    Image(systemName: "chevron.down")
                        .foregroundStyle(.gray)
                        .rotationEffect(secondaryMenuOpen ? .degrees(180) : .zero)
                }
//                Menu {
//                    Button("Open in Preview", action: openInPreview)
//                    Button("Save as PDF", action: saveAsPDF)
//                } label: {
//                    Image(systemName: "chevron.down")
//                        .foregroundStyle(.white)
//                        .rotationEffect(secondaryMenuOpen ? .degrees(180) : .zero)
//                }
//                .menuStyle(.button)

                Spacer()
            }
        }
        .padding()
        .frame(maxHeight: barHeight)
    }
    
    func openInPreview() {
        
    }
    
    func saveAsPDF() {
        
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
                        .frame(width: 20, height: 2)
                        .tint(.black)
                }
            }
            .frame(width: 30, height: 30)
            .padding(4)
        }
    }
}

#Preview {
    SlidingMenuView {
        GeometryReader { proxy in
            NavigationStack {
                List {
                    Section {
                        Label(
                            title: { Text("Label") },
                            icon: { Image(systemName: "42.circle") }
                        )
                        .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
                    }
                    
                    Section("Subreddits") {
                        ForEach(1..<20) { number in
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
                .border(.green)
            }
            .frame(width: .sidePanelWidth)
            .border(.red)
        }
    } content: {
        EmptyView()
//        RedditPageView(viewModel: RedditPageViewModel(postsRepository: .preview,
//                                                      subredditRepository: .preview,
//                                                      commentsRepository: .preview,
//                                                      redditorRepository: .preview))
    }
}
