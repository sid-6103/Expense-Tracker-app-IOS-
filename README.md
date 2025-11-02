# 💰 Expense Tracker iOS App

A comprehensive personal finance management iOS application built with SwiftUI and Core Data, designed to help users track their daily expenses, categorize spending, and gain insights through visual analytics.

## 📱 Features

### 🔹 Phase 1 - Basic Features (MVP)
- ✅ **Add Expense**: Input amount, category, date, and notes
- ✅ **View Expenses List**: Chronological list with edit/delete functionality
- ✅ **Data Persistence**: Core Data integration for secure local storage

### 🔹 Phase 2 - Intermediate Features
- ✅ **Expense Categories**: 7 predefined categories with icons and colors
- ✅ **Summary Dashboard**: Total spending for today, this week, and this month
- ✅ **Charts & Visualization**: Category breakdown and spending trends
- ✅ **Search & Filter**: Find expenses by keyword, category, or time period

### 🔹 Phase 3 - Advanced Features
- ✅ **Dark Mode Support**: Adapts to system appearance settings
- ✅ **Settings Panel**: Customizable preferences and app information
- ✅ **Modern UI/UX**: Beautiful, intuitive interface with smooth animations
- ✅ **Data Export**: Export expenses + income as PDF or CSV (Excel)
- ✅ **Currency Picker**: Choose $, €, or ₹ and the symbol updates app‑wide (lists, stats, and exports)

## 🏗 Architecture

- **Design Pattern**: MVVM (Model-View-ViewModel)
- **UI Framework**: SwiftUI
- **Data Layer**: Core Data
- **Platform**: iOS 15.0+
- **Language**: Swift 5.0+

### Project Structure
```
expense/
├── expense/
│   ├── expenseApp.swift          # Main app entry point
│   ├── MainTabView.swift         # Tab-based navigation
│   ├── HomeView.swift            # Main expenses list and summary
│   ├── AddExpenseView.swift      # Add new expense form
│   ├── ExpenseRowView.swift      # Individual expense display
│   ├── IncomeRowView.swift       # Individual income display
│   ├── StatisticsView.swift      # Charts and analytics
│   ├── ExpenseViewModel.swift    # Business logic for expenses
│   ├── IncomeViewModel.swift     # Business logic for income
│   ├── DataExporter.swift        # PDF/CSV export implementation
│   ├── ExpenseModel.swift        # Data models and enums
│   ├── Persistence.swift         # Core Data setup
│   └── expense.xcdatamodeld/     # Core Data model
```

## 🎯 Core Features

### 1. Expense & Income Management
- **Add/Edit/Delete** expenses and incomes
- **Categories**: Food, Travel, Shopping, Bills, Entertainment, Health, Other (plus income types)

### 2. Smart Filtering
- **Time Filters**: All, Today, This Week, This Month
- **Category Filters**: Filter by specific categories
- **Search**: Find items by notes or category names

### 3. Visual Analytics
- **Summary Cards**: Today's total, weekly total, monthly total
- **Category Breakdown**: Visual representation of spending by category
- **Spending Trends**: Bar chart showing daily spending patterns

### 4. User Experience
- **Intuitive Navigation**: Tab-based interface with clear sections
- **Responsive Design**: Adapts to different screen sizes
- **Smooth Animations**: Fluid transitions and interactions
- **Empty States**: Helpful guidance when no items exist

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 15.0+ deployment target
- macOS 13.0 or later (for development)

### Installation
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd expense
   ```

2. Open the project in Xcode:
   ```bash
   open expense.xcodeproj
   ```

3. Build and run the project:
   - Select your target device or simulator
   - Press `Cmd + R` or click the Run button

### First Run
- The app may include sample data for demonstration
- Add your first expense using the "+" button
- Explore different tabs and features
- Customize settings in the Settings tab

## 📊 Data Model

### Expense Entity
```swift
struct ExpenseItem {
    let id: UUID
    var amount: Double
    var category: ExpenseCategory
    var date: Date
    var notes: String?
}
```

## 🔧 Customization

### Currency
- Default: Indian Rupees (₹)
- Change in Settings: Picker with `$` (USD), `€` (EUR), `₹` (INR)
- Applies globally: lists, statistics, and PDF/CSV exports

### Data Export
- Open Settings → Export Data
- Choose: "Export as PDF" or "Export as Excel (CSV)"
- PDF includes: Title, date, summary (totals), Income section, then Expenses section
- CSV is Excel‑compatible with properly escaped fields

### Appearance
- Light/Dark mode support
- Customizable accent tint based on theme

## 📱 Screenshots
- Home, Statistics, and Settings tabs showcase lists, charts, and preferences

## 🛠 Technical Implementation

### Core Data Integration
- Automatic data persistence
- Efficient querying and filtering

### SwiftUI Best Practices
- ObservableObject pattern for state management
- Proper view separation and reusability

### Performance Optimizations
- Lazy loading for large lists
- Efficient Core Data queries

## 🔮 Future Enhancements

- [ ] **Budgets**: Monthly budget & alerts
- [ ] **Local Notifications**: Daily reminders
- [ ] **Receipt Photos**: Attach images to expenses
- [ ] **Cloud Sync**: iCloud backup/sync
- [ ] **Widgets**: Home screen summaries

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Developer

**Siddharth Patel**
- Created: August 18, 2025
- Platform: iOS
- Framework: SwiftUI + Core Data

## 🙏 Acknowledgments

- Apple for SwiftUI and Core Data frameworks
- SF Symbols for beautiful system icons
- SwiftUI community for best practices and examples

---

**Note**: This app is designed for personal use and educational purposes. Always ensure your financial data is secure and backed up appropriately.


