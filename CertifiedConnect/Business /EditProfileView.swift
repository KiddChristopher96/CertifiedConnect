import SwiftUI
import FirebaseFirestore

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode // Used to dismiss the sheet
    @State var business: Business
    @State private var certificationsText: String
    @State private var isSaving = false

    init(business: Business) {
        self.business = business
        _certificationsText = State(initialValue: business.certifications.joined(separator: ", "))
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
                presentationMode.wrappedValue.dismiss() // Dismiss the sheet
            })
        }
    }

    func saveProfile() {
        isSaving = true

        // Parse certifications from text field
        business.certifications = certificationsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }

        // Update Firestore
        let db = Firestore.firestore()
        db.collection("businesses").document(business.id).setData([
            "businessName": business.businessName,
            "ownerName": business.ownerName,
            "email": business.email,
            "phone": business.phone,
            "certifications": business.certifications
        ], merge: true) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error saving profile: \(error.localizedDescription)")
                } else {
                    print("Profile updated successfully")
                    presentationMode.wrappedValue.dismiss() // Dismiss the sheet after saving
                }
                isSaving = false
            }
        }
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(business: Business(
            id: "1",
            businessName: "Mock Business",
            ownerName: "Owner Name",
            email: "email@example.com",
            phone: "123-456-7890",
            certifications: ["Certification 1", "Certification 2"],
            insuranceVerified: true,
            submittedBy: "userUID"
        ))
    }
}
