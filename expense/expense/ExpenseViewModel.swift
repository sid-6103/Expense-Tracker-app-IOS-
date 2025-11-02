import Foundation
import CoreData
import SwiftUI

class ExpenseViewModel: ObservableObject {
    @Published var expenses: [ExpenseItem] = []
    @Published var selectedCategory: ExpenseCategory = .other
    @Published var searchText = ""
    @Published var showingAddExpense = false
    @Published var selectedTimeFilter: TimeFilter = .all
    @Published var showingDatePicker = false
    @Published var selectedCustomDate: Date?
    
    private let viewContext: NSManagedObjectContext
    
    enum TimeFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case today = "Today"
        case custom = "Custom"
        
        var id: String { self.rawValue }
    }
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchExpenses()
    }
    
    // MARK: - Core Data Operations
    
    func fetchExpenses() {
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Expense.date, ascending: false)]
        
        do {
            let coreDataExpenses = try viewContext.fetch(request)
            expenses = coreDataExpenses.map { coreDataExpense in
                let name = coreDataExpense.category ?? "Other"
                let enumCat = ExpenseCategory(rawValue: name) ?? .other
                return ExpenseItem(
                    id: coreDataExpense.id ?? UUID(),
                    amount: coreDataExpense.amount,
                    category: enumCat,
                    categoryName: name,
                    date: coreDataExpense.date ?? Date(),
                    notes: coreDataExpense.notes
                )
            }
        } catch {
            print("Error fetching expenses: \(error)")
        }
    }
    
    func addExpense(amount: Double, categoryName: String, date: Date, notes: String?) {
        let newExpense = Expense(context: viewContext)
        newExpense.id = UUID()
        newExpense.amount = amount
        newExpense.category = categoryName
        newExpense.date = date
        newExpense.notes = notes
        
        saveContext()
    }
    
    func updateExpense(_ expense: ExpenseItem, amount: Double, category: ExpenseCategory, date: Date, notes: String?) {
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", expense.id as CVarArg)
        
        do {
            let results = try viewContext.fetch(request)
            if let expenseToUpdate = results.first {
                expenseToUpdate.amount = amount
                expenseToUpdate.category = category.rawValue
                expenseToUpdate.date = date
                expenseToUpdate.notes = notes
                saveContext()
            }
        } catch {
            print("Error updating expense: \(error)")
        }
    }
    
    func deleteExpense(_ expense: ExpenseItem) {
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", expense.id as CVarArg)
        
        do {
            let results = try viewContext.fetch(request)
            if let expenseToDelete = results.first {
                viewContext.delete(expenseToDelete)
                saveContext()
            }
        } catch {
            print("Error deleting expense: \(error)")
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
            fetchExpenses()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    // MARK: - Filters & Statistics
    var filteredExpenses: [ExpenseItem] {
        var filtered = expenses
        
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
        
        // Category filter (only when not "All Categories")
        if selectedCategory != .other {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        // Search
        if !searchText.isEmpty {
            filtered = filtered.filter { expense in
                expense.notes?.localizedCaseInsensitiveContains(searchText) == true ||
                expense.categoryName.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        return filtered
    }
    
    var statistics: ExpenseStatistics {
        // Use selectedCustomDate as reference when in custom filter so header aligns with selected period
        if selectedTimeFilter == .custom, let ref = selectedCustomDate {
            return ExpenseStatistics(expenses: expenses, referenceDate: ref)
        }
        return ExpenseStatistics(expenses: expenses)
    }
    var filteredStatistics: ExpenseStatistics {
        if selectedTimeFilter == .custom, let ref = selectedCustomDate {
            return ExpenseStatistics(expenses: filteredExpenses, referenceDate: ref)
        }
        return ExpenseStatistics(expenses: filteredExpenses)
    }
    
    // MARK: - Category Rendering
    func resolvedCategoryTint(for expense: ExpenseItem, isDark: Bool) -> Color {
        guard isDark else { return .primary }
        let req: NSFetchRequest<Category> = Category.fetchRequest()
        req.predicate = NSPredicate(format: "name ==[c] %@", expense.categoryName)
        req.fetchLimit = 1
        if let match = try? viewContext.fetch(req).first {
            if let hex = match.colorHex, let color = Color(hex: hex) { return color }
            if let emoji = match.emoji, let approx = Color(emojiApprox: emoji) { return approx }
        }
        return AppColors.categoryTint(expense.category, isDark: true)
    }
    
    func resolvedEmoji(for expense: ExpenseItem) -> String {
        let req: NSFetchRequest<Category> = Category.fetchRequest()
        req.predicate = NSPredicate(format: "name ==[c] %@", expense.categoryName)
        req.fetchLimit = 1
        if let match = try? viewContext.fetch(req).first, let e = match.emoji, !e.isEmpty {
            return e
        }
        return expense.category.emoji
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

// MARK: - Color helpers
extension Color {
    init?(hex: String) {
        var s = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if s.count == 3 { s = s.map { "\($0)\($0)" }.joined() }
        guard s.count == 6 || s.count == 8 else { return nil }
        var value: UInt64 = 0
        Scanner(string: s).scanHexInt64(&value)
        let a, r, g, b: Double
        if s.count == 8 {
            a = Double((value & 0xFF000000) >> 24) / 255
        } else { a = 1 }
        r = Double((value & 0x00FF0000) >> 16) / 255
        g = Double((value & 0x0000FF00) >> 8) / 255
        b = Double(value & 0x000000FF) / 255
        self = Color(red: r, green: g, blue: b, opacity: a)
    }
    
    init?(emojiApprox: String) {
        let e = emojiApprox
        if e.contains("🚗") { self = .red; return }
        if e.contains("🍽") { self = .gray; return }
        if e.contains("🛍") { self = Color(red: 1.0, green: 0.70, blue: 0.85); return }
        if e.contains("🧾") { self = .white; return }
        if e.contains("📺") { self = .cyan; return }
        if e.contains("❤️") { self = Color(red: 1.0, green: 0.70, blue: 0.85); return }
        if e.contains("⚪") { self = .secondary; return }
        return nil
    }
}
