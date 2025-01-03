import SwiftUI
import PhotosUI
import FirebaseStorage
import FirebaseFirestore

struct AddPhotoView: View {
    let serviceName: String
    let businessId: String
    var onPhotoAdded: () -> Void

    @Environment(\.presentationMode) var presentationMode
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil
    @State private var photoDescription: String = ""
    @State private var isSaving = false

    var body: some View {
        NavigationView {
            VStack {
                if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .padding()
                } else {
                    PhotosPicker(selection: $selectedImage, matching: .images, photoLibrary: .shared()) {
                        Text("Select a Photo")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .onChange(of: selectedImage) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                self.imageData = data
                            }
                        }
                    }
                }

                TextField("Enter photo description", text: $photoDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: savePhoto) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Save Photo")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(isSaving || imageData == nil || photoDescription.isEmpty)
                .padding()

                Spacer()
            }
            .padding()
            .navigationTitle("Add Photo")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    func savePhoto() {
        guard let imageData = imageData else { return }
        isSaving = true

        // Upload image to Firebase Storage
        let storage = Storage.storage()
        let storageRef = storage.reference().child("businesses/\(businessId)/services/\(serviceName)/\(UUID().uuidString).jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                isSaving = false
                return
            }

            storageRef.downloadURL { url, error in
                guard let url = url else {
                    print("Error fetching image URL: \(error?.localizedDescription ?? "Unknown error")")
                    isSaving = false
                    return
                }

                // Save photo metadata to Firestore
                let db = Firestore.firestore()
                let photoData: [String: Any] = [
                    "url": url.absoluteString,
                    "description": photoDescription,
                    "timestamp": FieldValue.serverTimestamp()
                ]
                db.collection("businesses").document(businessId)
                    .collection("services").document(serviceName)
                    .collection("photos").addDocument(data: photoData) { error in
                        if let error = error {
                            print("Error saving photo metadata: \(error.localizedDescription)")
                        } else {
                            print("Photo metadata saved successfully.")
                            onPhotoAdded()
                            presentationMode.wrappedValue.dismiss()
                        }
                        isSaving = false
                    }
            }
        }
    }
}
