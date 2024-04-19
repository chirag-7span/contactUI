import SwiftUI

// Define the ContactData structure
struct ContactData: Identifiable {
    let id = UUID()
    let firstName: String
    let lastName: String
    let contactNum: String
    let email: String
    let DOB: Date
    let profileImg: UIImage
}

// Define the ContentView
struct ContentView: View {
    @EnvironmentObject var contactList: ContactList // Inject ContactList into the environment
    @State private var isAddingContact = false // Track if the user is adding a new contact
    @State private var selectedContact: ContactData? // Track the selected contact

    var body: some View {
        NavigationView {
            ContactListView(isAddingContact: $isAddingContact, selectedContact: $selectedContact)
                .navigationBarItems(trailing:
                                        NavigationLink(destination: AddContactView(contact: selectedContact)) {
                        Image(systemName: "plus")
                    }
                )
                .sheet(isPresented: $isAddingContact) {
                    if let selectedContact = selectedContact {
                        AddContactView(contact: selectedContact)
                    } else {
                        // Present add contact view here
                    }
                }
        }
    }
}


struct SearchBar: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            TextField("Search", text: $searchText)
                .padding(.horizontal, 25)
        }
        .frame(height: 50)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

// Define the ContactListView
struct ContactListView: View {
    @EnvironmentObject var contactList: ContactList
    @Binding var isAddingContact: Bool // Binding to track if a new contact is being added
    @Binding var selectedContact: ContactData? // Binding to track the selected contact
    @State private var searchText = "" // Text to store the search query
    @State private var isAscendingOrder = true // Track the sorting order
    @State private var existingInitials: Set<String> = Set() // Set to track existing initials
    
    var filteredContacts: [ContactData] {
        if searchText.isEmpty {
            return contactList.contacts
        } else {
            return contactList.contacts.filter { contact in
                contact.firstName.localizedCaseInsensitiveContains(searchText) || contact.lastName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var sortedContacts: [ContactData] {
        if isAscendingOrder {
            return filteredContacts.sorted { $0.firstName < $1.firstName }
        } else {
            return filteredContacts.sorted { $0.firstName > $1.firstName }
        }
    }

    var body: some View {
        VStack {
            HStack {
                SearchBar(searchText: $searchText) // Add the search bar
                Button(action: {
                    isAscendingOrder.toggle() // Toggle the sorting order
                }) {
                    Image(systemName: isAscendingOrder ? "arrow.up.circle" : "arrow.down.circle")
                        .padding()
                }
            }

            List {
                ForEach(sortedContacts) { contact in
                    let initial = contact.initials
                    let insertionResult = existingInitials.insert(initial)
                    if insertionResult.inserted {
                        // Insertion was successful, meaning the initial was not previously present
                        Section(header: Text(initial)) {
                            ContactRowView(contact: contact)
                                .onTapGesture {
                                    selectedContact = contact // Set the selected contact
                                    isAddingContact = true // Set the flag to true when a contact is selected
                                }
                        }
                    } else {
                        // The initial already exists, so no need to create a new section
                        ContactRowView(contact: contact)
                            .onTapGesture {
                                selectedContact = contact // Set the selected contact
                                isAddingContact = true // Set the flag to true when a contact is selected
                            }
                    }
                }
            }
        }
        .navigationTitle("Contacts")
    }
}

// Define the ContactRowView
struct ContactRowView: View {
    let contact: ContactData
    
    var body: some View {
        NavigationLink(destination: AddContactView(contact: contact)) {
            HStack {
                Image(uiImage: contact.profileImg)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                VStack(alignment: .leading) {
                    Text("\(contact.firstName) \(contact.lastName)")
                }
                Spacer()
                Image(systemName: "pencil.circle")
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}

// Define the EditContactView
struct EditContactView: View {
    let contact: ContactData
    
    var body: some View {
        // Implement the edit view here using the contact data
        Text("Edit \(contact.firstName) \(contact.lastName)")
    }
}

// Define the main app struct
@main
struct YourAppName: App {
    @StateObject var contactList = ContactList() // Create an instance of ContactList
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(contactList) // Inject ContactList into the environment
        }
    }
}

// Define an extension to get initials from first name and last name
extension ContactData {
    var initials: String {
        let firstInitial = firstName.first.map { String($0) } ?? ""
        return "\(firstInitial)"
    }
}

//class ContactList: ObservableObject {
//    @Published var contacts: [ContactData] = []
//
//    // Add any additional functions or properties you need
//}
