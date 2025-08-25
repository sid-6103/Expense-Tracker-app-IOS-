import Foundation
import SwiftUI

// MARK: - Dark Mode Manager
class DarkModeManager: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "darkModeEnabled")
        }
    }
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "darkModeEnabled")
    }
    
    func toggleDarkMode() {
        isDarkMode.toggle()
    }
}
