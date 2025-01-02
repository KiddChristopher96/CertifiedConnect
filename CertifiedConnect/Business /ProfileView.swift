import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ProfileView: View {
    @State private var business: Business?
    @State private var isLoading: Bool = true
    @State private var showEditProfile = false

    var body: some View {
        NavigationView {
            if isLoading {
                ProgressView("Loading your profile...")
            } else if let business = business {
                VStack(spacing: 20) {
                    // Header
                    Text("Welcome, \(business.businessName)!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding()

                    // Profile Details
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Owner: \(business.ownerName)")
                            .font(.headline)
                        Text("Email: \(business.email)")
                        Text("Phone: \(business.phone)")
                        Text("Certifications: \(business.certifications.joined(separator: ", "))")
                        Text("Insurance Verified: \(business.insuranceVerified ? "Yes ✅" : "No ⏳")")
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                    // Actions
                    Button(action: {
                        showEditProfile = true
                    }) {
                        Text("Edit Profile")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .navigationTitle("Business Profile")
                .sheet(isPresented: $showEditProfile) {
                    EditProfileView(business: business)
                }
            } else {
                Text("No profile found. Please complete your onboarding.")
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .onAppear(perform: fetchBusinessProfile)
    }

    func fetchBusinessProfile() {
        let db = Firestore.firestore()
        guard let userUID = Auth.auth().currentUser?.uid else {
            print("Error: User not authenticated")
            isLoading = false
            return
        }

        db.collection("businesses").whereField("submittedBy", isEqualTo: userUID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching business profile: \(error.localizedDescription)")
                    isLoading = false
                    return
                }
                if let document = snapshot?.documents.first {
                    let data = document.data()
                    self.business = Business(
                        id: document.documentID,
                        businessName: data["businessName"] as? String ?? "",
                        ownerName: data["ownerName"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        phone: data["phone"] as? String ?? "",
                        certifications: data["certifications"] as? [String] ?? [],
                        insuranceVerified: data["insuranceVerified"] as? Bool ?? false,
                        submittedBy: data["submittedBy"] as? String ?? ""
                    )
                }
                isLoading = false
            }
    }
}

