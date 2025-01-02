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
                        .navigationTitle("Admin Panel")
                } else if let isInsuranceVerified = isInsuranceVerified {
                    if isInsuranceVerified {
                        // Business profile is verified
                        BusinessDashboardView(businessName: currentUser.name, isInsuranceVerified: isInsuranceVerified)
                    } else {
                        // Business profile is not verified
                        VerificationPendingView()
                            .environmentObject(AppState())
                    }
                } else {
                    // No business profile found
                    VStack {
                        Text("No business profile found.")
                            .font(.headline)
                            .padding()

                        Text("Please complete your onboarding.")
                            .multilineTextAlignment(.center)
                            .padding()

                        NavigationLink(destination: BusinessOnboardingView()) {
                            Text("Go to Onboarding")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top, 10)
                    }
                }
            }
        }
        .onAppear {
            print("UI: ContentView onAppear triggered")
            if currentUser.role != "Admin" {
                checkInsuranceVerification()
            } else {
                isLoading = false // Admins bypass insurance check
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

        print("Checking insurance verification for user: \(userUID)")
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
                        print("No business profile found for user.")
                        self.isInsuranceVerified = nil
                    }
                    isLoading = false
                }
            }
    }
}
