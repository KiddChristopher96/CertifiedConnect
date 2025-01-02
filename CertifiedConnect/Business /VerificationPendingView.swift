import SwiftUI
import FirebaseAuth

struct VerificationPendingView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 20) {
            Text("Your Business Profile is Under Review")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()

            Text("Our team is currently reviewing your business profile. Once your insurance is verified, you’ll be notified, and your profile will be activated.")
                .multilineTextAlignment(.center)
                .padding()

            Spacer()

            Button(action: logOut) {
                Text("Logout")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }

    func logOut() {
        do {
            try Auth.auth().signOut()
<<<<<<< HEAD
            DispatchQueue.main.async {
                appState.isLoggedIn = false
                print("Successfully logged out.")
            }
=======
            appState.isLoggedIn = false
            print("Successfully logged out. Returning to login screen.")
>>>>>>> main
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
