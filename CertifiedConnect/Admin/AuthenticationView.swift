import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AuthenticationView: View {
    @EnvironmentObject var appState: AppState
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    var onLogin: () -> Void // Callback for handling login actions

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome")
                .font(.largeTitle)
                .padding()

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            // Login Button
            Button(action: login) {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            // Sign-Up Button
            Button(action: signUp) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }

    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            // Call onLogin after successful login
            onLogin()
        }
    }

    func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }

            guard let userUID = result?.user.uid else {
                errorMessage = "Unable to retrieve user UID "
                return
            }

            // Save new user to Firestore
            let db = Firestore.firestore()
            db.collection("users").document(userUID).setData([
                "name": email, // Placeholder name
                "email": email,
                "role": "BusinessOwner" // Default role
            ]) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                // Call onLogin after successful sign-up
                onLogin()
            }
        }
    }
}


