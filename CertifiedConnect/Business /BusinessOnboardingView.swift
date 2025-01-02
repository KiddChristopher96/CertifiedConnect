import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore

struct BusinessOnboardingView: View {
    @State private var businessName: String = ""
    @State private var ownerName: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var certifications: String = ""
    @State private var selectedInsuranceFile: PhotosPickerItem? = nil
    @State private var insuranceDocument: Data? = nil
    @State private var navigateToDashboard = false
    @State private var isInsuranceVerified = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Business Details")) {
                    TextField("Business Name", text: $businessName)
                    TextField("Owner Name", text: $ownerName)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("Phone Number", text: $phone)
                        .keyboardType(.phonePad)
                }

                Section(header: Text("Additional Details")) {
                    TextField("Certifications (comma-separated)", text: $certifications)
                    
                    PhotosPicker(
                        selection: $selectedInsuranceFile,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Text(insuranceDocument == nil ? "Upload Proof of Insurance" : "Document Uploaded")
                            .foregroundColor(insuranceDocument == nil ? .blue : .green)
                    }
                    .onChange(of: selectedInsuranceFile) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                insuranceDocument = data
                            }
                        }
                    }
                }

                NavigationLink(
                    destination: BusinessDashboardView(businessName: businessName, isInsuranceVerified: isInsuranceVerified),
                    isActive: $navigateToDashboard
                ) {
                    EmptyView()
                }

                Button(action: saveBusinessProfile) {
                    Text("Save Profile")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(businessName.isEmpty || ownerName.isEmpty || email.isEmpty || phone.isEmpty) // Disable button if fields are empty
            }
            .navigationTitle("Business Onboarding")
        }
    }

    func saveBusinessProfile() {
        print("Save Business Profile function called")
        
        // Ensure all fields are filled
        guard !businessName.isEmpty, !ownerName.isEmpty, !email.isEmpty, !phone.isEmpty else {
            print("Error: All fields must be filled")
            return
        }

        print("All fields are valid")
        
        let db = Firestore.firestore()
        guard let userUID = Auth.auth().currentUser?.uid else {
            print("Error: User not authenticated")
            return
        }

        print("Authenticated user UID: \(userUID)")

        // Prepare business data
        let businessData: [String: Any] = [
            "businessName": businessName,
            "ownerName": ownerName,
            "email": email,
            "phone": phone,
            "certifications": certifications.components(separatedBy: ","),
            "insuranceVerified": false, // Default to false
            "submittedBy": userUID
        ]

        // Save to Firestore
        db.collection("businesses").addDocument(data: businessData) { error in
            if let error = error {
                print("Error saving business: \(error.localizedDescription)")
            } else {
                print("Business saved successfully")
                navigateToDashboard = true
            }
        }
    }

}
