import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var categoryManager: CategoryManager
    @ObservedObject var viewModel: ExpenseViewModel
    
    @State private var amount: String = ""
    @State private var selectedCategoryObj: Category?
    @State private var selectedDate = Date()
    @State private var notes: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(viewModel: ExpenseViewModel) {
        self.viewModel = viewModel
        _categoryManager = StateObject(wrappedValue: CategoryManager(context: PersistenceController.shared.container.viewContext))
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
                    
                    Picker("Category", selection: Binding(get: {
                        selectedCategoryObj ?? categoryManager.categories.first
                    }, set: { newValue in
                        selectedCategoryObj = newValue
                    })) {
                        ForEach(categoryManager.categories, id: \.id) { cat in
                            HStack {
                                Text(cat.emoji?.isEmpty == false ? cat.emoji! : "🗂️")
                                Text(cat.name ?? "")
                            }.tag(Optional(cat))
                        }
                    }
                    
                    DatePicker("Date", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                }
                .listRowBackground(AppColors.surfaceAlt(colorScheme == .dark))
                
                Section(header: Text("Additional Information")) {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                .listRowBackground(AppColors.surfaceAlt(colorScheme == .dark))
                
                Section {
                    Button(action: saveExpense) {
                        HStack {
                            Spacer()
                            Text("Save Expense")
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .disabled(amount.isEmpty || Double(amount) == 0 || selectedCategoryObj == nil)
                }
                .listRowBackground(AppColors.surfaceAlt(colorScheme == .dark))
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(AppColors.surface(colorScheme == .dark))
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .toolbarBackground(AppColors.surface(colorScheme == .dark), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                if selectedCategoryObj == nil { selectedCategoryObj = categoryManager.categories.first }
            }
        }
        .background(AppColors.surface(colorScheme == .dark))
        .modifier(SheetPresentationBackground(isDark: colorScheme == .dark))
    }
    
    private func saveExpense() {
        guard let amountValue = Double(amount), amountValue > 0 else {
            alertMessage = "Please enter a valid amount"
            showingAlert = true
            return
        }
        let categoryName = selectedCategoryObj?.name ?? "Other"
        viewModel.addExpense(
            amount: amountValue,
            categoryName: categoryName,
            date: selectedDate,
            notes: notes.isEmpty ? nil : notes
        )
        dismiss()
    }
}

private struct SheetPresentationBackground: ViewModifier {
    let isDark: Bool
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .presentationBackground(AppColors.surface(isDark))
                .presentationCornerRadius(20)
        } else {
            content
        }
    }
}

#Preview {
    AddExpenseView(viewModel: ExpenseViewModel(context: PersistenceController.preview.container.viewContext))
}


