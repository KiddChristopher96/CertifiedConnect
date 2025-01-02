import SwiftUI

struct BusinessDashboardView: View {
    let businessName: String
    let isInsuranceVerified: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome, \(businessName)!")
                .font(.largeTitle)
                .padding()

            if isInsuranceVerified {
                Text("Your insurance is verified. ✅")
                    .font(.headline)
                    .foregroundColor(.green)
            } else {
                Text("Your insurance is pending verification. ⏳")
                    .font(.headline)
                    .foregroundColor(.orange)
            }

            Text("Here you can manage your business profile, view service requests, and more.")
                .multilineTextAlignment(.center)
                .padding()

            Spacer()
        }
        .padding()
        .navigationTitle("Dashboard")
    }
}

struct BusinessDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        BusinessDashboardView(businessName: "Mock Business", isInsuranceVerified: false)
    }
}
