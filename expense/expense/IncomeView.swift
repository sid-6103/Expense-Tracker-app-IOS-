import SwiftUI

struct IncomeView: View {
    @ObservedObject var viewModel: IncomeViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var amount: String = ""
    @State private var selectedCategory: IncomeCategory = .salary
    @State private var selectedDate: Date = Date()
    @State private var notes: String = ""
    
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
            }
            .navigationTitle("Add Income")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveIncome()
                    }
                    .disabled(amount.isEmpty || Double(amount) == 0)
                }
            }
        }
    }
    
    private func saveIncome() {
        guard let amountValue = Double(amount), amountValue > 0 else { return }
        
        viewModel.addIncome(
            amount: amountValue,
            category: selectedCategory,
            date: selectedDate,
            notes: notes.isEmpty ? nil : notes
        )
        
        dismiss()
    }
}



#Preview {
    IncomeView(viewModel: IncomeViewModel())
}
