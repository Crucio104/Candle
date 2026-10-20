import SwiftUI
import UIKit

/// Minimal and elegant design system for Candle
@MainActor
public enum CandleTheme {
    // Adaptive background and card tones for Light and Dark modes
    public static let background = Color(uiColor: .systemGroupedBackground)
    public static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    public static let subCardBackground = Color(uiColor: .tertiarySystemGroupedBackground)
    
    // Curated avatar gradient color pairs (12 vibrant and harmonious themes)
    public static let avatarColorPairs: [(primary: Color, secondary: Color)] = [
        (Color(red: 0.98, green: 0.62, blue: 0.26), Color(red: 0.99, green: 0.44, blue: 0.35)), // 0: Amber / Coral
        (Color(red: 0.43, green: 0.68, blue: 0.98), Color(red: 0.35, green: 0.49, blue: 0.96)), // 1: Ocean Blue
        (Color(red: 0.58, green: 0.44, blue: 0.89), Color(red: 0.82, green: 0.47, blue: 0.91)), // 2: Lavender / Purple
        (Color(red: 0.30, green: 0.81, blue: 0.67), Color(red: 0.20, green: 0.68, blue: 0.73)), // 3: Mint / Emerald
        (Color(red: 0.95, green: 0.42, blue: 0.54), Color(red: 0.96, green: 0.65, blue: 0.48)), // 4: Rose / Peach
        (Color(red: 0.89, green: 0.72, blue: 0.36), Color(red: 0.81, green: 0.53, blue: 0.26)), // 5: Honey / Gold
        (Color(red: 0.91, green: 0.20, blue: 0.48), Color(red: 0.72, green: 0.12, blue: 0.58)), // 6: Ruby / Magenta
        (Color(red: 0.38, green: 0.36, blue: 0.96), Color(red: 0.22, green: 0.22, blue: 0.85)), // 7: Electric Indigo
        (Color(red: 0.08, green: 0.78, blue: 0.82), Color(red: 0.05, green: 0.56, blue: 0.72)), // 8: Cyan / Aqua
        (Color(red: 0.52, green: 0.84, blue: 0.25), Color(red: 0.25, green: 0.72, blue: 0.42)), // 9: Lime / Spring
        (Color(red: 1.00, green: 0.52, blue: 0.12), Color(red: 0.98, green: 0.32, blue: 0.20)), // 10: Solar Tangerine
        (Color(red: 0.55, green: 0.60, blue: 0.68), Color(red: 0.35, green: 0.40, blue: 0.48))  // 11: Platinum / Slate
    ]
    
    public static func avatarGradient(for index: Int) -> LinearGradient {
        let safeIndex = abs(index) % avatarColorPairs.count
        let pair = avatarColorPairs[safeIndex]
        return LinearGradient(
            colors: [pair.primary, pair.secondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    public static func avatarPrimaryColor(for index: Int) -> Color {
        let safeIndex = abs(index) % avatarColorPairs.count
        return avatarColorPairs[safeIndex].primary
    }
    
    public static func avatarSecondaryColor(for index: Int) -> Color {
        let safeIndex = abs(index) % avatarColorPairs.count
        return avatarColorPairs[safeIndex].secondary
    }
    
    // MARK: - Haptic Feedback Helpers
    public static func hapticSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    public static func hapticImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    public static func hapticNotification(type: UINotificationFeedbackGenerator.FeedbackType = .success) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}

extension View {
    public func candleCardStyle() -> some View {
        self
            .background(CandleTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.primary.opacity(0.04), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
}
