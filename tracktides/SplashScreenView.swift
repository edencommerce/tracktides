import SwiftUI
import UIKit

struct SplashScreenView: View {
    @Environment(\.colorScheme) private var colorScheme

    private let backgroundColor = Color(UIColor.systemBackground)

    @State private var rotation: Double = 0
    @State private var scale: Double = 0.8
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            logoImage
                .rotationEffect(.degrees(rotation))
                .scaleEffect(scale)
                .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                opacity = 1
                scale = 1
            }

            withAnimation(
                .linear(duration: 2)
                    .repeatForever(autoreverses: false)
            ) {
                rotation = 360
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var logoImage: some View {
        let base = Image("Logo")
            .resizable()
            .scaledToFit()
            .frame(width: 120, height: 120)

        if colorScheme == .dark {
            base.colorInvert()
        } else {
            base
        }
    }
}

#Preview {
    SplashScreenView()
}
