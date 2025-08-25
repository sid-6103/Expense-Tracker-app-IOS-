import SwiftUI
import CoreData

struct ManageCategoriesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var manager: CategoryManager
    @State private var showingAdd = false
    @State private var editTarget: Category?
    
    init(context: NSManagedObjectContext) {
        _manager = StateObject(wrappedValue: CategoryManager(context: context))
    }
    
    var body: some View {
        List {
            ForEach(manager.categories, id: \.id) { cat in
                HStack {
                    Text(cat.emoji?.isEmpty == false ? cat.emoji! : "🗂️")
                    Text(cat.name ?? "")
                    Spacer()
                    Button("Edit") { editTarget = cat }
                }
            }
            .onDelete { idx in
                idx.map { manager.categories[$0] }.forEach(manager.delete)
            }
        }
        .navigationTitle("Manage Categories")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAdd = true }) { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showingAdd) {
            EditCategorySheet(manager: manager, category: nil)
        }
        .sheet(item: $editTarget) { cat in
            EditCategorySheet(manager: manager, category: cat)
        }
    }
}

private struct EditCategorySheet: View {
    @ObservedObject var manager: CategoryManager
    var category: Category?
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var emoji: String = ""
    @State private var colorHex: String = ""
    @State private var showEmojiPicker = false
    
    init(manager: CategoryManager, category: Category?) {
        self.manager = manager
        self.category = category
        _name = State(initialValue: category?.name ?? "")
        _emoji = State(initialValue: category?.emoji ?? "")
        _colorHex = State(initialValue: category?.colorHex ?? "")
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
                            .onChange(of: emoji) { newValue in
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
                            .onChange(of: colorHex) { _ in
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
                        if let cat = category {
                            manager.update(cat, name: name, emoji: emoji.isEmpty ? nil : emoji, colorHex: colorHex.isEmpty ? nil : colorHex)
                        } else {
                            manager.add(name: name, emoji: emoji.isEmpty ? nil : emoji, colorHex: colorHex.isEmpty ? nil : colorHex)
                        }
                        dismiss()
                    }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .sheet(isPresented: $showEmojiPicker) {
                EmojiPickerView { picked in
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
        // Basic suggestions matching our dark-mode tints
        if emoji.contains("🚗") { return "#FF3B30" } // red
        if emoji.contains("🍽") { return "#8E8E93" } // gray
        if emoji.contains("🛍") { return "#FFB3D9" } // light pink
        if emoji.contains("🧾") { return "#FFFFFF" } // white
        if emoji.contains("📺") { return "#5AC8FA" } // sky blue (iOS cyan)
        if emoji.contains("❤️") { return "#FFB3D9" } // light pink
        if emoji.contains("⚪") { return "#8E8E93" } // secondary gray
        return nil
    }
}

private struct EmojiPickerView: View {
    let onSelect: (String) -> Void
    private let emojis: [String] = [
        "🍽️","🚗","🛍️","🧾","📺","❤️","⚽️","🎮","🎵","📚","🏠","🚌","✈️","🍿","☕️","🍔","💡","🧰","💊","🎁","🎨","🧼","🐶","🐱","🪙","💼","🧴","🪵","🔧","🪛"
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

// Color(hex:) is already defined in ExpenseViewModel.swift; reuse it from there.
