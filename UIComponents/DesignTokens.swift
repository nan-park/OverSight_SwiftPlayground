import SwiftUI

// MARK: - Spacing

enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius

enum CornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
}

// MARK: - Typography

extension Font {
    static let displayLarge: Font = .system(size: 34, weight: .bold)
    static let displayMedium: Font = .system(size: 28, weight: .bold)
    static let titleLarge: Font = .system(size: 22, weight: .semibold)
    static let titleMedium: Font = .system(size: 17, weight: .semibold)
    static let bodyLarge: Font = .system(size: 17, weight: .regular)
    static let bodyMedium: Font = .system(size: 15, weight: .regular)
    static let caption: Font = .system(size: 13, weight: .regular)
}
