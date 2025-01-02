import Foundation

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false // This should trigger view updates
}
