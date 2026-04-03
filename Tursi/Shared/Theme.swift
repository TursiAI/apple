import SwiftUI

/// Tursi design tokens.
enum TursiTheme {
    // MARK: - Colors
    static let accent = Color.blue
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary

    // MARK: - Spacing
    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 16
    static let paddingLarge: CGFloat = 24

    // MARK: - Radii
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 18
}
