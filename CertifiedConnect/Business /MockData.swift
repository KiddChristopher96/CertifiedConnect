import Foundation

struct User {
    let id: String
    let name: String
    let role: String // "Admin" or "BusinessOwner"
}

import Foundation

struct Business: Identifiable {
    let id: String
    var businessName: String // Matches Firestore field
    var ownerName: String
    var email: String
    var phone: String
    var certifications: [String]
    var insuranceVerified: Bool // Matches Firestore field
    var submittedBy: String // Links to the submitting user
}


struct MockBusiness {
    static var pendingBusinesses: [Business] = [
        Business(
            id: "1",
            businessName: "ABC Plumbing",
            ownerName: "John Doe",
            email: "johndoe@abcplumbing.com",
            phone: "123-456-7890", // Phone as a string
            certifications: ["Licensed Plumber"], // Certifications as an array
            insuranceVerified: false, // Matches Firestore field
            submittedBy: "userUID1" // UID of the submitting user
        ),
        Business(
            id: "2",
            businessName: "Green Landscaping",
            ownerName: "Jane Smith",
            email: "janesmith@greenlandscaping.com",
            phone: "987-654-3210",
            certifications: ["Certified Arborist", "Sustainable Practices"],
            insuranceVerified: false,
            submittedBy: "userUID2"
        )
    ]
}

