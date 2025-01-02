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
    @State private var isLoggedIn = false // Controls whether the user is logged in
    @State private var isLoading = true // Start as true to check authentication state

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
                print("CertifiedConnectApp: Checking authentication state")
                checkAuthenticationState()
            }
        }
    }

    /// Handle the login action
    func handleLogin() {
        guard let user = Auth.auth().currentUser else {
            print("Error: No authenticated user after login")
            isLoggedIn = false
            return
        }

        print("User logged in: \(user.uid)")
        fetchCurrentUser()
    }

    /// Fetch the current user's profile
    func fetchCurrentUser() {
        guard let userUID = Auth.auth().currentUser?.uid else {
            print("Error: No authenticated user")
            isLoggedIn = false
            isLoading = false
            return
        }

        print("Fetching profile for user: \(userUID)")
        isLoading = true // Start loading spinner
        print("State before fetch: isLoggedIn = \(isLoggedIn), isLoading = \(isLoading)")

        let db = Firestore.firestore()
        db.collection("users").document(userUID).getDocument { snapshot, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching current user: \(error.localizedDescription)")
                    isLoading = false
                    isLoggedIn = false
                    print("State after error: isLoggedIn = \(isLoggedIn), isLoading = \(isLoading)")
                    return
                }

                guard let data = snapshot?.data(),
                      let name = data["name"] as? String,
                      let role = data["role"] as? String else {
                    print("Error: Invalid user data for user \(userUID)")
                    isLoading = false
                    isLoggedIn = false
                    print("State after invalid data: isLoggedIn = \(isLoggedIn), isLoading = \(isLoading)")
                    return
                }

                // Successfully fetched user data
                print("Successfully fetched profile: \(data)")
                self.currentUser = User(id: userUID, name: name, role: role)

                // Update states and log transitions
                isLoggedIn = true
                isLoading = false
                print("State after fetch: isLoggedIn = \(isLoggedIn), isLoading = \(isLoading)")
            }
        }
    }

    /// Check the user's authentication state when the app launches
    func checkAuthenticationState() {
        if let user = Auth.auth().currentUser {
            print("User is already logged in: \(user.uid)")
            fetchCurrentUser()
        } else {
            print("No authenticated user.")
            isLoading = false // Stop spinner and show login screen
        }
    }
}
