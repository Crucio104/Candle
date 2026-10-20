import SwiftUI

public struct ContactsImportView: View {
    @ObservedObject var store: BirthdayStore
    @StateObject private var importer = ContactsImporter.shared
    @Environment(\.dismiss) private var dismiss
    
    public init(store: BirthdayStore) {
        self.store = store
    }
    
    private var availableCount: Int {
        importer.contactsWithBirthdays.filter { !$0.isAlreadyImported }.count
    }
    
    private var selectedCount: Int {
        importer.contactsWithBirthdays.filter { $0.isSelected && !$0.isAlreadyImported }.count
    }
    
    public var body: some View {
        NavigationStack {
            Group {
                if importer.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text(store.tr(.readingContacts))
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = importer.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .font(.system(size: 48))
                            .foregroundColor(store.accentPrimary)
                        Text(store.tr(.importContactsTitle))
                            .font(.system(size: 20, weight: .bold))
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Button(store.tr(.retryBtn)) {
                            Task {
                                await importer.requestAccessAndFetch(existingPeople: store.people)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(store.accentPrimary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if importer.contactsWithBirthdays.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text(store.tr(.noContactsWithBirthdayTitle))
                            .font(.system(size: 20, weight: .bold))
                        Text(store.tr(.noContactsWithBirthdayMsg))
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    contactsList
                }
            }
            .background(CandleTheme.background.ignoresSafeArea())
            .navigationTitle(store.tr(.importContactsTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(store.tr(.close)) {
                        dismiss()
                    }
                }
                
                if !importer.contactsWithBirthdays.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(selectedCount == availableCount ? store.tr(.deselectAll) : store.tr(.selectAll)) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                toggleSelectAll()
                            }
                        }
                        .font(.system(size: 14, weight: .medium))
                    }
                }
            }
            .task {
                await importer.requestAccessAndFetch(existingPeople: store.people)
            }
        }
    }
    
    private var contactsList: some View {
        VStack(spacing: 0) {
            // Informational header
            HStack {
                Text(store.tr(.contactsFoundHeader(importer.contactsWithBirthdays.count, availableCount)))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            List {
                ForEach($importer.contactsWithBirthdays) { $contact in
                    HStack(spacing: 14) {
                        if contact.isAlreadyImported {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.secondary.opacity(0.4))
                                .font(.system(size: 20))
                        } else {
                            Image(systemName: contact.isSelected ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(contact.isSelected ? store.accentPrimary : .secondary.opacity(0.3))
                                .font(.system(size: 20))
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(contact.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(contact.isAlreadyImported ? .secondary : .primary)
                            
                            Text(contact.formattedBirthday)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if contact.isAlreadyImported {
                            Text(store.tr(.alreadyInCandle))
                                .font(.system(size: 11, weight: .medium))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.secondary.opacity(0.12))
                                .clipShape(Capsule())
                                .foregroundColor(.secondary)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !contact.isAlreadyImported {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                contact.isSelected.toggle()
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            
            // Bottom import action button
            VStack {
                Button {
                    store.importContacts(importer.contactsWithBirthdays)
                    dismiss()
                } label: {
                    Text(selectedCount > 0 ? store.tr(.importCountBtn(selectedCount)) : store.tr(.selectAtLeastOne))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(selectedCount > 0 ? store.accentGradient : LinearGradient(colors: [Color.gray.opacity(0.5)], startPoint: .top, endPoint: .bottom))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .disabled(selectedCount == 0)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .background(CandleTheme.cardBackground)
        }
    }
    
    private func toggleSelectAll() {
        let allSelected = selectedCount == availableCount
        for i in 0..<importer.contactsWithBirthdays.count {
            if !importer.contactsWithBirthdays[i].isAlreadyImported {
                importer.contactsWithBirthdays[i].isSelected = !allSelected
            }
        }
    }
}
