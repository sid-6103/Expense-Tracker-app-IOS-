import Foundation
import SwiftUI

class IncomeViewModel: ObservableObject {
    @Published var incomes: [IncomeItem] = []
    @Published var selectedCategory: IncomeCategory = .other
    @Published var searchText = ""
    @Published var selectedTimeFilter: TimeFilter = .all
    @Published var showingDatePicker = false
    @Published var selectedCustomDate: Date?
    
    enum TimeFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case today = "Today"
        case custom = "Custom"
        
        var id: String { self.rawValue }
    }
    
    init() {
        // For now, we'll use sample data since we don't have Core Data for income yet
        loadSampleData()
    }
    
    // MARK: - Sample Data (temporary until Core Data integration)
    private func loadSampleData() {
        incomes = [
            IncomeItem(amount: 5000.0, category: .salary, categoryName: "Salary", date: Date(), notes: "Monthly salary"),
            IncomeItem(amount: 500.0, category: .bonus, categoryName: "Bonus", date: Date().addingTimeInterval(-86400), notes: "Performance bonus"),
            IncomeItem(amount: 200.0, category: .freelance, categoryName: "Freelance", date: Date().addingTimeInterval(-172800), notes: "Web design project")
        ]
    }
    
    // MARK: - Income Operations
    
    func addIncome(amount: Double, category: IncomeCategory, date: Date, notes: String?) {
        let newIncome = IncomeItem(
            amount: amount,
            category: category,
            categoryName: category.rawValue,
            date: date,
            notes: notes
        )
        incomes.append(newIncome)
        // Sort by date (newest first)
        incomes.sort { $0.date > $1.date }
    }
    
    func updateIncome(_ income: IncomeItem, amount: Double, category: IncomeCategory, date: Date, notes: String?) {
        if let index = incomes.firstIndex(where: { $0.id == income.id }) {
            incomes[index] = IncomeItem(
                id: income.id,
                amount: amount,
                category: category,
                categoryName: category.rawValue,
                date: date,
                notes: notes
            )
            // Sort by date (newest first)
            incomes.sort { $0.date > $1.date }
        }
    }
    
    func deleteIncome(_ income: IncomeItem) {
        incomes.removeAll { $0.id == income.id }
    }
    
    // MARK: - Filters & Statistics
    var filteredIncomes: [IncomeItem] {
        var filtered = incomes
        
        // Time filter
        switch selectedTimeFilter {
        case .today:
            let calendar = Calendar.current
            filtered = filtered.filter { calendar.isDateInToday($0.date) }
        case .custom:
            if let customDate = selectedCustomDate {
                let calendar = Calendar.current
                filtered = filtered.filter { calendar.isDate($0.date, inSameDayAs: customDate) }
            }
        case .all:
            break
        }
        
        // Category filter (only when not "Other")
        if selectedCategory != .other {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        // Search
        if !searchText.isEmpty {
            filtered = filtered.filter { income in
                income.notes?.localizedCaseInsensitiveContains(searchText) == true ||
                income.categoryName.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        return filtered
    }
    
    var statistics: IncomeStatistics {
        if selectedTimeFilter == .custom, let ref = selectedCustomDate {
            return IncomeStatistics(incomes: incomes, referenceDate: ref)
        }
        return IncomeStatistics(incomes: incomes)
    }
    var filteredStatistics: IncomeStatistics {
        if selectedTimeFilter == .custom, let ref = selectedCustomDate {
            return IncomeStatistics(incomes: filteredIncomes, referenceDate: ref)
        }
        return IncomeStatistics(incomes: filteredIncomes)
    }
    
    // MARK: - Formatting
    func formatCurrency(_ amount: Double) -> String {
        let symbol = UserDefaults.standard.string(forKey: "currencySymbol") ?? "₹"
        let formatted = String(format: "%.2f", amount)
        return "\(symbol)\(formatted)"
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
