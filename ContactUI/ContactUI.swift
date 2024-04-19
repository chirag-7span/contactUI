import SwiftUI

struct AddContactView: View {
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var contactNum = ""
    @State private var email = ""
    @State private var dob = Date() // Initial date for date of birth
    @State private var profileImage: UIImage? = UIImage(systemName: "person.fill") // Set default image to "person"
    @State private var isShowingImagePicker = false
    
    init(contact: ContactData?) {
           _firstName = State(initialValue: contact?.firstName ?? "")
           _lastName = State(initialValue: contact?.lastName ?? "")
           _contactNum = State(initialValue: contact?.contactNum ?? "")
           _email = State(initialValue: contact?.email ?? "")
        _dob = State(initialValue: contact?.DOB ?? Date.now      )
           _profileImage = State(initialValue: contact?.profileImg ?? UIImage(systemName: "person.fill")!)
       }
    
    
    @EnvironmentObject var contactList: ContactList
    @Environment(\.presentationMode) var presentationMode // Access the presentation mode
    
    var isSaveDisabled: Bool {
        // Check if any of the text fields are empty or validations fail
        firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !isValidName(firstName) || !isValidName(lastName) ||
            contactNum.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !isNumeric(contactNum) ||
            email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !isValidEmail(email)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .center, spacing: 25) {
                    // Display selected image preview or default "person" image
                    Image(uiImage: profileImage ?? UIImage(systemName: "person.fill")!) // Use default "person" image if profileImage is nil
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    
                    Button(action: {
                        isShowingImagePicker = true
                    }) {
                        Text("Choose Profile Image")
                    }
                    .sheet(isPresented: $isShowingImagePicker) {
                        ImagePicker(image: $profileImage)
                    }
                    
                    TextField("First Name", text: $firstName)
                        .onChange(of: firstName) { newValue in
                            // Limit input to alphabets only
                            if !newValue.isEmpty && !newValue.isAlphabetic {
                                firstName = String(newValue.dropLast())
                            }
                        }
                    TextField("Last Name", text: $lastName)
                        .onChange(of: lastName) { newValue in
                            // Limit input to alphabets only
                            if !newValue.isEmpty && !newValue.isAlphabetic {
                                lastName = String(newValue.dropLast())
                            }
                        }
                    TextField("Contact Number", text: $contactNum)
                        .keyboardType(.numberPad)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .onChange(of: email) { newValue in
                            // Limit input to lowercase letters only
                            if !newValue.isEmpty && !newValue.isLowercased {
                                email = String(newValue.dropLast())
                            }
                        }
                    DatePicker("Date of Birth", selection: $dob, displayedComponents: .date)
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    let contact = ContactData(firstName: firstName, lastName: lastName, contactNum: contactNum, email: email, DOB: dob, profileImg: profileImage ?? UIImage(systemName: "person.fill")!)
                    contactList.contacts.append(contact)
                    profileImage = nil
                    firstName = ""
                    lastName = ""
                    contactNum = ""
                    email = ""
                    dob = Date() // Reset date of birth
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save")
                        .padding()
                        .background(isSaveDisabled ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(isSaveDisabled)
                }
                .padding()
            }
            .padding()
            .navigationTitle("Add Contact")
        }
    }
    
    func isValidName(_ name: String) -> Bool {
        // Validate that the name contains only alphabetic characters
        let nameRegex = "^[a-zA-Z]+$"
        return NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: name)
    }
    
    func isNumeric(_ input: String) -> Bool {
        // Validate that the input contains only numeric characters
        let numericRegex = "^[0-9]*$"
        return NSPredicate(format: "SELF MATCHES %@", numericRegex).evaluate(with: input)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        // Validate email format
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

extension String {
    var isAlphabetic: Bool {
        // Check if the string contains only alphabetic characters
        return !isEmpty && range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }
    
    var isLowercased: Bool {
        // Check if the string contains only lowercase characters
        return !isEmpty && range(of: "[^a-z]", options: .regularExpression) == nil
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
                parent.image = image
            } else if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
class ContactList: ObservableObject {
    @Published var contacts: [ContactData] = []

    // Add any additional functions or properties you need
}
