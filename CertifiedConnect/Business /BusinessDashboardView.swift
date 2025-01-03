import SwiftUI
import FirebaseFirestore

struct BusinessDashboardView: View {
    let businessName: String
    let isInsuranceVerified: Bool
    @State private var services: [String] = []
    @State private var newServiceName: String = ""
    @State private var showAddServiceModal: Bool = false // Use modal instead of alert
    @State private var isLoading = true
    @State private var businessId: String = "YOUR_BUSINESS_ID" // Replace with actual ID

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Section
                    VStack(alignment: .center, spacing: 10) {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 100, height: 100)
                            .overlay(Text("B").font(.largeTitle).foregroundColor(.white))

                        Text(businessName)
                            .font(.title)
                            .fontWeight(.bold)

                        Text(isInsuranceVerified ? "Verified ✅" : "Not Verified ⏳")
                            .foregroundColor(isInsuranceVerified ? .green : .orange)
                    }
                    .padding()

                    Divider()

                    // Services Section
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Services Offered")
                                .font(.headline)
                            Spacer()
                            Button(action: { showAddServiceModal = true }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)

                        if isLoading {
                            ProgressView("Loading services...")
                        } else if services.isEmpty {
                            Text("No services added yet.")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        } else {
                            // Services List
                            ForEach(services, id: \.self) { service in
                                NavigationLink(destination: ServiceDetailView(serviceName: service)) {
                                    Text(service)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Dashboard")
            .onAppear(perform: fetchServices)
            .sheet(isPresented: $showAddServiceModal) {
                AddServiceView(addService: addService)
            }
        }
    }

    // Fetch services from Firestore
    func fetchServices() {
        let db = Firestore.firestore()
        isLoading = true
        db.collection("businesses").document(businessId).getDocument { snapshot, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching services: \(error.localizedDescription)")
                    isLoading = false
                    return
                }

                if let data = snapshot?.data(),
                   let fetchedServices = data["services"] as? [String] {
                    self.services = fetchedServices
                }
                isLoading = false
            }
        }
    }

    // Add a new service to Firestore and update the UI
    func addService(_ serviceName: String) {
        guard !serviceName.isEmpty else { return }
        let db = Firestore.firestore()
        services.append(serviceName)

        db.collection("businesses").document(businessId).updateData([
            "services": services
        ]) { error in
            if let error = error {
                print("Error adding service: \(error.localizedDescription)")
            } else {
                print("Service added successfully.")
            }
        }
    }
}
