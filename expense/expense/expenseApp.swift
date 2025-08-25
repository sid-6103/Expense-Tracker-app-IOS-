//
//  expenseApp.swift
//  expense
//
//  Created by Siddharth Patel on 8/18/25.
//

import SwiftUI

@main
struct expenseApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabView(context: persistenceController.container.viewContext)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
