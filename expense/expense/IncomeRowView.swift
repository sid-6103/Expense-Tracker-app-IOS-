import SwiftUI

struct IncomeRowView: View {
    let income: IncomeItem
    let viewModel: IncomeViewModel
    @State private var showingEditSheet = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Emoji
            ZStack {
                Circle()
                    .fill(Color(income.category.color))
                    .frame(width: 40, height: 40)
                
                Text(income.category.emoji)
                    .font(.system(size: 20))
            }
            
            // Income Details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(income.categoryName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(viewModel.formatCurrency(income.amount))
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Text(viewModel.formatDate(income.date))
                        .font(.caption)
                        .foregroundColor(.primary)
                    
                    if let notes = income.notes, !notes.isEmpty {
                        Text("•")
                            .foregroundColor(.primary)
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Text(viewModel.formatTime(income.date))
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            showingEditSheet = true
        }
        .sheet(isPresented: $showingEditSheet) {
            EditIncomeView(income: income, viewModel: viewModel)
        }
    }
}

struct EditIncomeView: View {
    let income: IncomeItem
    let viewModel: IncomeViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount: String
    @State private var selectedCategory: IncomeCategory
    @State private var selectedDate: Date
    @State private var notes: String
    @State private var showingDeleteAlert = false
    
    init(income: IncomeItem, viewModel: IncomeViewModel) {
        self.income = income
        self.viewModel = viewModel
        self._amount = State(initialValue: String(income.amount))
        self._selectedCategory = State(initialValue: income.category)
        self._selectedDate = State(initialValue: income.date)
        self._notes = State(initialValue: income.notes ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Income Details")) {
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(IncomeCategory.allCases) { category in
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
                    Button("Update Income") {
                        updateIncome()
                    }
                    .disabled(amount.isEmpty || Double(amount) == 0)
                    
                    Button("Delete Income", role: .destructive) {
                        showingDeleteAlert = true
                    }
                }
            }
            .navigationTitle("Edit Income")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Delete Income", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deleteIncome()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this income? This action cannot be undone.")
            }
        }
    }
    
    private func updateIncome() {
        guard let amountValue = Double(amount), amountValue > 0 else { return }
        
        viewModel.updateIncome(
            income,
            amount: amountValue,
            category: selectedCategory,
            date: selectedDate,
            notes: notes.isEmpty ? nil : notes
        )
        
        dismiss()
    }
    
    private func deleteIncome() {
        viewModel.deleteIncome(income)
        dismiss()
    }
}

#Preview {
    IncomeRowView(
        income: IncomeItem(
            amount: 5000.0,
            category: .salary,
            categoryName: "Salary",
            date: Date(),
            notes: "Monthly salary"
        ),
        viewModel: IncomeViewModel()
    )
}
