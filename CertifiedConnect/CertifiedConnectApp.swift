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
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        print("App Check Debug Provider is configured.")
        #endif

        FirebaseApp.configure()

        return true
    }
}

@main
struct CertifiedConnectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appState = AppState()
    @State private var currentUser: User?
    @State private var isLoading = true

    var body: some Scene {
        WindowGroup {
            Group {
                if isLoading {
                    ProgressView("Fetching your profile...")
<<<<<<< HEAD
                        .onAppear(perform: checkAuthenticationState)
=======
>>>>>>> main
                } else if appState.isLoggedIn, let user = currentUser {
                    ContentView(currentUser: user)
                        .environmentObject(appState)
                } else {
                    AuthenticationView(onLogin: handleLogin)
                        .environmentObject(appState)
                }
            }
<<<<<<< HEAD
            .environmentObject(appState)
=======
            .onAppear {
                checkAuthenticationState()
            }
>>>>>>> main
        }
    }

    func handleLogin() {
        guard let user = Auth.auth().currentUser else {
            print("Error: No authenticated user after login")
            appState.isLoggedIn = false
            return
        }

        fetchCurrentUser()
    }

    func fetchCurrentUser() {
        guard let userUID = Auth.auth().currentUser?.uid else {
            print("Error: No authenticated user")
            appState.isLoggedIn = false
            isLoading = false
            return
        }

        print("Fetching profile for user: \(userUID)")
        isLoading = true

        let db = Firestore.firestore()
        db.collection("users").document(userUID).getDocument { snapshot, error in
            DispatchQueue.main.async {
                if let error = error {
<<<<<<< HEAD
                    print("Error fetching user profile: \(error.localizedDescription)")
=======
                    print("Error fetching current user: \(error.localizedDescription)")
>>>>>>> main
                    appState.isLoggedIn = false
                    isLoading = false
                    return
                }

                guard let data = snapshot?.data(),
                      let name = data["name"] as? String,
                      let role = data["role"] as? String else {
<<<<<<< HEAD
                    print("Error: Invalid user data")
=======
                    print("Error: Invalid user data for user \(userUID)")
>>>>>>> main
                    appState.isLoggedIn = false
                    isLoading = false
                    return
                }

<<<<<<< HEAD
=======
                print("Successfully fetched profile: \(data)")
>>>>>>> main
                self.currentUser = User(id: userUID, name: name, role: role)
                appState.isLoggedIn = true
                isLoading = false
            }
        }
    }

    func checkAuthenticationState() {
        if let user = Auth.auth().currentUser {
            fetchCurrentUser()
        } else {
<<<<<<< HEAD
=======
            print("No authenticated user.")
>>>>>>> main
            isLoading = false
        }
    }
}
