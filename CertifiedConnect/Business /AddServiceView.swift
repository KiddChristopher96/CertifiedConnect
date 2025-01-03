import SwiftUI

struct AddServiceView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var serviceName: String = ""
    var addService: (String) -> Void

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter service name", text: $serviceName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    addService(serviceName)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Add Service")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(serviceName.isEmpty) // Disable button if input is empty

                Spacer()
            }
            .padding()
            .navigationTitle("Add Service")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
