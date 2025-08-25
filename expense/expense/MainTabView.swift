import SwiftUI
import CoreData

struct MainTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var expenseViewModel: ExpenseViewModel
    @StateObject private var darkModeManager = DarkModeManager()
    
    init(context: NSManagedObjectContext) {
        self._expenseViewModel = StateObject(wrappedValue: ExpenseViewModel(context: context))
    }
    
    var body: some View {
        TabView {
            ExpenseIncomeTabView(expenseViewModel: expenseViewModel)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            StatisticsView(expenseViewModel: expenseViewModel)
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Statistics")
                }
            
            SettingsView(darkModeManager: darkModeManager)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(AppColors.tint(darkModeManager.isDarkMode))
        .preferredColorScheme(darkModeManager.isDarkMode ? .dark : .light)
    }
}

#Preview {
    MainTabView(context: PersistenceController.preview.container.viewContext)
}
