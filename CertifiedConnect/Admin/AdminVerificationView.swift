import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AdminVerificationView: View {
    @State private var pendingBusinesses: [Business] = []
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(pendingBusinesses) { business in
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Business: \(business.businessName)")
                                .font(.headline)
                            Text("Owner: \(business.ownerName)")
                            Text("Email: \(business.email)")
                            Text("Phone: \(business.phone)")

                            if business.insuranceVerified {
                                Text("Insurance: Verified ✅")
                                    .foregroundColor(.green)
                            } else {
                                Text("Insurance: Pending ⏳")
                                    .foregroundColor(.orange)
                            }

                            HStack {
                                Spacer()
                                Button(action: {
                                    verifyInsurance(for: business.id)
                                }) {
                                    Text("Verify Insurance")
                                        .padding(5)
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(5)
                                }
                                .disabled(business.insuranceVerified)
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
                .navigationTitle("Pending Verifications")
                .onAppear(perform: fetchPendingBusinesses)

                Button(action: logOut) {
                    Text("Logout")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 10)
            }
        }
    }

    func fetchPendingBusinesses() {
        let db = Firestore.firestore()
        db.collection("businesses").whereField("insuranceVerified", isEqualTo: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching businesses: \(error.localizedDescription)")
                    return
                }
                pendingBusinesses = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    return Business(
                        id: document.documentID,
                        businessName: data["businessName"] as? String ?? "",
                        ownerName: data["ownerName"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        phone: data["phone"] as? String ?? "",
                        certifications: data["certifications"] as? [String] ?? [],
                        insuranceVerified: data["insuranceVerified"] as? Bool ?? false,
                        submittedBy: data["submittedBy"] as? String ?? ""
                    )
                } ?? []
            }
    }

    func verifyInsurance(for id: String) {
        let db = Firestore.firestore()
        db.collection("businesses").document(id).updateData(["insuranceVerified": true]) { error in
            if let error = error {
                print("Error verifying insurance: \(error.localizedDescription)")
            } else {
                fetchPendingBusinesses()
            }
        }
    }

    func logOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                appState.isLoggedIn = false
                print("Admin logged out successfully.")
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
