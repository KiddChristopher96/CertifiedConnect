import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ContentView: View {
    var currentUser: User
    @State private var isInsuranceVerified: Bool?
    @State private var isLoading: Bool = true

    var body: some View {
        NavigationView {
            if isLoading {
                ProgressView("Checking your profile...")
            } else {
                if let isInsuranceVerified = isInsuranceVerified {
                    if isInsuranceVerified {
                        // Verified: Show the business dashboard
                        BusinessDashboardView(businessName: currentUser.name, isInsuranceVerified: isInsuranceVerified)
                    } else {
                        // Not Verified: Show verification pending screen
                        VerificationPendingView()
                            .environmentObject(AppState())
                    }
                } else {
                    // Error: No business profile found
                    Text("No business profile found. Please complete your onboarding.")
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
        }
        .onAppear {
            print("UI: onAppear triggered in ContentView")
            checkInsuranceVerification()
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
                        print("Insurance verification status: \(self.isInsuranceVerified ?? false)")
                    } else {
                        print("No business profile found for user")
                        self.isInsuranceVerified = nil
                    }
                    isLoading = false
                }
            }
    }
}
