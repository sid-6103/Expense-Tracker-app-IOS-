import SwiftUI
import CoreData

struct MainTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var expenseViewModel: ExpenseViewModel
    @StateObject private var darkModeManager = DarkModeManager()
    @StateObject private var securityManager = SecurityManager()
    @Environment(\.scenePhase) private var scenePhase
    @State private var wasInBackground = false
    
    init(context: NSManagedObjectContext) {
        self._expenseViewModel = StateObject(wrappedValue: ExpenseViewModel(context: context))
    }
    
    var body: some View {
        ZStack {
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
            
            // App Lock Overlay
            if securityManager.isLocked {
                AppLockView(securityManager: securityManager)
                    .zIndex(999)
                    .transition(.opacity)
                    .animation(.easeInOut, value: securityManager.isLocked)
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // Lock app when it goes to background or becomes inactive
            if newPhase == .background || newPhase == .inactive {
                if securityManager.enableAppLock {
                    securityManager.lockApp()
                    wasInBackground = true
                }
            }
            
            // When returning from background, ensure app stays locked if needed
            if newPhase == .active && oldPhase == .background && wasInBackground {
                // App will remain locked until user authenticates
                wasInBackground = false
            }
        }
        .onAppear {
            // Lock app on launch if it was locked before
            if securityManager.enableAppLock && !securityManager.isAuthenticated {
                securityManager.lockApp()
            }
        }
    }
}

#Preview {
    MainTabView(context: PersistenceController.preview.container.viewContext)
}
