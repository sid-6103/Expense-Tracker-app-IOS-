import SwiftUI

struct IncomeHomeView: View {
    @ObservedObject var viewModel: IncomeViewModel
    @State private var showingAddIncome = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with Summary
                IncomeHeaderSummaryView(statistics: viewModel.filteredStatistics, viewModel: viewModel)
                
                // Search and Filters
                IncomeSearchAndFiltersView(viewModel: viewModel)
                
                // Income List
                IncomeListView(viewModel: viewModel)
            }
            .navigationTitle("Income")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddIncome = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppColors.tint(colorScheme == .dark))
                    }
                }
            }
            .sheet(isPresented: $showingAddIncome) {
                IncomeView(viewModel: viewModel)
            }
        }
    }
}

struct IncomeHeaderSummaryView: View {
    let statistics: IncomeStatistics
    let viewModel: IncomeViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            // Total Income Today
            VStack(spacing: 8) {
                Text("Total Earned Today")
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
                        .foregroundColor(.green)
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

struct IncomeSearchAndFiltersView: View {
    @ObservedObject var viewModel: IncomeViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search income...", text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.primary)
                
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
                    
                    ForEach(IncomeCategory.allCases) { category in
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
            IncomeDatePickerView(selectedDate: $viewModel.selectedCustomDate, viewModel: viewModel)
        }
    }
}

// MARK: - Income Date Picker View
struct IncomeDatePickerView: View {
    @Binding var selectedDate: Date?
    @ObservedObject var viewModel: IncomeViewModel
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

struct IncomeListView: View {
    @ObservedObject var viewModel: IncomeViewModel
    
    var body: some View {
        if viewModel.filteredIncomes.isEmpty {
            IncomeEmptyStateView()
        } else {
            List {
                ForEach(viewModel.filteredIncomes) { income in
                    IncomeRowView(income: income, viewModel: viewModel)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                .onDelete(perform: deleteIncomes)
            }
            .listStyle(PlainListStyle())
        }
    }
    
    private func deleteIncomes(offsets: IndexSet) {
        offsets.forEach { index in
            let income = viewModel.filteredIncomes[index]
            viewModel.deleteIncome(income)
        }
    }
}

struct IncomeEmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "dollarsign.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Income Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Start tracking your income by adding your first transaction")
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
    IncomeHomeView(viewModel: IncomeViewModel())
}
