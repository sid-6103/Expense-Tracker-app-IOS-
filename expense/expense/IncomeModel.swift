import Foundation

// MARK: - Income Categories
enum IncomeCategory: String, CaseIterable, Identifiable {
    case salary = "Salary"
    case bonus = "Bonus"
    case investment = "Investment"
    case freelance = "Freelance"
    case gift = "Gift"
    case business = "Business"
    case other = "Other"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .salary: return "dollarsign.circle.fill"
        case .bonus: return "star.circle.fill"
        case .investment: return "chart.line.uptrend.xyaxis.circle.fill"
        case .freelance: return "briefcase.circle.fill"
        case .gift: return "gift.circle.fill"
        case .business: return "building.2.circle.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .salary: return "green"
        case .bonus: return "yellow"
        case .investment: return "blue"
        case .freelance: return "purple"
        case .gift: return "pink"
        case .business: return "indigo"
        case .other: return "gray"
        }
    }

    // Emoji used for category display in lists
    var emoji: String {
        switch self {
        case .salary: return "💰"
        case .bonus: return "⭐"
        case .investment: return "📈"
        case .freelance: return "💼"
        case .gift: return "🎁"
        case .business: return "🏢"
        case .other: return "⚪️"
        }
    }
}

// MARK: - Income Model
struct IncomeItem: Identifiable {
    let id: UUID
    var amount: Double
    var category: IncomeCategory
    var categoryName: String
    var date: Date
    var notes: String?
    
    init(id: UUID = UUID(), amount: Double, category: IncomeCategory, categoryName: String, date: Date, notes: String? = nil) {
        self.id = id
        self.amount = amount
        self.category = category
        self.categoryName = categoryName
        self.date = date
        self.notes = notes
    }
}

// MARK: - Income Statistics
struct IncomeStatistics {
    let totalToday: Double
    let totalThisWeek: Double
    let totalThisMonth: Double
    let categoryBreakdown: [IncomeCategory: Double]
    
    /// referenceDate lets the caller compute "today/week/month" relative to a chosen day (e.g., custom filter)
    init(incomes: [IncomeItem], referenceDate: Date = Date()) {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: referenceDate)
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: referenceDate)?.start ?? day
        let monthStart = calendar.dateInterval(of: .month, for: referenceDate)?.start ?? day
        
        totalToday = incomes
            .filter { calendar.isDate($0.date, inSameDayAs: day) }
            .reduce(0) { $0 + $1.amount }
        
        totalThisWeek = incomes
            .filter { $0.date >= weekStart && $0.date < (calendar.date(byAdding: .weekOfYear, value: 1, to: weekStart) ?? Date.distantFuture) }
            .reduce(0) { $0 + $1.amount }
        
        totalThisMonth = incomes
            .filter { $0.date >= monthStart && $0.date < (calendar.date(byAdding: .month, value: 1, to: monthStart) ?? Date.distantFuture) }
            .reduce(0) { $0 + $1.amount }
        
        // Category breakdown for the provided set
        var breakdown: [IncomeCategory: Double] = [:]
        for category in IncomeCategory.allCases {
            breakdown[category] = incomes
                .filter { $0.category == category }
                .reduce(0) { $0 + $1.amount }
        }
        categoryBreakdown = breakdown
    }
}
