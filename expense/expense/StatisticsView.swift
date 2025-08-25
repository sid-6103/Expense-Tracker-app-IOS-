import SwiftUI
import Charts

struct StatisticsView: View {
    @ObservedObject var expenseViewModel: ExpenseViewModel
    @StateObject private var incomeViewModel = IncomeViewModel()
    @State private var selectedTab: StatisticsTab = .expenses
    
    enum StatisticsTab: String, CaseIterable, Identifiable {
        case expenses = "Expenses"
        case income = "Income"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                HStack(spacing: 0) {
                    ForEach(StatisticsTab.allCases) { tab in
                        Button(action: { selectedTab = tab }) {
                            VStack(spacing: 8) {
                                Text(tab.rawValue)
                                    .font(.headline)
                                    .fontWeight(selectedTab == tab ? .bold : .medium)
                                    .foregroundColor(selectedTab == tab ? .primary : .secondary)
                                
                                Rectangle()
                                    .fill(selectedTab == tab ? .blue : Color.clear)
                                    .frame(height: 3)
                                    .animation(.easeInOut(duration: 0.2), value: selectedTab)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal)
                .background(Color(UIColor.systemBackground))
                
                // Content
                ScrollView {
                    LazyVStack(spacing: 20) {
                        if selectedTab == .expenses {
                            // Expense Statistics
                            SummaryCardsView(statistics: ExpenseStatistics(expenses: expenseViewModel.expenses), viewModel: expenseViewModel)
                            CategoryBreakdownView(statistics: ExpenseStatistics(expenses: expenseViewModel.expenses), viewModel: expenseViewModel)
                            SpendingTrendsView(expenses: expenseViewModel.expenses, viewModel: expenseViewModel)
                        } else {
                            // Income Statistics
                            IncomeSummaryCardsView(statistics: incomeViewModel.statistics, viewModel: incomeViewModel)
                            IncomeCategoryBreakdownView(statistics: incomeViewModel.statistics, viewModel: incomeViewModel)
                            IncomeTrendsView(incomes: incomeViewModel.incomes, viewModel: incomeViewModel)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct SummaryCardsView: View {
    let statistics: ExpenseStatistics
    let viewModel: ExpenseViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Spending Summary")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                SummaryCard(
                    title: "Today",
                    amount: statistics.totalToday,
                    color: .blue,
                    viewModel: viewModel
                )
                
                SummaryCard(
                    title: "This Week",
                    amount: statistics.totalThisWeek,
                    color: .green,
                    viewModel: viewModel
                )
                
                SummaryCard(
                    title: "This Month",
                    amount: statistics.totalThisMonth,
                    color: .orange,
                    viewModel: viewModel
                )
            }
        }
    }
}

struct SummaryCard: View {
    let title: String
    let amount: Double
    let color: Color
    let viewModel: ExpenseViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
            
            Text(viewModel.formatCurrency(amount))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CategoryBreakdownView: View {
    let statistics: ExpenseStatistics
    let viewModel: ExpenseViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Spending by Category")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                ForEach(ExpenseCategory.allCases) { category in
                    let amount = statistics.categoryBreakdown[category] ?? 0
                    if amount > 0 {
                        CategoryRow(
                            category: category,
                            amount: amount,
                            total: statistics.totalThisMonth,
                            viewModel: viewModel
                        )
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct CategoryRow: View {
    let category: ExpenseCategory
    let amount: Double
    let total: Double
    let viewModel: ExpenseViewModel
    
    private var percentage: Double {
        total > 0 ? (amount / total) * 100 : 0
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            ZStack {
                Circle()
                    .fill(Color(category.color).opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: category.icon)
                    .foregroundColor(Color(category.color))
                    .font(.system(size: 14, weight: .medium))
            }
            
            // Category Name
            Text(category.rawValue)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Amount and Percentage
            VStack(alignment: .trailing, spacing: 2) {
                Text(viewModel.formatCurrency(amount))
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(String(format: "%.1f%%", percentage))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct SpendingTrendsView: View {
    let expenses: [ExpenseItem]
    let viewModel: ExpenseViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Recent Spending")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(groupedExpenses, id: \.date) { item in
                        BarMark(
                            x: .value("Date", item.date, unit: .day),
                            y: .value("Amount", item.amount)
                        )
                        .foregroundStyle(Color.blue.gradient)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.day())
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let amount = value.as(Double.self) {
                                Text(viewModel.formatCurrency(amount))
                            }
                        }
                    }
                }
            } else {
                // Fallback for iOS 15
                VStack(spacing: 12) {
                    ForEach(groupedExpenses.prefix(7), id: \.date) { item in
                        HStack {
                            Text(viewModel.formatDate(item.date))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(viewModel.formatCurrency(item.amount))
                                .font(.body)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private var groupedExpenses: [GroupedExpense] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: expenses) { expense in
            calendar.startOfDay(for: expense.date)
        }
        
        return grouped.map { date, expenses in
            GroupedExpense(date: date, amount: expenses.reduce(0) { $0 + $1.amount })
        }.sorted { $0.date < $1.date }
    }
}

struct GroupedExpense {
    let date: Date
    let amount: Double
}

// MARK: - Income Statistics Views

struct IncomeSummaryCardsView: View {
    let statistics: IncomeStatistics
    let viewModel: IncomeViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Income Summary")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                IncomeSummaryCard(
                    title: "Today",
                    amount: statistics.totalToday,
                    color: .green,
                    viewModel: viewModel
                )
                
                IncomeSummaryCard(
                    title: "This Week",
                    amount: statistics.totalThisWeek,
                    color: .blue,
                    viewModel: viewModel
                )
                
                IncomeSummaryCard(
                    title: "This Month",
                    amount: statistics.totalThisMonth,
                    color: .purple,
                    viewModel: viewModel
                )
            }
        }
    }
}

struct IncomeSummaryCard: View {
    let title: String
    let amount: Double
    let color: Color
    let viewModel: IncomeViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
            
            Text(viewModel.formatCurrency(amount))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct IncomeCategoryBreakdownView: View {
    let statistics: IncomeStatistics
    let viewModel: IncomeViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Income by Category")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if statistics.categoryBreakdown.isEmpty {
                Text("No income data available")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                Chart(Array(statistics.categoryBreakdown.enumerated()), id: \.offset) { index, element in
                    SectorMark(
                        angle: .value("Amount", element.value),
                        innerRadius: .ratio(0.5),
                        angularInset: 2
                    )
                    .foregroundStyle(by: .value("Category", element.key.rawValue))
                }
                .frame(height: 200)
                .chartLegend(position: .bottom, alignment: .center)
            }
        }
    }
}

struct IncomeTrendsView: View {
    let incomes: [IncomeItem]
    let viewModel: IncomeViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Income Trends")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if incomes.isEmpty {
                Text("No income data available")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                Chart(incomes, id: \.id) { income in
                    LineMark(
                        x: .value("Date", income.date),
                        y: .value("Amount", income.amount)
                    )
                    .foregroundStyle(.green)
                    .symbol(Circle())
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.day())
                    }
                }
            }
        }
    }
}

#Preview {
    StatisticsView(expenseViewModel: ExpenseViewModel(context: PersistenceController.preview.container.viewContext))
}


