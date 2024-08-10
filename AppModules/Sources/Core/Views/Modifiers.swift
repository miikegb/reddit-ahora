//
//  Modifiers.swift
//  RedditClient
//
//  Created by Miguel Gonzalez on 4/26/24.
//

import SwiftUI

struct RoundedCorners: ViewModifier {
    let cornerSize: Int
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: cornerSize, height: cornerSize)))
    }
}

extension View {
    func cornerRadius(_ size: Int) -> some View {
        modifier(RoundedCorners(cornerSize: size))
    }
}

struct Modifiers: View {
    var body: some View {
        Group {
            Color.accentColor
                .cornerRadius(15)
        }
        .padding()
    }
}

public struct TappablePlainButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? CGSize(width: 1.4, height: 1.4) : CGSize(width: 1.0, height: 1.0))
    }
}

extension ButtonStyle where Self == TappablePlainButtonStyle {
    public static var tappablePlain: Self {
        TappablePlainButtonStyle()
    }
}

#Preview {
    Modifiers()
}
