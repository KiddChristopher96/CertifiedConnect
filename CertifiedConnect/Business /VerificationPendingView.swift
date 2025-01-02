import SwiftUI
import FirebaseAuth

struct VerificationPendingView: View {
    @EnvironmentObject var appState: AppState // Use shared app state for navigation

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

            // Help Button
            Button(action: {
                // Optional: Add help or contact support action
            }) {
                Text("Need Help?")
                    .foregroundColor(.blue)
            }

            // Logout Button
            Button(action: logOut) {
                Text("Logout")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .padding()
    }

    func logOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                appState.isLoggedIn = false // Update app state to show the login screen
                print("Successfully logged out. Returning to login screen.")
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
