import Foundation
import Contacts

public struct ImportableContact: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let birthDay: Int
    public let birthMonth: Int
    public let birthYear: Int?
    public var isSelected: Bool
    public var isAlreadyImported: Bool
    public let imageData: Data?
    
    @MainActor
    public var formattedBirthday: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: BirthdayStore.shared.currentLanguage.resolvedCode)
        let monthName = formatter.monthSymbols[max(0, min(11, birthMonth - 1))].capitalized
        if let year = birthYear {
            return "\(birthDay) \(monthName) \(year)"
        } else {
            return "\(birthDay) \(monthName)"
        }
    }
}

@MainActor
public final class ContactsImporter: ObservableObject {
    public static let shared = ContactsImporter()
    
    @Published public var contactsWithBirthdays: [ImportableContact] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var authorizationStatus: CNAuthorizationStatus = .notDetermined
    
    private let contactStore = CNContactStore()
    
    public init() {
        authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
    }
    
    public func requestAccessAndFetch(existingPeople: [BirthdayPerson]) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let granted = try await contactStore.requestAccess(for: .contacts)
            authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
            if granted {
                fetchContacts(existingPeople: existingPeople)
            } else {
                errorMessage = "Contacts access was denied in iOS Settings."
            }
        } catch {
            errorMessage = "Unable to access contacts: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func fetchContacts(existingPeople: [BirthdayPerson]) {
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactBirthdayKey as CNKeyDescriptor,
            CNContactThumbnailImageDataKey as CNKeyDescriptor
        ]
        
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
        var results: [ImportableContact] = []
        
        do {
            try contactStore.enumerateContacts(with: request) { contact, _ in
                guard let birthday = contact.birthday,
                      let month = birthday.month,
                      let day = birthday.day else {
                    return
                }
                
                let fullName = [contact.givenName, contact.familyName]
                    .filter { !$0.isEmpty }
                    .joined(separator: " ")
                
                let name = fullName.isEmpty ? "No Name" : fullName
                
                // Check if already imported by matching name and date
                let alreadyImported = existingPeople.contains { person in
                    person.name.caseInsensitiveCompare(name) == .orderedSame &&
                    person.birthDay == day &&
                    person.birthMonth == month
                }
                
                let importable = ImportableContact(
                    id: contact.identifier,
                    name: name,
                    birthDay: day,
                    birthMonth: month,
                    birthYear: birthday.year,
                    isSelected: !alreadyImported,
                    isAlreadyImported: alreadyImported,
                    imageData: contact.thumbnailImageData
                )
                
                results.append(importable)
            }
            
            // Sort alphabetically by name
            self.contactsWithBirthdays = results.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        } catch {
            self.errorMessage = "Error reading address book: \(error.localizedDescription)"
        }
    }
    
    /// Syncs/updates birthday, name and avatar photo directly into the iOS Address Book contact according to settings
    public func performSyncContactToiOS(
        contactIdentifier: String? = nil,
        name: String,
        day: Int,
        month: Int,
        year: Int?,
        avatarImageData: Data?,
        syncName: Bool = false,
        syncPhoto: Bool = false,
        syncBirthday: Bool = true
    ) async {
        guard syncName || syncPhoto || syncBirthday else { return }
        
        do {
            let status = CNContactStore.authorizationStatus(for: .contacts)
            if status == .notDetermined {
                let granted = try await contactStore.requestAccess(for: .contacts)
                if !granted { return }
            } else if status == .denied || status == .restricted {
                print("Contacts access denied or restricted")
                return
            }
            
            let keysToFetch: [CNKeyDescriptor] = [
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactBirthdayKey as CNKeyDescriptor,
                CNContactImageDataKey as CNKeyDescriptor,
                CNContactThumbnailImageDataKey as CNKeyDescriptor,
                CNContactFormatter.descriptorForRequiredKeys(for: .fullName)
            ]
            
            var contactToUpdate: CNMutableContact? = nil
            
            if let id = contactIdentifier, !id.isEmpty {
                if let contact = try? contactStore.unifiedContact(withIdentifier: id, keysToFetch: keysToFetch),
                   let mutable = contact.mutableCopy() as? CNMutableContact {
                    contactToUpdate = mutable
                }
            }
            
            if contactToUpdate == nil {
                let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    let predicate = CNContact.predicateForContacts(matchingName: trimmed)
                    if let matches = try? contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch),
                       let first = matches.first,
                       let mutable = first.mutableCopy() as? CNMutableContact {
                        contactToUpdate = mutable
                    }
                }
            }
            
            guard let mutableContact = contactToUpdate else {
                print("No matching iOS contact found for \(name)")
                return
            }
            
            // 1. Update birthday date if enabled
            if syncBirthday {
                var dateComponents = DateComponents()
                dateComponents.day = day
                dateComponents.month = month
                dateComponents.year = year
                mutableContact.birthday = dateComponents
            }
            
            // 2. Update contact name if enabled
            if syncName {
                let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                let parts = trimmed.split(separator: " ")
                if parts.count > 1 {
                    mutableContact.givenName = String(parts[0])
                    mutableContact.familyName = parts.dropFirst().joined(separator: " ")
                } else if !parts.isEmpty {
                    mutableContact.givenName = String(parts[0])
                    mutableContact.familyName = ""
                }
            }
            
            // 3. Update iOS contact photo if enabled
            if syncPhoto, let avatarImageData = avatarImageData {
                mutableContact.imageData = avatarImageData
            }
            
            let saveRequest = CNSaveRequest()
            saveRequest.update(mutableContact)
            try contactStore.execute(saveRequest)
            print("iOS Contact successfully updated (syncName: \(syncName), syncPhoto: \(syncPhoto), syncBirthday: \(syncBirthday)): \(mutableContact.identifier)")
        } catch {
            print("Note: unable to sync to CNContact: \(error)")
        }
    }
    
    public func syncContactToiOS(
        contactIdentifier: String? = nil,
        name: String,
        day: Int,
        month: Int,
        year: Int?,
        avatarImageData: Data?,
        syncName: Bool = false,
        syncPhoto: Bool = false,
        syncBirthday: Bool = true
    ) {
        Task {
            await performSyncContactToiOS(
                contactIdentifier: contactIdentifier,
                name: name,
                day: day,
                month: month,
                year: year,
                avatarImageData: avatarImageData,
                syncName: syncName,
                syncPhoto: syncPhoto,
                syncBirthday: syncBirthday
            )
        }
    }
    
    /// Syncs all currently registered birthdays to matching contacts in address book
    public func syncAllPeopleToContacts(people: [BirthdayPerson], syncName: Bool, syncPhoto: Bool, syncBirthday: Bool) async -> Int {
        guard syncName || syncPhoto || syncBirthday else { return 0 }
        var updatedCount = 0
        for person in people where person.eventType == .birthday {
            await performSyncContactToiOS(
                contactIdentifier: person.linkedContactId,
                name: person.name,
                day: person.birthDay,
                month: person.birthMonth,
                year: person.birthYear,
                avatarImageData: person.avatarImageData,
                syncName: syncName,
                syncPhoto: syncPhoto,
                syncBirthday: syncBirthday
            )
            updatedCount += 1
        }
        return updatedCount
    }
}

