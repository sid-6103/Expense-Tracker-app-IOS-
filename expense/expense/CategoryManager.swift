import Foundation
import CoreData
import SwiftUI

final class CategoryManager: ObservableObject {
    @Published var categories: [Category] = []
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        ensureSeedData()
        fetch()
    }
    
    func fetch() {
        let req: NSFetchRequest<Category> = Category.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        categories = (try? viewContext.fetch(req)) ?? []
    }
    
    func add(name: String, emoji: String?, colorHex: String?) {
        let c = Category(context: viewContext)
        c.id = UUID()
        c.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        c.emoji = (emoji ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let hex = (colorHex ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        c.colorHex = hex.isEmpty ? nil : hex
        save()
    }
    
    func update(_ category: Category, name: String, emoji: String?, colorHex: String?) {
        category.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        category.emoji = (emoji ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let hex = (colorHex ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        category.colorHex = hex.isEmpty ? nil : hex
        save()
    }
    
    func delete(_ category: Category) {
        viewContext.delete(category)
        save()
    }
    
    private func save() {
        do { try viewContext.save(); fetch() } catch { print("Category save error: \(error)") }
    }
    
    private func ensureSeedData() {
        let req: NSFetchRequest<Category> = Category.fetchRequest()
        let count = (try? viewContext.count(for: req)) ?? 0
        guard count == 0 else { return }
        let seeds: [(String, String, String?)] = [
            ("Food", "🍽️", nil),
            ("Travel", "🚗", nil),
            ("Shopping", "🛍️", nil),
            ("Bills", "🧾", nil),
            ("Entertainment", "📺", nil),
            ("Health", "❤️", nil),
            ("Other", "⚪️", nil)
        ]
        for (name, emoji, color) in seeds { add(name: name, emoji: emoji, colorHex: color) }
    }
}
