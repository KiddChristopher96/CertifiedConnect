import SwiftUI
import PhotosUI
import FirebaseFirestore
import FirebaseStorage

struct ServiceDetailView: View {
    let serviceName: String
    @State private var photos: [Photo] = [] // A list of photo objects
    @State private var showAddPhotoModal = false
    @State private var isLoading = true
    @State private var businessId: String = "YOUR_BUSINESS_ID" // Replace with actual ID

    var body: some View {
        VStack {
            Text(serviceName)
                .font(.largeTitle)
                .padding()

            if isLoading {
                ProgressView("Loading photos...")
            } else if photos.isEmpty {
                Text("No photos yet. Add some!")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(photos) { photo in
                        VStack {
                            if let url = URL(string: photo.url) {
                                AsyncImage(url: url) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                }
                                .frame(height: 100)
                                .clipped()
                                .cornerRadius(10)
                            }

                            Text(photo.description)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                        .cornerRadius(10)
                    }
                }
                .padding()
            }

            Button(action: { showAddPhotoModal = true }) {
                Text("Add Photo")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .padding()
        .navigationTitle(serviceName)
        .onAppear(perform: fetchPhotos)
        .sheet(isPresented: $showAddPhotoModal) {
            AddPhotoView(serviceName: serviceName, businessId: businessId, onPhotoAdded: fetchPhotos)
        }
    }

    func fetchPhotos() {
        let db = Firestore.firestore()
        isLoading = true
        db.collection("businesses").document(businessId).collection("services")
            .document(serviceName).collection("photos")
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error fetching photos: \(error.localizedDescription)")
                        isLoading = false
                        return
                    }

                    self.photos = snapshot?.documents.compactMap { doc in
                        let data = doc.data()
                        return Photo(
                            id: doc.documentID,
                            url: data["url"] as? String ?? "",
                            description: data["description"] as? String ?? ""
                        )
                    } ?? []
                    isLoading = false
                }
            }
    }
}
