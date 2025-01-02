import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ContentView: View {
    var currentUser: User
    @EnvironmentObject var appState: AppState
    @State private var isInsuranceVerified: Bool?
    @State private var isLoading: Bool = true

    var body: some View {
        NavigationView {
            if isLoading {
                ProgressView("Checking your profile...")
            } else {
                if currentUser.role == "Admin" {
                    AdminVerificationView()
                } else if let isInsuranceVerified = isInsuranceVerified {
                    if isInsuranceVerified {
<<<<<<< HEAD
                        BusinessDashboardView(businessName: currentUser.name, isInsuranceVerified: isInsuranceVerified)
=======
                        VStack {
                            BusinessDashboardView(businessName: currentUser.name, isInsuranceVerified: isInsuranceVerified)
                            Button(action: logOut) {
                                Text("Logout")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding()
                        }
>>>>>>> main
                    } else {
                        VerificationPendingView()
                            .environmentObject(appState)
                    }
                } else {
<<<<<<< HEAD
                    Text("No business profile found. Please complete your onboarding.")
                        .multilineTextAlignment(.center)
=======
                    VStack {
                        Text("No business profile found. Please complete your onboarding.")
                            .multilineTextAlignment(.center)
                            .padding()
                        Button(action: logOut) {
                            Text("Logout")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
>>>>>>> main
                        .padding()
                    }
                }
            }
        }
        .onAppear {
<<<<<<< HEAD
            if currentUser.role != "Admin" {
                checkInsuranceVerification()
            } else {
                isLoading = false
            }
=======
            checkInsuranceVerification()
>>>>>>> main
        }
    }

    func logOut() {
        do {
            try Auth.auth().signOut()
            appState.isLoggedIn = false
            print("Successfully logged out. Returning to login screen.")
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    func checkInsuranceVerification() {
        let db = Firestore.firestore()
        guard let userUID = Auth.auth().currentUser?.uid else {
            print("Error: User not authenticated")
            isLoading = false
            return
        }

        db.collection("businesses").whereField("submittedBy", isEqualTo: userUID)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error fetching business data: \(error.localizedDescription)")
                        isLoading = false
                        return
                    }
                    if let document = snapshot?.documents.first {
                        let data = document.data()
                        self.isInsuranceVerified = data["insuranceVerified"] as? Bool
                    } else {
                        print("No business profile found for user")
                        self.isInsuranceVerified = nil
                    }
                    isLoading = false
                }
            }
    }
}
