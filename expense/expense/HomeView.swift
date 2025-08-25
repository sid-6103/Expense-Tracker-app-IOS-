import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @State private var showingAddExpense = false
    @State private var showingIncomeSheet = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with Summary
                HeaderSummaryView(statistics: viewModel.filteredStatistics, viewModel: viewModel)
                    .onTapGesture(count: 2) {
                        showingIncomeSheet = true
                    }
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                // Swipe right (leading edge) to show income
                                if value.translation.width > 100 && abs(value.translation.height) < 50 {
                                    showingIncomeSheet = true
                                }
                            }
                    )
                
                // Search and Filters
                SearchAndFiltersView(viewModel: viewModel)
                
                // Expenses List
                ExpensesListView(viewModel: viewModel, showingIncomeSheet: $showingIncomeSheet)
            }
            .navigationTitle("Expenses")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddExpense = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppColors.tint(colorScheme == .dark))
                    }
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingIncomeSheet) {
                IncomeHomeView(viewModel: IncomeViewModel())
            }
        }
    }
}

struct HeaderSummaryView: View {
    let statistics: ExpenseStatistics
    let viewModel: ExpenseViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            // Total Spending Today
            VStack(spacing: 8) {
                Text("Total Spent Today")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                Text(viewModel.formatCurrency(statistics.totalToday))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            // Quick Stats
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("This Week")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.formatCurrency(statistics.totalThisWeek))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack(spacing: 4) {
                    Text("This Month")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.formatCurrency(statistics.totalThisMonth))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: AppColors.headerGradient(colorScheme == .dark)),
                startPoint: .top,
                endPoint: .bottom
            )
        )
       
    }
}

struct SearchAndFiltersView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search expenses...", text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Filters
            HStack(spacing: 12) {
                // Time Filter Buttons
                HStack(spacing: 8) {
                    // All Button
                    Button(action: {
                        viewModel.selectedTimeFilter = .all
                    }) {
                        Text("All")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(viewModel.selectedTimeFilter == .all ? .white : .primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(viewModel.selectedTimeFilter == .all ? Color.blue : Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // Today Button
                    Button(action: {
                        viewModel.selectedTimeFilter = .today
                    }) {
                        Text("Today")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(viewModel.selectedTimeFilter == .today ? .white : .primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(viewModel.selectedTimeFilter == .today ? Color.blue : Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // Calendar Button
                    Button(action: {
                        viewModel.showingDatePicker = true
                    }) {
                                            Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                
                // Category Filter
                Menu {
                    Button("All Categories") {
                        viewModel.selectedCategory = .other
                    }
                    
                    ForEach(ExpenseCategory.allCases) { category in
                        if category != .other {
                            Button(category.rawValue) {
                                viewModel.selectedCategory = category
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(viewModel.selectedCategory == .other ? "All Categories" : viewModel.selectedCategory.rawValue)
                            .foregroundColor(viewModel.selectedCategory == .other ? (colorScheme == .dark ? .purple : .primary) : .primary)
                        Image(systemName: "chevron.down")
                            .foregroundColor(viewModel.selectedCategory == .other ? (colorScheme == .dark ? .purple : .primary) : .primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .sheet(isPresented: $viewModel.showingDatePicker) {
            DatePickerView(selectedDate: $viewModel.selectedCustomDate, viewModel: viewModel)
        }
    }
}

// MARK: - Date Picker View
struct DatePickerView: View {
    @Binding var selectedDate: Date?
    @ObservedObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var tempDate = Date()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Calendar Header with Month Navigation
                HStack {
                    Button(action: {
                        tempDate = Calendar.current.date(byAdding: .month, value: -1, to: tempDate) ?? tempDate
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text(tempDate.formatted(.dateTime.month(.wide).year()))
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: {
                        tempDate = Calendar.current.date(byAdding: .month, value: 1, to: tempDate) ?? tempDate
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                
                // Calendar Grid
                DatePicker("Select Date", selection: $tempDate, displayedComponents: [.date])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding(.horizontal)
                
                // Action Buttons
                HStack(spacing: 16) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    
                    Button("Apply") {
                        selectedDate = tempDate
                        viewModel.selectedTimeFilter = .custom
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ExpensesListView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @Binding var showingIncomeSheet: Bool
    
    var body: some View {
        if viewModel.filteredExpenses.isEmpty {
            EmptyStateView()
        } else {
            List {
                ForEach(viewModel.filteredExpenses) { expense in
                    ExpenseRowView(expense: expense, viewModel: viewModel)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button(action: {
                                showingIncomeSheet = true
                            }) {
                                Label("Income", systemImage: "plus.circle.fill")
                            }
                            .tint(.green)
                        }
                }
                .onDelete(perform: deleteExpenses)
            }
            .listStyle(PlainListStyle())
        }
    }
    
    private func deleteExpenses(offsets: IndexSet) {
        offsets.forEach { index in
            let expense = viewModel.filteredExpenses[index]
            viewModel.deleteExpense(expense)
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "creditcard")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Expenses Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Start tracking your expenses by adding your first transaction")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    HomeView(viewModel: ExpenseViewModel(context: PersistenceController.preview.container.viewContext))
}


