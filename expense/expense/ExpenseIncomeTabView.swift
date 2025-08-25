import SwiftUI

struct ExpenseIncomeTabView: View {
    @ObservedObject var expenseViewModel: ExpenseViewModel
    @StateObject private var incomeViewModel = IncomeViewModel()
    @State private var selectedTab: TabType = .expense
    @State private var showingAddExpense = false
    @State private var showingAddIncome = false
    @Environment(\.colorScheme) private var colorScheme
    
    enum TabType {
        case expense, income
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Tab Selector
                HStack(spacing: 0) {
                    TabButton(
                        title: "Expenses",
                        isSelected: selectedTab == .expense,
                        action: { selectedTab = .expense }
                    )
                    
                    TabButton(
                        title: "Income",
                        isSelected: selectedTab == .income,
                        action: { selectedTab = .income }
                    )
                }
                .padding(.horizontal)
                .background(Color(UIColor.systemBackground))
                
                // Content View without paging to keep row swipe actions working
                Group {
                    if selectedTab == .expense {
                        ExpenseContentView(viewModel: expenseViewModel, selectedTab: $selectedTab)
                    } else {
                        IncomeContentView(viewModel: incomeViewModel, selectedTab: $selectedTab)
                    }
                }
            }
            .navigationTitle(selectedTab == .expense ? "Expenses" : "Income")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if selectedTab == .expense {
                            showingAddExpense = true
                        } else {
                            showingAddIncome = true
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppColors.tint(colorScheme == .dark))
                    }
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView(viewModel: expenseViewModel)
            }
            .sheet(isPresented: $showingAddIncome) {
                IncomeView(viewModel: incomeViewModel)
            }
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundColor(isSelected ? AppColors.tint(colorScheme == .dark) : .secondary)
                
                Rectangle()
                    .fill(isSelected ? AppColors.tint(colorScheme == .dark) : Color.clear)
                    .frame(height: 3)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

// Expense Content View (extracted from HomeView)
struct ExpenseContentView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @Binding var selectedTab: ExpenseIncomeTabView.TabType
    @State private var showingAddExpense = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Summary (reflect current filters)
            HeaderSummaryView(statistics: viewModel.filteredStatistics, viewModel: viewModel)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            let threshold: CGFloat = 60
                            if value.translation.width < -threshold {
                                withAnimation(.easeInOut(duration: 0.25)) { selectedTab = .income }
                            }
                        }
                )
            
            // Search and Filters
            SearchAndFiltersView(viewModel: viewModel)
            
            // Expenses List
            ExpenseListContentView(viewModel: viewModel)
        }
    }
}

// Income Content View (extracted from IncomeHomeView)
struct IncomeContentView: View {
    @ObservedObject var viewModel: IncomeViewModel
    @Binding var selectedTab: ExpenseIncomeTabView.TabType
    @State private var showingAddIncome = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Summary
            IncomeHeaderSummaryView(statistics: viewModel.statistics, viewModel: viewModel)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            let threshold: CGFloat = 60
                            if value.translation.width > threshold {
                                withAnimation(.easeInOut(duration: 0.25)) { selectedTab = .expense }
                            }
                        }
                )
            
            // Search and Filters
            IncomeSearchAndFiltersView(viewModel: viewModel)
            
            // Income List
            IncomeListView(viewModel: viewModel)
        }
    }
}

// Simplified Expense List without swipe actions
struct ExpenseListContentView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    
    var body: some View {
        if viewModel.filteredExpenses.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "tray")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)
                
                Text("No expenses yet")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Tap the + button to add your first expense")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemBackground))
        } else {
            List {
                ForEach(viewModel.filteredExpenses) { expense in
                    ExpenseRowView(expense: expense, viewModel: viewModel)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.deleteExpense(expense)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
                .onDelete(perform: deleteExpenses)
            }
            .listStyle(PlainListStyle())
            .background(Color(UIColor.systemBackground))
        }
    }
    
    private func deleteExpenses(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                viewModel.deleteExpense(viewModel.filteredExpenses[index])
            }
        }
    }
}

#Preview {
    ExpenseIncomeTabView(expenseViewModel: ExpenseViewModel(context: PersistenceController.preview.container.viewContext))
}
