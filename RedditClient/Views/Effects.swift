//
//  Effects.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 5/7/24.
//

import SwiftUI

#if os(macOS)
struct TranslucentVisualEffect: NSViewRepresentable {
    func makeNSView(context: Context) -> some NSView { NSVisualEffectView() }
    func updateNSView(_ nsView: NSViewType, context: Context) { }
}
#endif
