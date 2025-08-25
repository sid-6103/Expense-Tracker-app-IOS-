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
│   ├── StatisticsView.swift      # Charts and analytics
│   ├── ExpenseViewModel.swift    # Business logic and data management
│   ├── ExpenseModel.swift        # Data models and enums
│   ├── Persistence.swift         # Core Data setup
│   └── expense.xcdatamodeld/     # Core Data model
```

## 🎯 Core Features

### 1. Expense Management
- **Add Expenses**: Simple form with amount, category picker, date picker, and notes
- **Edit Expenses**: Tap any expense to modify details
- **Delete Expenses**: Swipe to delete or use edit mode
- **Categories**: Food, Travel, Shopping, Bills, Entertainment, Health, Other

### 2. Smart Filtering
- **Time Filters**: All, Today, This Week, This Month
- **Category Filters**: Filter by specific expense categories
- **Search**: Find expenses by notes or category names

### 3. Visual Analytics
- **Summary Cards**: Today's total, weekly total, monthly total
- **Category Breakdown**: Visual representation of spending by category
- **Spending Trends**: Bar chart showing daily spending patterns
- **Percentage Calculations**: Category-wise spending percentages

### 4. User Experience
- **Intuitive Navigation**: Tab-based interface with clear sections
- **Responsive Design**: Adapts to different screen sizes
- **Smooth Animations**: Fluid transitions and interactions
- **Empty States**: Helpful guidance when no expenses exist

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
- The app will start with sample data for demonstration
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

### Categories
- **Food** 🍴 - Orange color
- **Travel** 🚗 - Blue color
- **Shopping** 🛍️ - Purple color
- **Bills** 📄 - Red color
- **Entertainment** 📺 - Green color
- **Health** ❤️ - Pink color
- **Other** ⚪ - Gray color

## 🔧 Customization

### Currency Format
- Default: Indian Rupees (₹)
- Customizable in Settings tab
- Automatically adapts to system locale

### Appearance
- Light/Dark mode support
- Customizable accent colors
- Responsive typography

### Data Management
- Export functionality (planned)
- Data backup and restore
- Clear all data option

## 📱 Screenshots

The app features three main tabs:

1. **Home Tab**: Expense list, summary cards, search and filters
2. **Statistics Tab**: Charts, category breakdown, spending trends
3. **Settings Tab**: Preferences, app information, data management

## 🛠 Technical Implementation

### Core Data Integration
- Automatic data persistence
- Efficient querying and filtering
- Sample data for previews

### SwiftUI Best Practices
- ObservableObject pattern for state management
- Proper view separation and reusability
- Accessibility support

### Performance Optimizations
- Lazy loading for large lists
- Efficient Core Data queries
- Minimal memory footprint

## 🔮 Future Enhancements

- [ ] **Data Export**: CSV/PDF export functionality
- [ ] **Local Notifications**: Daily expense reminders
- [ ] **Budget Tracking**: Set and monitor spending limits
- [ ] **Receipt Photos**: Attach images to expenses
- [ ] **Cloud Sync**: iCloud integration for data backup
- [ ] **Widgets**: Home screen expense summaries
- [ ] **Apple Watch**: Companion app for quick logging

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


