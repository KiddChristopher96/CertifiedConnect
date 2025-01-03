import SwiftUI

struct TextAlertView: UIViewControllerRepresentable {
    let title: String
    let message: String?
    let placeholder: String
    let callback: (String?) -> Void

    func makeUIViewController(context: Context) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = placeholder
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            callback(nil)
        })
        alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            callback(alert.textFields?.first?.text)
        })
        return alert
    }

    func updateUIViewController(_ uiViewController: UIAlertController, context: Context) {}
}

extension View {
    func alert(
        _ title: String,
        isPresented: Binding<Bool>,
        _ callback: @escaping (String?) -> Void
    ) -> some View {
        self.background(
            TextAlertView(
                title: title,
                message: nil,
                placeholder: "Enter service name",
                callback: { input in
                    isPresented.wrappedValue = false
                    callback(input)
                }
            )
            .opacity(isPresented.wrappedValue ? 1 : 0)
        )
    }
}
