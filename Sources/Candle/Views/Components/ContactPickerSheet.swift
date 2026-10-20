import SwiftUI
import Contacts
import ContactsUI

/// Presents native Apple Contacts picker (CNContactPickerViewController)
public struct ContactPickerSheet: UIViewControllerRepresentable {
    public var onSelectContact: (CNContact) -> Void
    public var onCancel: (() -> Void)? = nil
    
    public init(onSelectContact: @escaping (CNContact) -> Void, onCancel: (() -> Void)? = nil) {
        self.onSelectContact = onSelectContact
        self.onCancel = onCancel
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(onSelectContact: onSelectContact, onCancel: onCancel)
    }
    
    public func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        picker.displayedPropertyKeys = [
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactBirthdayKey,
            CNContactImageDataKey,
            CNContactThumbnailImageDataKey
        ]
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {
        context.coordinator.onSelectContact = onSelectContact
        context.coordinator.onCancel = onCancel
    }
    
    public final class Coordinator: NSObject, CNContactPickerDelegate, @unchecked Sendable {
        var onSelectContact: ((CNContact) -> Void)?
        var onCancel: (() -> Void)?
        
        init(onSelectContact: @escaping (CNContact) -> Void, onCancel: (() -> Void)?) {
            self.onSelectContact = onSelectContact
            self.onCancel = onCancel
        }
        
        public func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            onSelectContact?(contact)
        }
        
        public func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            onCancel?()
        }
    }
}
