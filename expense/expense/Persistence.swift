//
//  Persistence.swift
//  expense
//
//  Created by Siddharth Patel on 8/18/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Add sample expenses for preview
        let sampleExpenses = [
            (amount: 25.50, category: "Food", date: Date(), notes: "Lunch at restaurant"),
            (amount: 15.00, category: "Travel", date: Date().addingTimeInterval(-86400), notes: "Bus fare"),
            (amount: 45.99, category: "Shopping", date: Date().addingTimeInterval(-172800), notes: "New shirt"),
            (amount: 120.00, category: "Bills", date: Date().addingTimeInterval(-259200), notes: "Electricity bill"),
            (amount: 30.00, category: "Entertainment", date: Date().addingTimeInterval(-345600), notes: "Movie tickets")
        ]
        
        for expenseData in sampleExpenses {
            let newExpense = Expense(context: viewContext)
            newExpense.id = UUID()
            newExpense.amount = expenseData.amount
            newExpense.category = expenseData.category
            newExpense.date = expenseData.date
            newExpense.notes = expenseData.notes
        }
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "expense")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
