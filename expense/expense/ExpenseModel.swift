import Foundation

// MARK: - Expense Categories
enum ExpenseCategory: String, CaseIterable, Identifiable {
    case food = "Food"
    case travel = "Travel"
    case shopping = "Shopping"
    case bills = "Bills"
    case entertainment = "Entertainment"
    case health = "Health"
    case other = "Other"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .travel: return "car"
        case .shopping: return "bag"
        case .bills: return "doc.text"
        case .entertainment: return "tv"
        case .health: return "heart"
        case .other: return "ellipsis.circle"
        }
    }
    
    var color: String {
        switch self {
        case .food: return "orange"
        case .travel: return "blue"
        case .shopping: return "purple"
        case .bills: return "red"
        case .entertainment: return "green"
        case .health: return "pink"
        case .other: return "gray"
        }
    }

    // Emoji used for category display in lists
    var emoji: String {
        switch self {
        case .food: return "🍽️"
        case .travel: return "🚗"
        case .shopping: return "🛍️"
        case .bills: return "🧾"
        case .entertainment: return "📺"
        case .health: return "❤️"
        case .other: return "⚪️"
        }
    }
}

// MARK: - Expense Model
struct ExpenseItem: Identifiable {
    let id: UUID
    var amount: Double
    var category: ExpenseCategory
    var categoryName: String
    var date: Date
    var notes: String?
    
    init(id: UUID = UUID(), amount: Double, category: ExpenseCategory, categoryName: String, date: Date, notes: String? = nil) {
        self.id = id
        self.amount = amount
        self.category = category
        self.categoryName = categoryName
        self.date = date
        self.notes = notes
    }
}

// MARK: - Expense Statistics
struct ExpenseStatistics {
    let totalToday: Double
    let totalThisWeek: Double
    let totalThisMonth: Double
    let categoryBreakdown: [ExpenseCategory: Double]
    
    /// referenceDate lets the caller compute "today/week/month" relative to a chosen day (e.g., custom filter)
    init(expenses: [ExpenseItem], referenceDate: Date = Date()) {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: referenceDate)
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: referenceDate)?.start ?? day
        let monthStart = calendar.dateInterval(of: .month, for: referenceDate)?.start ?? day
        
        totalToday = expenses
            .filter { calendar.isDate($0.date, inSameDayAs: day) }
            .reduce(0) { $0 + $1.amount }
        
        totalThisWeek = expenses
            .filter { $0.date >= weekStart && $0.date <= calendar.date(byAdding: .day, value: 1, to: day)?.addingTimeInterval(24*60*60*6) ?? Date.distantFuture }
            .reduce(0) { $0 + $1.amount }
        
        totalThisMonth = expenses
            .filter { $0.date >= monthStart && $0.date < (calendar.date(byAdding: .month, value: 1, to: monthStart) ?? Date.distantFuture) }
            .reduce(0) { $0 + $1.amount }
        
        // Category breakdown for the provided set
        var breakdown: [ExpenseCategory: Double] = [:]
        for category in ExpenseCategory.allCases {
            breakdown[category] = expenses
                .filter { $0.category == category }
                .reduce(0) { $0 + $1.amount }
        }
        categoryBreakdown = breakdown
    }
}


