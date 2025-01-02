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
                if currentUser.role == "Admin" {
                    AdminVerificationView()
                } else if let isInsuranceVerified = isInsuranceVerified {
                    if isInsuranceVerified {
                        BusinessDashboardView(businessName: currentUser.name, isInsuranceVerified: isInsuranceVerified)
                    } else {
                        VerificationPendingView()
                            .environmentObject(AppState())
                    }
                } else {
                    Text("No business profile found. Please complete your onboarding.")
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
        }
        .onAppear {
            if currentUser.role != "Admin" {
                checkInsuranceVerification()
            } else {
                isLoading = false
            }
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
