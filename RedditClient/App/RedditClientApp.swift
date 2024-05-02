//
//  RedditClientApp.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 3/26/24.
//

import SwiftUI

@main
struct RedditClientApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(TranslucentVisualEffect().ignoresSafeArea())
        }
        .windowStyle(.hiddenTitleBar)
    }
}

struct TranslucentVisualEffect: NSViewRepresentable {
    func makeNSView(context: Context) -> some NSView { NSVisualEffectView() }
    func updateNSView(_ nsView: NSViewType, context: Context) { }
}
