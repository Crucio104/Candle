import SwiftUI
import UIKit
import Contacts

public struct AddEditBirthdayView: View {
    @ObservedObject var store: BirthdayStore
    let personToEdit: BirthdayPerson?
    let preselectedDate: Date?
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var knowsYear: Bool = true
    @State private var selectedDate: Date = Date()
    @State private var selectedDay: Int = 1
    @State private var selectedMonth: Int = 1
    @State private var gifts: [GiftItem] = []
    @State private var notifyOnSameDay: Bool = true
    @State private var notifyInAdvance: Bool = true
    @State private var advanceDays: Int = 3
    @State private var selectedColorIndex: Int = 0
    @State private var selectedCategory: PersonCategory = .friends
    @State private var selectedCustomCategory: String? = nil
    @State private var showingAddCategoryAlert: Bool = false
    @State private var newCategoryName: String = ""
    @State private var selectedEventType: EventType = .birthday
    @State private var selectedRecurrence: EventRecurrence = .yearly
    @State private var isPrivate: Bool = false
    @State private var celebrationLocation: String = ""
    
    // Avatar photo with circular crop
    @State private var showingImagePicker: Bool = false
    @State private var pickedUIImage: UIImage? = nil
    @State private var avatarImageData: Data? = nil
    @State private var showingPhotoSourceDialog: Bool = false
    @State private var showingCameraFullScreen: Bool = false
    @State private var isLocating: Bool = false
    @State private var locationErrorMessage: String? = nil
    
    // Link with Apple Contact
    @State private var showingContactPicker: Bool = false
    @State private var linkedContactId: String? = nil
    @State private var linkedContactName: String? = nil
    
    private let advanceOptions = [1, 2, 3, 5, 7, 14]
    
    public init(store: BirthdayStore, personToEdit: BirthdayPerson? = nil, preselectedDate: Date? = nil) {
        self.store = store
        self.personToEdit = personToEdit
        self.preselectedDate = preselectedDate
        
        if let person = personToEdit {
            _name = State(initialValue: person.name)
            _selectedCategory = State(initialValue: person.category)
            _selectedCustomCategory = State(initialValue: person.customCategory)
            _selectedEventType = State(initialValue: person.eventType)
            _selectedRecurrence = State(initialValue: person.recurrence)
            _selectedColorIndex = State(initialValue: person.colorIndex)
            _avatarImageData = State(initialValue: person.avatarImageData)
            _isPrivate = State(initialValue: person.isPrivate)
            _celebrationLocation = State(initialValue: person.celebrationLocation ?? "")
            _gifts = State(initialValue: person.gifts)
            _notifyOnSameDay = State(initialValue: person.notifyOnSameDay)
            _notifyInAdvance = State(initialValue: person.notifyInAdvance)
            _advanceDays = State(initialValue: person.advanceDays)
            
            if person.eventType == .birthday, let contactId = person.linkedContactId {
                _linkedContactId = State(initialValue: contactId)
                _linkedContactName = State(initialValue: person.name)
            } else {
                _linkedContactId = State(initialValue: nil)
                _linkedContactName = State(initialValue: nil)
            }
            
            let hasYear = person.birthYear != nil
            _knowsYear = State(initialValue: hasYear)
            _selectedDay = State(initialValue: person.birthDay)
            _selectedMonth = State(initialValue: person.birthMonth)
            
            var comp = DateComponents()
            comp.year = person.birthYear ?? Calendar.current.component(.year, from: Date())
            comp.month = person.birthMonth
            comp.day = person.birthDay
            let initialDate = Calendar.current.date(from: comp) ?? Date()
            _selectedDate = State(initialValue: initialDate)
        } else {
            _name = State(initialValue: "")
            _selectedCategory = State(initialValue: .friends)
            _selectedCustomCategory = State(initialValue: nil)
            _selectedEventType = State(initialValue: .birthday)
            _selectedRecurrence = State(initialValue: .yearly)
            _selectedColorIndex = State(initialValue: Int.random(in: 0..<CandleTheme.avatarColorPairs.count))
            _avatarImageData = State(initialValue: nil)
            _isPrivate = State(initialValue: false)
            _celebrationLocation = State(initialValue: "")
            _gifts = State(initialValue: [])
            _notifyOnSameDay = State(initialValue: store.settings.defaultSameDayEnabled)
            _notifyInAdvance = State(initialValue: store.settings.defaultAdvanceEnabled)
            _advanceDays = State(initialValue: store.settings.defaultAdvanceDays)
            _linkedContactId = State(initialValue: nil)
            _linkedContactName = State(initialValue: nil)
            _knowsYear = State(initialValue: true)
            
            let baseDate = preselectedDate ?? Date()
            _selectedDate = State(initialValue: baseDate)
            _selectedMonth = State(initialValue: Calendar.current.component(.month, from: baseDate))
            _selectedDay = State(initialValue: Calendar.current.component(.day, from: baseDate))
        }
    }
    
    private var isEditing: Bool {
        personToEdit != nil
    }
    
    private var initials: String {
        let parts = name.split(separator: " ").prefix(2)
        let inits = parts.compactMap { $0.first }.map { String($0).uppercased() }
        return inits.isEmpty ? "" : inits.joined()
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                // Photo & Avatar section
                Section {
                    VStack(spacing: 14) {
                        AvatarCircleView(
                            avatarData: avatarImageData,
                            initials: initials,
                            colorIndex: selectedColorIndex,
                            size: 96
                        )
                        .shadow(
                            color: CandleTheme.avatarPrimaryColor(for: selectedColorIndex).opacity(0.35),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                        
                        HStack(spacing: 12) {
                            Button {
                                CandleTheme.hapticSelection()
                                showingPhotoSourceDialog = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "photo.badge.plus")
                                    Text(avatarImageData == nil ? store.tr(.choosePhoto) : store.tr(.changePhoto))
                                }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(store.accentPrimary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(store.accentPrimary.opacity(0.12))
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            
                            if avatarImageData != nil {
                                Button(role: .destructive) {
                                    avatarImageData = nil
                                    pickedUIImage = nil
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "trash")
                                        Text(store.tr(.removePhoto))
                                    }
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.red.opacity(0.1))
                                    .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        if selectedEventType == .birthday {
                            // Link contact from iOS Address Book (Birthdays only)
                            HStack(spacing: 8) {
                                Button {
                                    showingContactPicker = true
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: linkedContactId != nil ? "link.circle.fill" : "person.crop.circle.badge.plus")
                                        Text(linkedContactId != nil ? (linkedContactName.map { store.tr(.linkedContactBadge($0)) } ?? store.tr(.linkContactBtn)) : store.tr(.linkContactBtn))
                                    }
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(linkedContactId != nil ? .green : store.accentSecondary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background((linkedContactId != nil ? Color.green : store.accentSecondary).opacity(0.12))
                                    .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                                
                                if linkedContactId != nil {
                                    Button {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                            linkedContactId = nil
                                            linkedContactName = nil
                                        }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.secondary)
                                    }
                                    .accessibilityLabel(store.tr(.unlinkContactBtn))
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                } header: {
                    Text(store.tr(.avatarSection))
                } footer: {
                    Text(store.tr(.avatarFooter))
                        .font(.caption2)
                }
                
                // Personal info section
                Section(store.tr(.personDetails)) {
                    TextField(store.tr(.fullNamePlaceholder), text: $name)
                        .textInputAutocapitalization(.words)
                    
                    Toggle(store.knowYearToggleLabel(for: selectedEventType), isOn: $knowsYear)
                        .tint(store.accentPrimary)
                    
                    if knowsYear {
                        if selectedEventType == .special {
                            DatePicker(
                                store.eventDateLabel(for: selectedEventType),
                                selection: $selectedDate,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.compact)
                        } else {
                            DatePicker(
                                store.eventDateLabel(for: selectedEventType),
                                selection: $selectedDate,
                                in: ...Date(),
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.compact)
                        }
                    } else {
                        Picker(store.tr(.month), selection: $selectedMonth) {
                            ForEach(1...12, id: \.self) { month in
                                Text(monthName(for: month)).tag(month)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(store.accentPrimary)
                        .onChange(of: selectedMonth) { _, newMonth in
                            let maxDays = maxDaysInMonth(newMonth)
                            if selectedDay > maxDays {
                                selectedDay = maxDays
                            }
                        }
                        
                        Picker(store.tr(.day), selection: $selectedDay) {
                            ForEach(1...maxDaysInMonth(selectedMonth), id: \.self) { day in
                                Text("\(day)").tag(day)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(store.accentPrimary)
                    }
                }
                
                // Recurrence type section (Birthday, Anniversary, Name Day, Special)
                Section(store.tr(.eventTypeSection)) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(EventType.allCases) { type in
                                let isSelected = selectedEventType == type
                                Button {
                                    CandleTheme.hapticSelection()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedEventType = type
                                        if type != .birthday {
                                            linkedContactId = nil
                                            linkedContactName = nil
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 5) {
                                        Text(type.emoji)
                                        Text(type.localizedName(for: store.currentLanguage))
                                    }
                                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                                    .foregroundColor(isSelected ? .white : .primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(isSelected ? store.accentPrimary : Color.primary.opacity(0.06))
                                    .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // Recurrence options
                    if selectedEventType == .special {
                        Toggle(
                            store.tr(.oneShotSpecialToggle),
                            isOn: Binding(
                                get: { selectedRecurrence == .oneTime },
                                set: { isOneShot in
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedRecurrence = isOneShot ? .oneTime : .yearly
                                    }
                                }
                            )
                        )
                        .tint(store.accentPrimary)
                        
                        Text(store.tr(.oneShotSpecialFooter))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if selectedRecurrence != .oneTime {
                            Toggle(
                                store.tr(.rememberMonthlySpecial),
                                isOn: Binding(
                                    get: { selectedRecurrence == .monthly },
                                    set: { selectedRecurrence = $0 ? .monthly : .yearly }
                                )
                            )
                            .tint(store.accentPrimary)
                        }
                    } else if selectedEventType == .anniversary {
                        Toggle(
                            store.tr(.rememberMonthlyAnniversary),
                            isOn: Binding(
                                get: { selectedRecurrence == .monthly },
                                set: { selectedRecurrence = $0 ? .monthly : .yearly }
                            )
                        )
                        .tint(store.accentPrimary)
                    }
                }
                
                // Circle & Category section (Unified Standard & Custom Categories)
                Section(store.tr(.categorySection)) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(store.orderedCategories) { item in
                                let isSelected = item.isCustom
                                    ? (selectedCustomCategory?.caseInsensitiveCompare(item.id) == .orderedSame)
                                    : (selectedCustomCategory == nil && selectedCategory.rawValue == item.id)
                                
                                Button {
                                    CandleTheme.hapticSelection()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        if item.isCustom {
                                            selectedCustomCategory = item.id
                                            selectedCategory = .other
                                        } else {
                                            selectedCustomCategory = nil
                                            selectedCategory = PersonCategory(rawValue: item.id) ?? .friends
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 5) {
                                        Text(item.emoji)
                                        Text(item.name)
                                    }
                                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                                    .foregroundColor(isSelected ? .white : .primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(isSelected ? store.accentPrimary : Color.primary.opacity(0.06))
                                    .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                            
                            // Add custom category button placed at the end to the right
                            Button {
                                CandleTheme.hapticSelection()
                                newCategoryName = ""
                                showingAddCategoryAlert = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 12, weight: .bold))
                                }
                                .foregroundColor(store.accentPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(store.accentPrimary.opacity(0.12))
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Celebration Venue & Location section (Apple Maps)
                Section(header: Text(store.tr(.celebrationLocationHeader)), footer: Text(store.tr(.celebrationLocationFooter))) {
                    HStack(spacing: 8) {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(store.accentPrimary)
                        
                        TextField(store.tr(.celebrationLocationPlaceholder), text: $celebrationLocation)
                            .textInputAutocapitalization(.words)
                        
                        if isLocating {
                            ProgressView()
                                .padding(.horizontal, 4)
                        } else {
                            Button {
                                fetchCurrentLocation()
                            } label: {
                                Image(systemName: "location.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(store.accentPrimary)
                            }
                            .accessibilityLabel(store.tr(.useCurrentLocationBtn))
                            .buttonStyle(.plain)
                        }
                        
                        if !celebrationLocation.isEmpty {
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    celebrationLocation = ""
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                // Avatar accent hue section
                Section(store.tr(.avatarHue)) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0..<CandleTheme.avatarColorPairs.count, id: \.self) { index in
                                Button {
                                    CandleTheme.hapticSelection()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                        selectedColorIndex = index
                                    }
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(CandleTheme.avatarGradient(for: index))
                                            .frame(width: 36, height: 36)
                                        
                                        if selectedColorIndex == index {
                                            Circle()
                                                .stroke(store.accentPrimary, lineWidth: 2.5)
                                                .frame(width: 44, height: 44)
                                        }
                                    }
                                    .frame(width: 44, height: 44)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 2)
                        .padding(.vertical, 4)
                    }
                }
                
                // Reminders & Notifications section
                Section(store.tr(.remindersSection)) {
                    Toggle(store.tr(.notifySameDay), isOn: $notifyOnSameDay)
                        .tint(store.accentPrimary)
                    
                    Toggle(store.tr(.notifyInAdvance), isOn: $notifyInAdvance)
                        .tint(store.accentSecondary)
                    
                    if notifyInAdvance {
                        Picker(store.tr(.howFarInAdvance), selection: $advanceDays) {
                            ForEach(advanceOptions, id: \.self) { days in
                                Text(store.tr(.daysAdvanceOption(days))).tag(days)
                            }
                        }
                    }
                }
                
                // Privacy & Confidentiality section
                Section(header: Text(store.tr(.privacySectionHeader)), footer: Text(store.tr(.privateEventFooter))) {
                    Toggle(store.tr(.privateEventLabel), isOn: $isPrivate)
                        .tint(store.accentPrimary)
                }
                
                // Gift Tracker & Wishlist section
                Section {
                    GiftTrackerSectionView(store: store, gifts: $gifts)
                }
            }
            .navigationTitle(isEditing ? store.tr(.editBirthday) : store.tr(.newBirthday))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(store.tr(.cancel)) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(store.tr(.save)) {
                        save()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .fontWeight(.bold)
                    .foregroundColor(store.accentPrimary)
                }
            }
            .onAppear {
                initializeValues()
            }
            .fullScreenCover(isPresented: $showingCameraFullScreen) {
                ImagePicker(selectedImage: $pickedUIImage, sourceType: .camera, allowsEditing: true)
                    .statusBarHidden(true)
                    .ignoresSafeArea()
                    .background(Color.black.ignoresSafeArea())
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $pickedUIImage, sourceType: .photoLibrary, allowsEditing: true)
            }
            .confirmationDialog(store.tr(.choosePhotoSource), isPresented: $showingPhotoSourceDialog, titleVisibility: .visible) {
                Button {
                    showingCameraFullScreen = true
                } label: {
                    Label(store.tr(.takePhoto), systemImage: "camera.fill")
                }
                Button {
                    showingImagePicker = true
                } label: {
                    Label(store.tr(.chooseFromLibrary), systemImage: "photo.on.rectangle")
                }
                Button(store.tr(.cancel), role: .cancel) {}
            }
            .alert(
                store.tr(.celebrationLocation),
                isPresented: Binding(
                    get: { locationErrorMessage != nil },
                    set: { if !$0 { locationErrorMessage = nil } }
                )
            ) {
                Button(store.tr(.done), role: .cancel) {}
            } message: {
                Text(locationErrorMessage ?? "")
            }
            .sheet(isPresented: $showingContactPicker) {
                ContactPickerSheet { contact in
                    let fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? [contact.givenName, contact.familyName].filter { !$0.isEmpty }.joined(separator: " ")
                    if !fullName.isEmpty {
                        self.name = fullName
                        self.linkedContactName = fullName
                    }
                    if let imgData = contact.imageData ?? contact.thumbnailImageData {
                        self.avatarImageData = imgData
                    }
                    if let bday = contact.birthday, let m = bday.month, let d = bday.day {
                        self.selectedDay = d
                        self.selectedMonth = m
                        if let y = bday.year {
                            self.knowsYear = true
                            var comp = DateComponents()
                            comp.year = y
                            comp.month = m
                            comp.day = d
                            if let date = Calendar.current.date(from: comp) {
                                self.selectedDate = date
                            }
                        } else {
                            self.knowsYear = false
                        }
                    }
                    self.linkedContactId = contact.identifier
                }
            }
            .onChange(of: pickedUIImage) { _, newImage in
                guard let newImage = newImage else { return }
                let cropped = newImage.centerSquareCroppedAndResized(maxDimension: 400)
                if let jpeg = cropped.jpegData(compressionQuality: 0.8) {
                    self.avatarImageData = jpeg
                }
            }
            .onChange(of: knowsYear) { _, knows in
                let cal = Calendar.current
                if !knows {
                    selectedMonth = cal.component(.month, from: selectedDate)
                    selectedDay = min(cal.component(.day, from: selectedDate), maxDaysInMonth(selectedMonth))
                } else {
                    var comp = DateComponents()
                    comp.year = cal.component(.year, from: selectedDate)
                    comp.month = selectedMonth
                    comp.day = min(selectedDay, maxDaysInMonth(selectedMonth))
                    if let d = cal.date(from: comp) {
                        selectedDate = d
                    }
                }
            }
            .onChange(of: selectedEventType) { _, newType in
                if newType != .birthday {
                    linkedContactId = nil
                    linkedContactName = nil
                }
                if newType != .special && selectedRecurrence == .oneTime {
                    selectedRecurrence = .yearly
                }
            }
            .alert(store.tr(.addCategoryBtn), isPresented: $showingAddCategoryAlert) {
                TextField(store.tr(.addCategoryPlaceholder), text: $newCategoryName)
                Button(store.tr(.addTagBtn)) {
                    let trimmed = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        store.addCustomCategory(trimmed)
                        selectedCustomCategory = trimmed
                        selectedCategory = .other
                        CandleTheme.hapticNotification(type: .success)
                    }
                }
                Button(store.tr(.cancel), role: .cancel) {}
            }
        }
    }
    
    private func initializeValues() {
        if let person = personToEdit {
            name = person.name
            selectedCategory = person.category
            selectedCustomCategory = person.customCategory
            selectedEventType = person.eventType
            selectedRecurrence = person.recurrence
            selectedColorIndex = person.colorIndex
            avatarImageData = person.avatarImageData
            gifts = person.gifts
            notifyOnSameDay = person.notifyOnSameDay
            notifyInAdvance = person.notifyInAdvance
            advanceDays = person.advanceDays
            
            if person.eventType == .birthday, let contactId = person.linkedContactId {
                linkedContactId = contactId
                linkedContactName = person.name
            } else {
                linkedContactId = nil
                linkedContactName = nil
            }
            
            isPrivate = person.isPrivate
            celebrationLocation = person.celebrationLocation ?? ""
            selectedDay = person.birthDay
            selectedMonth = person.birthMonth
            knowsYear = (person.birthYear != nil)
            
            var comp = DateComponents()
            comp.year = person.birthYear ?? Calendar.current.component(.year, from: Date())
            comp.month = person.birthMonth
            comp.day = person.birthDay
            if let d = Calendar.current.date(from: comp) {
                selectedDate = d
            }
        } else {
            notifyOnSameDay = store.settings.defaultSameDayEnabled
            notifyInAdvance = store.settings.defaultAdvanceEnabled
            advanceDays = store.settings.defaultAdvanceDays
            selectedColorIndex = Int.random(in: 0..<CandleTheme.avatarColorPairs.count)
            selectedCategory = .friends
            selectedCustomCategory = nil
            selectedEventType = .birthday
            selectedRecurrence = .yearly
            isPrivate = false
            celebrationLocation = ""
            avatarImageData = nil
            knowsYear = true
            
            let baseDate = preselectedDate ?? Date()
            selectedDate = baseDate
            selectedMonth = Calendar.current.component(.month, from: baseDate)
            selectedDay = Calendar.current.component(.day, from: baseDate)
        }
    }
    
    private func save() {
        let cal = Calendar.current
        let day: Int
        let month: Int
        let year: Int?
        
        if knowsYear {
            day = cal.component(.day, from: selectedDate)
            month = cal.component(.month, from: selectedDate)
            year = cal.component(.year, from: selectedDate)
        } else {
            month = max(1, min(12, selectedMonth))
            day = max(1, min(selectedDay, maxDaysInMonth(month)))
            year = nil
        }
        
        let recurrenceToSave: EventRecurrence
        if selectedEventType == .special {
            recurrenceToSave = selectedRecurrence
        } else if selectedEventType == .anniversary {
            recurrenceToSave = (selectedRecurrence == .monthly) ? .monthly : .yearly
        } else {
            recurrenceToSave = .yearly
        }
        
        let contactIdToSave = (selectedEventType == .birthday) ? linkedContactId : nil
        let trimmedLocation = celebrationLocation.trimmingCharacters(in: .whitespacesAndNewlines)
        let locationToSave = trimmedLocation.isEmpty ? nil : trimmedLocation
        
        if var existing = personToEdit {
            existing.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            existing.birthDay = day
            existing.birthMonth = month
            existing.birthYear = year
            existing.gifts = gifts
            existing.notifyOnSameDay = notifyOnSameDay
            existing.notifyInAdvance = notifyInAdvance
            existing.advanceDays = advanceDays
            existing.colorIndex = selectedColorIndex
            existing.avatarImageData = avatarImageData
            existing.linkedContactId = contactIdToSave
            existing.category = selectedCategory
            existing.customCategory = selectedCustomCategory
            existing.eventType = selectedEventType
            existing.recurrence = recurrenceToSave
            existing.isPrivate = isPrivate
            existing.celebrationLocation = locationToSave
            store.updatePerson(existing)
        } else {
            let newPerson = BirthdayPerson(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                birthDay: day,
                birthMonth: month,
                birthYear: year,
                notifyOnSameDay: notifyOnSameDay,
                notifyInAdvance: notifyInAdvance,
                advanceDays: advanceDays,
                colorIndex: selectedColorIndex,
                avatarImageData: avatarImageData,
                gifts: gifts,
                linkedContactId: contactIdToSave,
                category: selectedCategory,
                eventType: selectedEventType,
                recurrence: recurrenceToSave,
                isPrivate: isPrivate,
                celebrationLocation: locationToSave,
                customCategory: selectedCustomCategory
            )
            store.addPerson(newPerson)
        }
        
        // Synchronize birthday, name and photo to iOS contact only if it's a birthday
        if selectedEventType == .birthday {
            ContactsImporter.shared.syncContactToiOS(
                contactIdentifier: contactIdToSave,
                name: name,
                day: day,
                month: month,
                year: year,
                avatarImageData: avatarImageData,
                syncName: store.settings.syncContactName,
                syncPhoto: store.settings.syncContactPhoto,
                syncBirthday: store.settings.syncContactBirthday
            )
        }
        
        dismiss()
    }
    
    private func fetchCurrentLocation() {
        CandleTheme.hapticSelection()
        isLocating = true
        LocationHelper.shared.requestCurrentLocationName { result in
            isLocating = false
            switch result {
            case .success(let name):
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    celebrationLocation = name
                }
                CandleTheme.hapticNotification(type: .success)
            case .failure(let err):
                locationErrorMessage = err.localizedMessage(for: store.currentLanguage)
                CandleTheme.hapticNotification(type: .warning)
            }
        }
    }
    
    private func monthName(for month: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: store.currentLanguage.resolvedCode)
        return formatter.monthSymbols[max(0, min(11, month - 1))].capitalized
    }
    
    private func maxDaysInMonth(_ month: Int) -> Int {
        switch month {
        case 2:
            return 29
        case 4, 6, 9, 11:
            return 30
        default:
            return 31
        }
    }
}

// MARK: - UIImage Cropping & Normalization Helper

extension UIImage {
    func centerSquareCroppedAndResized(maxDimension: CGFloat = 400) -> UIImage {
        let image = self.normalizedOrientation()
        let side = min(image.size.width, image.size.height)
        let originX = (image.size.width - side) / 2.0
        let originY = (image.size.height - side) / 2.0
        let cropRect = CGRect(x: originX, y: originY, width: side, height: side)
        
        guard let cgCropped = image.cgImage?.cropping(to: cropRect) else { return self }
        let croppedImage = UIImage(cgImage: cgCropped, scale: 1.0, orientation: .up)
        
        let finalDimension = min(side, maxDimension)
        let targetSize = CGSize(width: finalDimension, height: finalDimension)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            croppedImage.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    private func normalizedOrientation() -> UIImage {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalized ?? self
    }
}
