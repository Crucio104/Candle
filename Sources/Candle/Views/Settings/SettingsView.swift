import SwiftUI
import UserNotifications
import UniformTypeIdentifiers

public struct SettingsView: View {
    @ObservedObject var store: BirthdayStore
    @StateObject private var notifications = NotificationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTime: Date = Date()
    @State private var defaultSameDay: Bool = true
    @State private var defaultAdvance: Bool = true
    @State private var defaultAdvanceDays: Int = 3
    @State private var selectedLanguage: AppLanguage = .english
    @State private var selectedAccentColor: AppAccentColor = .candleAmber
    @State private var showTestSentToast: Bool = false
    
    // Apple Calendar & Widget
    @State private var showingCalendarAlert: Bool = false
    @State private var calendarAlertMessage: String = ""
    @State private var showingWidgetPreviewSheet: Bool = false
    
    // Backup & Restore
    @State private var showingFileImporter = false
    @State private var showingBackupAlert = false
    @State private var backupAlertTitle = ""
    @State private var backupAlertMessage = ""
    
    // Contact Sync settings state
    @State private var syncContactName: Bool = false
    @State private var syncContactPhoto: Bool = false
    @State private var syncContactBirthday: Bool = true
    @State private var showContactSyncAlert: Bool = false
    @State private var contactSyncAlertMessage: String = ""
    
    private let advanceOptions = [1, 2, 3, 5, 7, 14]
    
    public init(store: BirthdayStore) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                // Language selection section (6 most spoken languages)
                Section(store.tr(.languageSection)) {
                    Picker(store.tr(.languageLabel), selection: $selectedLanguage) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedLanguage) { _, newLang in
                        var updated = store.settings
                        updated.language = newLang
                        store.updateSettings(updated)
                    }
                }
                
                // Accent color & Theme section
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(AppAccentColor.allCases) { colorOpt in
                                VStack(spacing: 6) {
                                    ZStack {
                                        Circle()
                                            .fill(colorOpt.gradient)
                                            .frame(width: 44, height: 44)
                                            .shadow(color: colorOpt.primary.opacity(0.3), radius: 4, x: 0, y: 2)
                                        
                                        if selectedAccentColor == colorOpt {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(.white)
                                            
                                            Circle()
                                                .stroke(Color.primary, lineWidth: 2.5)
                                                .frame(width: 52, height: 52)
                                        }
                                    }
                                    
                                    Text(colorOpt.localizedName(for: store.currentLanguage))
                                        .font(.system(size: 10, weight: selectedAccentColor == colorOpt ? .bold : .medium))
                                        .foregroundColor(selectedAccentColor == colorOpt ? .primary : .secondary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                .frame(width: 76)
                                .onTapGesture {
                                    selectedAccentColor = colorOpt
                                    var updated = store.settings
                                    updated.accentColor = colorOpt
                                    store.updateSettings(updated)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                } header: {
                    Text(store.tr(.accentColorSection))
                } footer: {
                    Text(store.tr(.accentColorFooter))
                }
                
                // User Guide & Instructions section
                Section {
                    NavigationLink {
                        UserGuideView(store: store)
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(store.accentPrimary.opacity(0.15))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "book.pages.fill")
                                    .foregroundColor(store.accentPrimary)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(store.tr(.guideSectionTitle))
                                    .font(.system(size: 15, weight: .semibold))
                                Text(store.tr(.guideSectionSubtitle))
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.vertical, 3)
                    }
                }
                
                // Category order & custom categories section
                Section {
                    NavigationLink {
                        CategoryOrderView(store: store)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.up.arrow.down")
                                .foregroundColor(store.accentPrimary)
                                .font(.system(size: 16, weight: .semibold))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(store.tr(.reorderCategoriesTitle))
                                    .font(.system(size: 15, weight: .medium))
                                Text(store.tr(.reorderCategoriesSubtitle))
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
                
                // iOS Notification status section
                Section(store.tr(.notificationStatusSection)) {
                    HStack {
                        Image(systemName: notifications.isAuthorized ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                            .foregroundColor(notifications.isAuthorized ? .green : .orange)
                            .font(.system(size: 22))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(notifications.isAuthorized ? store.tr(.notificationsActive) : store.tr(.notificationsInactive))
                                .font(.system(size: 16, weight: .semibold))
                            Text(notifications.isAuthorized ? store.tr(.notificationsActiveDesc) : store.tr(.notificationsInactiveDesc))
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    if notifications.authorizationStatus == .denied {
                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Text(store.tr(.openIOSSettingsBtn))
                                Spacer()
                                Image(systemName: "arrow.up.forward.app")
                            }
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    } else if !notifications.isAuthorized {
                        Button(store.tr(.requestPermissionBtn)) {
                            Task {
                                _ = await notifications.requestAuthorization()
                            }
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(store.accentPrimary)
                    } else {
                        Button {
                            Task {
                                await notifications.sendTestNotification(delay: 1.5, lang: store.currentLanguage)
                                showTestSentToast = true
                            }
                        } label: {
                            HStack {
                                Text(store.tr(.sendTestNotificationBtn))
                                Spacer()
                                Image(systemName: "paperplane.fill")
                            }
                        }
                        .foregroundColor(store.accentPrimary)
                    }
                }
                
                // Notification time & Defaults section
                Section(store.tr(.notificationTimeSection)) {
                    DatePicker(store.tr(.notificationTimeLabel), selection: $selectedTime, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(.compact)
                    
                    Text(store.tr(.notificationTimeDesc))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(store.tr(.newBirthdaysDefaultsSection)) {
                    Toggle(store.tr(.notifySameDay), isOn: $defaultSameDay)
                        .tint(store.accentPrimary)
                    
                    Toggle(store.tr(.notifyInAdvance), isOn: $defaultAdvance)
                        .tint(store.accentSecondary)
                    
                    if defaultAdvance {
                        Picker(store.tr(.defaultAdvanceTime), selection: $defaultAdvanceDays) {
                            ForEach(advanceOptions, id: \.self) { days in
                                Text(store.tr(.daysAdvanceOption(days))).tag(days)
                            }
                        }
                    }
                }
                
                // Apple Calendar sync section
                Section(store.tr(.calendarSection)) {
                    Button {
                        Task {
                            do {
                                let synced = try await CalendarSyncManager.shared.syncBirthdays(store.people)
                                calendarAlertMessage = store.tr(.calendarSyncSuccess(synced))
                                showingCalendarAlert = true
                            } catch {
                                calendarAlertMessage = error.localizedDescription
                                showingCalendarAlert = true
                            }
                        }
                    } label: {
                        HStack {
                            Label(store.tr(.syncCalendarBtn), systemImage: "calendar.badge.plus")
                            Spacer()
                            if CalendarSyncManager.shared.isSyncing {
                                ProgressView()
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .foregroundColor(store.accentPrimary)
                }
                
                // Widget & StandBy section
                Section(store.tr(.widgetSection)) {
                    Button {
                        showingWidgetPreviewSheet = true
                    } label: {
                        HStack {
                            Label(store.tr(.widgetPreviewTitle), systemImage: "square.dashed.inset.filled")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(store.accentPrimary)
                }
                
                // Automatic iCloud Sync section
                Section {
                    Toggle(
                        store.tr(.iCloudEnabled),
                        isOn: Binding(
                            get: { store.settings.iCloudSyncEnabled },
                            set: { enabled in
                                var updated = store.settings
                                updated.iCloudSyncEnabled = enabled
                                store.updateSettings(updated)
                                if enabled {
                                    store.syncWithICloud(manual: true)
                                }
                            }
                        )
                    )
                    .tint(store.accentPrimary)
                    
                    if store.settings.iCloudSyncEnabled {
                        HStack {
                            Label(
                                store.isSyncingICloud ? store.tr(.iCloudStatusSyncing) : store.tr(.iCloudStatusSynced),
                                systemImage: store.isSyncingICloud ? "arrow.triangle.2.circlepath" : "icloud.fill"
                            )
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(store.isSyncingICloud ? store.accentPrimary : .green)
                            
                            Spacer()
                            
                            Button {
                                store.syncWithICloud(manual: true)
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text(store.tr(.iCloudSyncNowBtn))
                                }
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(store.accentPrimary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(store.accentPrimary.opacity(0.12))
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            .disabled(store.isSyncingICloud)
                        }
                    }
                } header: {
                    Text(store.tr(.iCloudSection))
                } footer: {
                    Text(store.tr(.iCloudFooter))
                }
                
                // Phone Contacts synchronization section
                Section {
                    Toggle(
                        store.tr(.syncContactBirthday),
                        isOn: Binding(
                            get: { syncContactBirthday },
                            set: { val in
                                syncContactBirthday = val
                                var updated = store.settings
                                updated.syncContactBirthday = val
                                store.updateSettings(updated)
                                if val {
                                    Task {
                                        _ = await ContactsImporter.shared.syncAllPeopleToContacts(
                                            people: store.people,
                                            syncName: syncContactName,
                                            syncPhoto: syncContactPhoto,
                                            syncBirthday: true
                                        )
                                    }
                                }
                            }
                        )
                    )
                    .tint(store.accentPrimary)
                    
                    Toggle(
                        store.tr(.syncContactName),
                        isOn: Binding(
                            get: { syncContactName },
                            set: { val in
                                syncContactName = val
                                var updated = store.settings
                                updated.syncContactName = val
                                store.updateSettings(updated)
                                if val {
                                    Task {
                                        _ = await ContactsImporter.shared.syncAllPeopleToContacts(
                                            people: store.people,
                                            syncName: true,
                                            syncPhoto: syncContactPhoto,
                                            syncBirthday: syncContactBirthday
                                        )
                                    }
                                }
                            }
                        )
                    )
                    .tint(store.accentPrimary)
                    
                    Toggle(
                        store.tr(.syncContactPhoto),
                        isOn: Binding(
                            get: { syncContactPhoto },
                            set: { val in
                                syncContactPhoto = val
                                var updated = store.settings
                                updated.syncContactPhoto = val
                                store.updateSettings(updated)
                                if val {
                                    Task {
                                        _ = await ContactsImporter.shared.syncAllPeopleToContacts(
                                            people: store.people,
                                            syncName: syncContactName,
                                            syncPhoto: true,
                                            syncBirthday: syncContactBirthday
                                        )
                                    }
                                }
                            }
                        )
                    )
                    .tint(store.accentPrimary)
                    
                    Button {
                        Task {
                            let count = await ContactsImporter.shared.syncAllPeopleToContacts(
                                people: store.people,
                                syncName: syncContactName,
                                syncPhoto: syncContactPhoto,
                                syncBirthday: syncContactBirthday
                            )
                            contactSyncAlertMessage = store.tr(.contactSyncSuccessMsg(count))
                            showContactSyncAlert = true
                        }
                    } label: {
                        HStack {
                            Label(
                                store.tr(.contactSyncNowBtn),
                                systemImage: "arrow.triangle.2.circlepath"
                            )
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(store.accentPrimary)
                } header: {
                    Text(store.tr(.contactSyncSection))
                } footer: {
                    Text(store.tr(.contactSyncFooter))
                }
                
                // Backup & Export Files section (.json, .csv, .ics)
                Section(store.tr(.backupSection)) {
                    // 1. Full JSON Backup
                    if let jsonURL = store.createBackupFileURL() {
                        ShareLink(
                            item: jsonURL,
                            preview: SharePreview("Backup Candle (JSON)", image: Image(systemName: "archivebox.fill"))
                        ) {
                            HStack {
                                Label(store.tr(.exportBackupBtn), systemImage: "arrow.up.doc.fill")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .foregroundColor(store.accentPrimary)
                    }
                    
                    // 2. CSV Spreadsheet (Excel / Numbers)
                    if let csvURL = store.createCSVBackupFileURL() {
                        ShareLink(
                            item: csvURL,
                            preview: SharePreview("Compleanni Candle (CSV)", image: Image(systemName: "tablecells.fill"))
                        ) {
                            HStack {
                                Label(store.tr(.exportCSVBtn), systemImage: "tablecells")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .foregroundColor(store.accentPrimary)
                    }
                    
                    // 3. iCalendar .ics file (Apple Calendar, Google, Outlook)
                    if let icsURL = store.createICSBackupFileURL() {
                        ShareLink(
                            item: icsURL,
                            preview: SharePreview("Calendario Candle (.ics)", image: Image(systemName: "calendar.badge.clock"))
                        ) {
                            HStack {
                                Label(store.tr(.exportICSBtn), systemImage: "calendar.badge.clock")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .foregroundColor(store.accentPrimary)
                    }
                    
                    // 4. Universal File Import (.json, .csv, .ics)
                    Button {
                        showingFileImporter = true
                    } label: {
                        HStack {
                            Label(store.tr(.importAnyFileBtn), systemImage: "square.and.arrow.down.fill")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(store.accentPrimary)
                    
                    Text(store.tr(.backupFooter))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Privacy and App Info section
                Section(store.tr(.privacySection)) {
                    HStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 24))
                            .foregroundColor(store.accentPrimary)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(store.tr(.privacyTitle))
                                .font(.system(size: 15, weight: .semibold))
                            Text(store.tr(.privacyDesc))
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section(store.tr(.aboutSection)) {
                    HStack {
                        Text(store.tr(.versionLabel))
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text(store.tr(.savedBirthdaysCount))
                        Spacer()
                        Text("\(store.people.count)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(store.tr(.settingsTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(store.tr(.done)) {
                        saveAndDismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(store.accentPrimary)
                }
            }
            .onAppear {
                loadValues()
                notifications.checkStatus()
            }
            .fileImporter(
                isPresented: $showingFileImporter,
                allowedContentTypes: [.json, .commaSeparatedText, UTType(filenameExtension: "ics") ?? .text],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let fileURL = urls.first else { return }
                    do {
                        let outcome = try store.importFromFile(url: fileURL, merge: true)
                        backupAlertTitle = store.tr(.importCompletedTitle)
                        backupAlertMessage = store.tr(.importSuccessMsg(outcome.count, outcome.format))
                        showingBackupAlert = true
                    } catch {
                        backupAlertTitle = store.tr(.importErrorTitle)
                        backupAlertMessage = error.localizedDescription
                        showingBackupAlert = true
                    }
                case .failure(let error):
                    backupAlertTitle = store.tr(.errorTitle)
                    backupAlertMessage = error.localizedDescription
                    showingBackupAlert = true
                }
            }
            .alert(backupAlertTitle, isPresented: $showingBackupAlert) {
                Button(store.tr(.ok), role: .cancel) {}
            } message: {
                Text(backupAlertMessage)
            }
            .alert(store.tr(.testNotificationSentTitle), isPresented: $showTestSentToast) {
                Button(store.tr(.ok), role: .cancel) {}
            } message: {
                Text(store.tr(.testNotificationSentMsg))
            }
            .sheet(isPresented: $showingWidgetPreviewSheet) {
                WidgetPreviewView(store: store)
            }
            .alert(store.tr(.calendarSection), isPresented: $showingCalendarAlert) {
                Button(store.tr(.ok), role: .cancel) {}
            } message: {
                Text(calendarAlertMessage)
            }
            .alert(store.tr(.phoneContactsAlertTitle), isPresented: $showContactSyncAlert) {
                Button(store.tr(.ok), role: .cancel) {}
            } message: {
                Text(contactSyncAlertMessage)
            }
        }
    }
    
    private func loadValues() {
        var comp = DateComponents()
        comp.hour = store.settings.notificationHour
        comp.minute = store.settings.notificationMinute
        self.selectedTime = Calendar.current.date(from: comp) ?? Date()
        self.defaultSameDay = store.settings.defaultSameDayEnabled
        self.defaultAdvance = store.settings.defaultAdvanceEnabled
        self.defaultAdvanceDays = store.settings.defaultAdvanceDays
        self.selectedLanguage = store.settings.language
        self.selectedAccentColor = store.settings.accentColor
        self.syncContactName = store.settings.syncContactName
        self.syncContactPhoto = store.settings.syncContactPhoto
        self.syncContactBirthday = store.settings.syncContactBirthday
    }
    
    private func saveAndDismiss() {
        let cal = Calendar.current
        let hour = cal.component(.hour, from: selectedTime)
        let minute = cal.component(.minute, from: selectedTime)
        
        var newSettings = store.settings
        newSettings.notificationHour = hour
        newSettings.notificationMinute = minute
        newSettings.defaultSameDayEnabled = defaultSameDay
        newSettings.defaultAdvanceEnabled = defaultAdvance
        newSettings.defaultAdvanceDays = defaultAdvanceDays
        newSettings.appearance = store.settings.appearance
        newSettings.language = selectedLanguage
        newSettings.accentColor = selectedAccentColor
        newSettings.syncContactName = syncContactName
        newSettings.syncContactPhoto = syncContactPhoto
        newSettings.syncContactBirthday = syncContactBirthday
        
        store.updateSettings(newSettings)
        dismiss()
    }
}
