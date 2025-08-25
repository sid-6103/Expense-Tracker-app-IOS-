import SwiftUI

enum AppColors {
    static func tint(_ isDark: Bool) -> Color {
        isDark ? Color.indigo : Color.blue
    }
    
    static func surface(_ isDark: Bool) -> Color {
        isDark ? Color(red: 0.12, green: 0.12, blue: 0.14) : Color(.systemBackground)
    }
    
    static func surfaceAlt(_ isDark: Bool) -> Color {
        isDark ? Color(red: 0.17, green: 0.17, blue: 0.20) : Color(.systemGray6)
    }
    
    static func chip(_ isDark: Bool) -> Color {
        isDark ? Color.white.opacity(0.06) : Color(.systemGray5)
    }
    
    static func headerGradient(_ isDark: Bool) -> [Color] {
        isDark
        ? [Color(red: 0.18, green: 0.18, blue: 0.22), Color(red: 0.12, green: 0.12, blue: 0.14)]
        : [Color(.systemGray6), Color(.systemBackground)]
    }

    // Category-specific tint used for text in dark mode list rows
    static func categoryTint(_ category: ExpenseCategory, isDark: Bool) -> Color {
        guard isDark else { return .primary }
        switch category {
        case .travel:
            return .red // matches 🚗
        case .food:
            return .gray // subtle gray like 🍽️ plate
        case .shopping:
            return Color(red: 1.0, green: 0.70, blue: 0.85) // light pink for 🛍️
        case .bills:
            return .white // receipt 🧾
        case .entertainment:
            return .cyan // sky blue tone for 📺 highlight
        case .health:
            return .pink // pink for ❤️
        case .other:
            return .secondary
        }
    }
}
