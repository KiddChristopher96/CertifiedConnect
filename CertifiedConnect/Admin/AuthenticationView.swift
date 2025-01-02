import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AuthenticationView: View {
    @EnvironmentObject var appState: AppState
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    var onLogin: () -> Void

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

            Button(action: login) {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

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
        print("Login button pressed.")
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
                return
            }

            print("Login successful.")
            appState.isLoggedIn = true
            onLogin()
        }
    }

    func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Sign-up error: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
                return
            }

            guard let userUID = result?.user.uid else {
                errorMessage = "Unable to retrieve user UID"
                return
            }

            let db = Firestore.firestore()
            db.collection("users").document(userUID).setData([
                "name": email,
                "email": email,
                "role": "BusinessOwner"
            ]) { error in
                if let error = error {
                    print("Error saving user to Firestore: \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                    return
                }

                print("Sign-up successful.")
                appState.isLoggedIn = true
                onLogin()
            }
        }
    }
}
