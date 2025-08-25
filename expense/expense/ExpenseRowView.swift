import SwiftUI

struct ExpenseRowView: View {
    let expense: ExpenseItem
    let viewModel: ExpenseViewModel
    @State private var showingEditSheet = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @State private var refreshToken: Int = 0
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Emoji (matches Add screen selections)
            ZStack {
                Circle()
                    .fill(AppColors.chip(colorScheme == .dark))
                    .frame(width: 40, height: 40)
                
                Text(viewModel.resolvedEmoji(for: expense))
                    .font(.system(size: 20))
            }
            
            // Expense Details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(expense.categoryName)
                        .font(.headline)
                        .foregroundColor(viewModel.resolvedCategoryTint(for: expense, isDark: colorScheme == .dark))
                    
                    Spacer()
                    
                    Text(viewModel.formatCurrency(expense.amount))
                        .font(.headline)
                        .foregroundColor(viewModel.resolvedCategoryTint(for: expense, isDark: colorScheme == .dark))
                }
                
                HStack {
                    Text(viewModel.formatDate(expense.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let notes = expense.notes, !notes.isEmpty {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Text(viewModel.formatTime(expense.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .id(refreshToken)
        .onTapGesture {
            showingEditSheet = true
        }
        .sheet(isPresented: $showingEditSheet) {
            EditExpenseView(expense: expense, viewModel: viewModel)
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange, object: viewContext)) { _ in
            refreshToken &+= 1
        }
    }
}

struct EditExpenseView: View {
    let expense: ExpenseItem
    let viewModel: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount: String
    @State private var selectedCategory: ExpenseCategory
    @State private var selectedDate: Date
    @State private var notes: String
    @State private var showingDeleteAlert = false
    
    init(expense: ExpenseItem, viewModel: ExpenseViewModel) {
        self.expense = expense
        self.viewModel = viewModel
        self._amount = State(initialValue: String(expense.amount))
        self._selectedCategory = State(initialValue: expense.category)
        self._selectedDate = State(initialValue: expense.date)
        self._notes = State(initialValue: expense.notes ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Expense Details")) {
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ExpenseCategory.allCases) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(Color(category.color))
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    
                    DatePicker("Date", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("Additional Information")) {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Button("Update Expense") {
                        updateExpense()
                    }
                    .disabled(amount.isEmpty || Double(amount) == 0)
                    
                    Button("Delete Expense", role: .destructive) {
                        showingDeleteAlert = true
                    }
                }
            }
            .navigationTitle("Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Delete Expense", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deleteExpense()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this expense? This action cannot be undone.")
            }
        }
    }
    
    private func updateExpense() {
        guard let amountValue = Double(amount), amountValue > 0 else { return }
        
        viewModel.updateExpense(
            expense,
            amount: amountValue,
            category: selectedCategory,
            date: selectedDate,
            notes: notes.isEmpty ? nil : notes
        )
        
        dismiss()
    }
    
    private func deleteExpense() {
        viewModel.deleteExpense(expense)
        dismiss()
    }
}

#Preview {
    ExpenseRowView(
        expense: ExpenseItem(
            amount: 25.50,
            category: .food,
            categoryName: "Food",
            date: Date(),
            notes: "Lunch at restaurant"
        ),
        viewModel: ExpenseViewModel(context: PersistenceController.preview.container.viewContext)
    )
}


