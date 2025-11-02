//
//  SettingsView.swift
//  expense
//
//  Created by Siddharth Patel on 8/18/25.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @ObservedObject var darkModeManager: DarkModeManager
    @AppStorage("currencySymbol") private var currencySymbol = "₹"
    @AppStorage("enableNotifications") private var enableNotifications = false
    @StateObject private var securityManager = SecurityManager()
    @StateObject private var dataExporter = DataExporter()
    @State private var showingPINSetup = false
    @State private var showingChangePIN = false
    @State private var showingExportOptions = false
    @State private var showingExportSheet = false
    @State private var exportURL: URL?
    @Environment(\.managedObjectContext) private var viewContext
    
    // Get expense and income data for export
    private var expenses: [ExpenseItem] {
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Expense.date, ascending: false)]
        
        do {
            let coreDataExpenses = try viewContext.fetch(request)
            return coreDataExpenses.map { coreDataExpense in
                let name = coreDataExpense.category ?? "Other"
                let enumCat = ExpenseCategory(rawValue: name) ?? .other
                return ExpenseItem(
                    id: coreDataExpense.id ?? UUID(),
                    amount: coreDataExpense.amount,
                    category: enumCat,
                    categoryName: name,
                    date: coreDataExpense.date ?? Date(),
                    notes: coreDataExpense.notes
                )
            }
        } catch {
            return []
        }
    }
    
    private var income: [IncomeItem] {
        // Get income from the shared view model if available
        // Otherwise create a temporary instance to get current data
        let incomeVM = IncomeViewModel()
        // Fetch fresh data
        return incomeVM.incomes
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Preferences")) {
                    HStack {
                        Text("Currency")
                        Spacer()
                        Picker("Currency", selection: $currencySymbol) {
                            Text("$ USD").tag("$")
                            Text("€ EUR").tag("€")
                            Text("₹ INR").tag("₹")
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    Toggle("Enable Notifications", isOn: $enableNotifications)
                    
                    HStack(spacing: 12) {
                        DarkModeIconView(isDark: darkModeManager.isDarkMode)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Dark Mode")
                                .font(.body)
                            Text(darkModeManager.isDarkMode ? "Enabled" : "Disabled")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $darkModeManager.isDarkMode)
                            .labelsHidden()
                            .onChange(of: darkModeManager.isDarkMode) { _, newValue in
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                            }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.25)) {
                            darkModeManager.toggleDarkMode()
                        }
                    }
                    
                    NavigationLink("Manage Expense Categories") {
                        ManageCategoriesView(context: PersistenceController.shared.container.viewContext)
                    }
                    
                    NavigationLink("Manage Income Categories") {
                        ManageIncomeCategoriesView()
                    }
                }
                
                Section(header: Text("Security")) {
                    Toggle("App Lock", isOn: $securityManager.enableAppLock)
                        .onChange(of: securityManager.enableAppLock) { _, enabled in
                            securityManager.saveSettings()
                            if enabled && securityManager.passcode.isEmpty && !showingPINSetup {
                                showingPINSetup = true
                            }
                        }
                    
                    if securityManager.enableAppLock {
                        // Face ID option (always show, but disabled if not available)
                        Toggle("Face ID", isOn: $securityManager.useFaceID)
                            .disabled(!securityManager.isBiometricAvailable)
                            .onChange(of: securityManager.useFaceID) { oldValue, newValue in
                                securityManager.saveSettings()
                                // If trying to disable Face ID but PIN is also disabled, enable PIN
                                if !newValue && !securityManager.usePIN {
                                    securityManager.usePIN = true
                                    securityManager.saveSettings()
                                }
                            }
                        
                        // PIN option
                        Toggle("PIN", isOn: $securityManager.usePIN)
                            .onChange(of: securityManager.usePIN) { oldValue, newValue in
                                if newValue && securityManager.passcode.isEmpty && !showingPINSetup {
                                    showingPINSetup = true
                                }
                                // If trying to disable PIN but Face ID is also disabled, enable Face ID if available
                                if !newValue && !securityManager.useFaceID && securityManager.isBiometricAvailable {
                                    securityManager.useFaceID = true
                                }
                                securityManager.saveSettings()
                            }
                        
                        if !securityManager.passcode.isEmpty {
                            Button(action: { showingChangePIN = true }) {
                                HStack {
                                    Text("Change PIN")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.1")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Developer")
                        Spacer()
                        Text("Siddharth Patel")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button("Export Data") {
                        showingExportOptions = true
                    }
                    .foregroundColor(.blue)
                    
                    Button("Clear All Data", role: .destructive) {
                        // TODO: Implement data clearing
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingPINSetup) {
                PINSetupView(securityManager: securityManager)
            }
            .sheet(isPresented: $showingChangePIN) {
                PINSetupView(securityManager: securityManager)
            }
            .confirmationDialog("Export Format", isPresented: $showingExportOptions, titleVisibility: .visible) {
                Button("Export as PDF") {
                    exportData(format: .pdf)
                }
                
                Button("Export as Excel (CSV)") {
                    exportData(format: .excel)
                }
                
                Button("Cancel", role: .cancel) { }
            }
            .sheet(item: Binding<URL?>(get: { exportURL }, set: { exportURL = $0 })) { url in
                ShareSheet(activityItems: [url])
            }
        }
    }
    
    private func exportData(format: DataExporter.ExportFormat) {
        let url: URL?
        
        if format == .pdf {
            url = dataExporter.exportToPDF(expenses: expenses, income: income, currencySymbol: currencySymbol)
        } else {
            url = dataExporter.exportToCSV(expenses: expenses, income: income, currencySymbol: currencySymbol)
        }
        
        if let url = url {
            exportURL = url
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// Extension to make URL Identifiable for sheet
extension URL: Identifiable {
    public var id: String {
        self.absoluteString
    }
}

// MARK: - Dark Mode Icon View
struct DarkModeIconView: View {
    let isDark: Bool
    @State private var rotationDegrees: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isDark ? Color.black : Color.clear)
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: isDark ? Color.black.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
                .animation(.easeInOut(duration: 0.25), value: isDark)
            
            Text("☀️")
                .font(.system(size: 16, weight: .medium))
                .opacity(isDark ? 0 : 1)
                .scaleEffect(isDark ? 0.6 : 1.0)
                .rotationEffect(.degrees(rotationDegrees))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isDark)
            
            Image(systemName: "moon.fill")
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium))
                .opacity(isDark ? 1 : 0)
                .scaleEffect(isDark ? 1.0 : 0.6)
                .rotationEffect(.degrees(rotationDegrees + 180))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isDark)
        }
        .onChange(of: isDark) { _, _ in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                rotationDegrees += 180
            }
        }
    }
}

// MARK: - Manage Income Categories View
struct ManageIncomeCategoriesView: View {
    @StateObject private var manager = IncomeCategoryManager()
    @State private var showingAdd = false
    @State private var editTarget: IncomeCategory?
    
    var body: some View {
        List {
            ForEach(IncomeCategory.allCases, id: \.self) { category in
                HStack {
                    Text(category.emoji)
                        .font(.system(size: 20))
                    Text(category.rawValue)
                    Spacer()
                    Button("Edit") { editTarget = category }
                }
            }
        }
        .navigationTitle("Manage Categories")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAdd = true }) { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showingAdd) {
            EditIncomeCategorySheet(category: nil)
        }
        .sheet(isPresented: Binding<Bool>(
            get: { editTarget != nil },
            set: { if !$0 { editTarget = nil } }
        )) {
            if let category = editTarget {
                EditIncomeCategorySheet(category: category)
            }
        }
    }
}

// MARK: - Income Category Manager
class IncomeCategoryManager: ObservableObject {
    func add(name: String, emoji: String?, colorHex: String?) {
        // This is a demo implementation since IncomeCategory is an enum
        // In a real app, you would save to Core Data or another persistence layer
    }
    
    func update(_ category: IncomeCategory, name: String, emoji: String?, colorHex: String?) {
        // This is a demo implementation since IncomeCategory is an enum
        // In a real app, you would update the persistent store
    }
}

// MARK: - Edit Income Category Sheet
private struct EditIncomeCategorySheet: View {
    var category: IncomeCategory?
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var emoji: String = ""
    @State private var colorHex: String = ""
    @State private var showEmojiPicker = false
    
    init(category: IncomeCategory?) {
        self.category = category
        _name = State(initialValue: category?.rawValue ?? "")
        _emoji = State(initialValue: category?.emoji ?? "")
        _colorHex = State(initialValue: category?.color ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                    HStack {
                        TextField("Emoji", text: $emoji)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .onChange(of: emoji) { oldValue, newValue in
                                enforceSingleGrapheme()
                                if colorHex.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    colorHex = suggestedHex(from: emoji) ?? colorHex
                                }
                            }
                        Button("Pick") { showEmojiPicker = true }
                    }
                    
                    HStack {
                        Text("Color hex (optional)")
                        Spacer()
                        TextField("#RRGGBB", text: $colorHex)
                            .multilineTextAlignment(.trailing)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .onChange(of: colorHex) { oldValue, newValue in
                                colorHex = colorHex.trimmingCharacters(in: .whitespaces)
                            }
                    }
                    if let preview = Color(hex: colorHex) {
                        HStack(spacing: 8) {
                            Text("Preview")
                            Circle().fill(preview).frame(width: 18, height: 18)
                            Text(colorHex).foregroundColor(.secondary).font(.caption)
                        }
                    }
                }
            }
            .navigationTitle(category == nil ? "Add Category" : "Edit Category")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // This is a demo - in a real app you would save the changes
                        dismiss()
                    }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .sheet(isPresented: $showEmojiPicker) {
                IncomeEmojiPickerView { picked in
                    emoji = picked
                    if colorHex.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        colorHex = suggestedHex(from: picked) ?? colorHex
                    }
                    showEmojiPicker = false
                }
            }
        }
    }
    
    private func enforceSingleGrapheme() {
        let trimmed = emoji.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count > 1 { emoji = String(trimmed.prefix(1)) }
        else { emoji = trimmed }
    }
    
    private func suggestedHex(from emoji: String) -> String? {
        // Income-specific emoji suggestions
        if emoji.contains("💰") { return "#32D74B" } // green
        if emoji.contains("💼") { return "#007AFF" } // blue
        if emoji.contains("⭐") { return "#FFD60A" } // yellow
        if emoji.contains("🎁") { return "#FF69B4" } // pink
        if emoji.contains("📈") { return "#5AC8FA" } // cyan
        if emoji.contains("🏢") { return "#8E8E93" } // gray
        return nil
    }
}

// MARK: - Income Emoji Picker View
private struct IncomeEmojiPickerView: View {
    let onSelect: (String) -> Void
    private let emojis: [String] = [
        "💰","💼","⭐","📈","🎁","🏢","💵","💸","📊","💳","🏦","💎","🪙","💷","💴","💶","🎯","🏆","📱","💻","🎨","🎵","📚","🏠","🚗","✈️","🍔","☕","🎮","⚽"
    ]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(emojis, id: \.self) { e in
                        Button(action: { onSelect(e); dismiss() }) {
                            Text(e).font(.system(size: 28))
                                .frame(width: 48, height: 48)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Pick Emoji")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
        }
    }
}

#Preview {
    SettingsView(darkModeManager: DarkModeManager())
}
