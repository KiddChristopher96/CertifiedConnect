import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseAppCheck

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        #if DEBUG
        // Enable App Check Debug Provider BEFORE configuring Firebase
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        print("App Check Debug Provider is configured.")
        #endif

        // Configure Firebase
        FirebaseApp.configure()

        #if DEBUG
        // Explicitly fetch the App Check Debug Token
        AppCheck.appCheck().token(forcingRefresh: true) { token, error in
            if let error = error {
                print("Failed to get App Check token: \(error.localizedDescription)")
            } else if let token = token {
                print("App Check Debug Token: \(token.token)")
            } else {
                print("No token received.")
            }
        }
        #endif

        return true
    }
}

@main
struct CertifiedConnectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appState = AppState()
    @State private var currentUser: User?
    @State private var isLoggedIn = false
    @State private var isLoading = true

    var body: some Scene {
        WindowGroup {
            Group {
                if isLoading {
                    ProgressView("Fetching your profile...")
                } else if isLoggedIn, let user = currentUser {
                    ContentView(currentUser: user)
                        .environmentObject(appState)
                } else {
                    AuthenticationView(onLogin: handleLogin)
                        .environmentObject(appState)
                }
            }
            .onAppear {
                checkAuthenticationState()
            }
        }
    }

    func handleLogin() {
        guard let user = Auth.auth().currentUser else {
            isLoggedIn = false
            return
        }
        fetchCurrentUser()
    }

    func fetchCurrentUser() {
        guard let userUID = Auth.auth().currentUser?.uid else {
            isLoggedIn = false
            isLoading = false
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(userUID).getDocument { snapshot, error in
            DispatchQueue.main.async {
                if let error = error {
                    isLoading = false
                    isLoggedIn = false
                    return
                }

                guard let data = snapshot?.data(),
                      let name = data["name"] as? String,
                      let role = data["role"] as? String else {
                    isLoading = false
                    isLoggedIn = false
                    return
                }

                self.currentUser = User(id: userUID, name: name, role: role)
                isLoggedIn = true
                isLoading = false
            }
        }
    }

    func checkAuthenticationState() {
        if let user = Auth.auth().currentUser {
            fetchCurrentUser()
        } else {
            isLoading = false
        }
    }
}
