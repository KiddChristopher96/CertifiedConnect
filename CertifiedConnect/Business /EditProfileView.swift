import SwiftUI
import FirebaseFirestore

struct EditProfileView: View {
    @State var business: Business
    @State private var isSaving = false
    @State private var certificationsText: String // New state variable for the certifications text field

    init(business: Business) {
        self.business = business
        _certificationsText = State(initialValue: business.certifications.joined(separator: ", ")) // Initialize with certifications
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Business Details")) {
                    TextField("Business Name", text: $business.businessName)
                    TextField("Owner Name", text: $business.ownerName)
                    TextField("Email", text: $business.email)
                        .keyboardType(.emailAddress)
                    TextField("Phone", text: $business.phone)
                        .keyboardType(.phonePad)
                }

                Section(header: Text("Certifications")) {
                    TextField("Certifications (comma-separated)", text: $certificationsText)
                }

                Section {
                    Button(action: saveProfile) {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Save Changes")
                        }
                    }
                    .disabled(isSaving)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(trailing: Button("Close") {
                // Close this sheet
            })
        }
    }

    func saveProfile() {
        isSaving = true

        // Update certifications from the text field
        business.certifications = certificationsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }

        let db = Firestore.firestore()
        db.collection("businesses").document(business.id).setData([
            "businessName": business.businessName,
            "ownerName": business.ownerName,
            "email": business.email,
            "phone": business.phone,
            "certifications": business.certifications
        ], merge: true) { error in
            if let error = error {
                print("Error saving profile: \(error.localizedDescription)")
            } else {
                print("Profile updated successfully")
            }
            isSaving = false
        }
    }
}
