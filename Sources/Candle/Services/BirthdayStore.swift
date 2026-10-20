import Foundation
import SwiftUI
import LocalAuthentication
#if canImport(WidgetKit)
import WidgetKit
#endif

@MainActor
public final class BirthdayStore: ObservableObject {
    public static let shared = BirthdayStore()
    
    @Published public var people: [BirthdayPerson] = []
    @Published public var settings: NotificationSettings = .standard
    @Published public var searchText: String = ""
    @Published public var selectedFilter: BirthdayFilter = .all
    @Published public var selectedCategoryFilter: String? = nil
    
    public enum BirthdayFilter: String, CaseIterable, Identifiable {
        case all = "all"
        case thisMonth = "thisMonth"
        case untilEndOfYear = "untilEndOfYear"
        
        public var id: String { rawValue }
        
        public func title(for lang: AppLanguage) -> String {
            switch self {
            case .all: return L10n.tr(.filterAll, lang: lang)
            case .thisMonth: return L10n.tr(.filterThisMonth, lang: lang)
            case .untilEndOfYear: return L10n.tr(.filterUntilEndOfYear, lang: lang)
            }
        }
    }
    
    // MARK: - Accent & Localization Helpers
    
    public var accentPrimary: Color {
        settings.accentColor.primary
    }
    
    public var accentSecondary: Color {
        settings.accentColor.secondary
    }
    
    public var accentGradient: LinearGradient {
        settings.accentColor.gradient
    }
    
    public var currentLanguage: AppLanguage {
        settings.language
    }
    
    public func tr(_ key: L10n.Key) -> String {
        L10n.tr(key, lang: settings.language)
    }
    
    public func knowYearToggleLabel(for eventType: EventType) -> String {
        tr(L10n.knowYearToggleKey(for: eventType))
    }
    
    public func eventDateLabel(for eventType: EventType) -> String {
        tr(L10n.eventDateLabelKey(for: eventType))
    }
    
    public func onEventDayLabel(for eventType: EventType, recurrence: EventRecurrence? = nil) -> String {
        tr(L10n.onEventDayKey(for: eventType, recurrence: recurrence))
    }
    
    public func onEventDayLabel(for person: BirthdayPerson) -> String {
        onEventDayLabel(for: person.eventType, recurrence: person.recurrence)
    }
    
    public func toggleAppearance(isCurrentlyDark: Bool) {
        var newSettings = settings
        newSettings.appearance = isCurrentlyDark ? .light : .dark
        updateSettings(newSettings)
    }
    
    @Published public var lastICloudSyncDate: Date? = nil
    @Published public var isSyncingICloud: Bool = false
    @Published public var isPrivacyUnlocked: Bool = false
    @Published public var arePrivateGiftsUnlocked: Bool = false
    
    public var hasPrivateEvents: Bool {
        people.contains { $0.isPrivate }
    }
    
    /// Authenticates with biometrics (Face ID / Touch ID) with native fallback to the iPhone device passcode.
    /// After the first failed biometric attempt, iOS displays the fallback button ("Inserisci codice" / "Enter Passcode")
    /// allowing the user to enter the iPhone passcode. The user can also cancel the prompt cleanly.
    public func authenticateBiometrics(reason: String? = nil, completion: @escaping @MainActor @Sendable (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        let localizedReason = reason ?? tr(.biometricsReasonText)
        
        // Setting localizedFallbackTitle ensures that after the first failed biometric attempt,
        // iOS displays the button to enter the device passcode.
        context.localizedFallbackTitle = tr(.usePasscodeFallback)
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: localizedReason) { [weak self] success, evalError in
                Task { @MainActor in
                    guard let self = self else { return }
                    if success {
                        CandleTheme.hapticNotification(type: .success)
                        completion(true)
                    } else if let laError = evalError as? LAError, laError.code == .userFallback {
                        // If the system returns userFallback when tapping the button, present the device passcode prompt directly
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                            self?.presentPasscodeFallback(reason: localizedReason, completion: completion)
                        }
                    } else {
                        // Check if the user actively cancelled the prompt (from Face ID or from the passcode screen)
                        let isCancelled: Bool
                        if let laError = evalError as? LAError {
                            isCancelled = (laError.code == .userCancel || laError.code == .appCancel)
                        } else if let nsError = evalError as NSError? {
                            isCancelled = (nsError.domain == LAErrorDomain && (nsError.code == LAError.userCancel.rawValue || nsError.code == LAError.appCancel.rawValue))
                        } else {
                            isCancelled = false
                        }
                        
                        if isCancelled {
                            CandleTheme.hapticSelection()
                        } else {
                            CandleTheme.hapticNotification(type: .error)
                        }
                        completion(false)
                    }
                }
            }
        } else {
            // Simulator or device without passcode/biometrics
            CandleTheme.hapticNotification(type: .success)
            completion(true)
        }
    }
    
    /// Secondary fallback explicitly requesting device passcode if user tapped the fallback button
    private func presentPasscodeFallback(reason: String, completion: @escaping @MainActor @Sendable (Bool) -> Void) {
        let passcodeContext = LAContext()
        passcodeContext.localizedFallbackTitle = ""
        var error: NSError?
        guard passcodeContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            completion(false)
            return
        }
        passcodeContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, evalError in
            Task { @MainActor in
                if success {
                    CandleTheme.hapticNotification(type: .success)
                    completion(true)
                } else {
                    let isCancelled: Bool
                    if let laError = evalError as? LAError {
                        isCancelled = (laError.code == .userCancel || laError.code == .appCancel)
                    } else if let nsError = evalError as NSError? {
                        isCancelled = (nsError.domain == LAErrorDomain && (nsError.code == LAError.userCancel.rawValue || nsError.code == LAError.appCancel.rawValue))
                    } else {
                        isCancelled = false
                    }
                    if isCancelled {
                        CandleTheme.hapticSelection()
                    } else {
                        CandleTheme.hapticNotification(type: .error)
                    }
                    completion(false)
                }
            }
        }
    }
    
    /// Unlocks private events by requesting biometric authentication (Face ID / Touch ID)
    public func unlockPrivacyWithBiometrics(completion: (@MainActor @Sendable (Bool) -> Void)? = nil) {
        authenticateBiometrics { [weak self] success in
            if success {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    self?.isPrivacyUnlocked = true
                }
            }
            completion?(success)
        }
    }
    
    /// Immediately locks private events view
    public func lockPrivacy() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            self.isPrivacyUnlocked = false
        }
        CandleTheme.hapticSelection()
    }
    
    /// If unlocked, locks immediately; if locked, requests Face ID / Touch ID
    public func togglePrivacyLock() {
        if isPrivacyUnlocked {
            lockPrivacy()
        } else {
            unlockPrivacyWithBiometrics()
        }
    }
    
    private let peopleFileName = "birthdays_v1.json"
    private let settingsFileName = "candle_settings.json"
    private let cloudPeopleKey = "candle_people_cloud_v1"
    private let cloudSettingsKey = "candle_settings_cloud_v1"
    private let cloudTimestampKey = "candle_cloud_timestamp_v1"
    
    public init() {
        loadSettings()
        loadPeople()
        setupICloudSync()
    }
    
    // MARK: - Computed Queries
    
    /// List sorted by remaining days (nearest first)
    public var sortedUpcomingPeople: [BirthdayPerson] {
        let reference = Date()
        let calendar = Calendar.current
        return people
            .filter { !$0.isOneShotExpired(relativeTo: reference, calendar: calendar) }
            .sorted {
                $0.daysRemaining(relativeTo: reference, calendar: calendar) <
                $1.daysRemaining(relativeTo: reference, calendar: calendar)
            }
    }
    
    /// Filtered list based on search text and active tab filter
    public var filteredPeople: [BirthdayPerson] {
        let reference = Date()
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: reference)
        
        var baseList = sortedUpcomingPeople
        
        // Filter by tab
        switch selectedFilter {
        case .all:
            break
        case .thisMonth:
            baseList = baseList.filter { $0.birthMonth == currentMonth }
        case .untilEndOfYear:
            let currentYear = calendar.component(.year, from: reference)
            baseList = baseList.filter { person in
                let nextDate = person.nextBirthdayDate(relativeTo: reference, calendar: calendar)
                return calendar.component(.year, from: nextDate) == currentYear
            }
        }
        
        // Filter by unified category
        if let catId = selectedCategoryFilter {
            baseList = baseList.filter { person in
                person.categoryId.caseInsensitiveCompare(catId) == .orderedSame
            }
        }
        
        // Search by name
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            baseList = baseList.filter { $0.name.lowercased().contains(query) }
        }
        
        return baseList
    }
    
    // MARK: - Unified & Custom Categories
    
    public struct CategoryDisplayItem: Identifiable, Equatable, Hashable {
        public let id: String
        public let name: String
        public let emoji: String
        public let isCustom: Bool
        
        public init(id: String, name: String, emoji: String, isCustom: Bool) {
            self.id = id
            self.name = name
            self.emoji = emoji
            self.isCustom = isCustom
        }
    }
    
    /// Returns categories in user-defined order
    public var orderedCategories: [CategoryDisplayItem] {
        var result: [CategoryDisplayItem] = []
        let order = settings.categoryOrder.isEmpty
            ? (PersonCategory.allCases.map(\.rawValue) + settings.customCategories)
            : settings.categoryOrder
        
        var added = Set<String>()
        
        for id in order {
            if let std = PersonCategory(rawValue: id) {
                result.append(CategoryDisplayItem(
                    id: id,
                    name: std.localizedName(for: currentLanguage),
                    emoji: std.emoji,
                    isCustom: false
                ))
                added.insert(id.lowercased())
            } else if settings.customCategories.contains(where: { $0.caseInsensitiveCompare(id) == .orderedSame }) {
                result.append(CategoryDisplayItem(
                    id: id,
                    name: id,
                    emoji: "🏷️",
                    isCustom: true
                ))
                added.insert(id.lowercased())
            }
        }
        
        // Fallback: any standard category not yet in order
        for std in PersonCategory.allCases {
            if !added.contains(std.rawValue.lowercased()) {
                result.append(CategoryDisplayItem(
                    id: std.rawValue,
                    name: std.localizedName(for: currentLanguage),
                    emoji: std.emoji,
                    isCustom: false
                ))
                added.insert(std.rawValue.lowercased())
            }
        }
        
        // Fallback: any custom category not yet in order
        for custom in settings.customCategories {
            if !added.contains(custom.lowercased()) {
                result.append(CategoryDisplayItem(
                    id: custom,
                    name: custom,
                    emoji: "🏷️",
                    isCustom: true
                ))
                added.insert(custom.lowercased())
            }
        }
        
        return result
    }
    
    /// Create and persist a new custom category
    public func addCustomCategory(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if !settings.customCategories.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            var updated = settings
            updated.customCategories.append(trimmed)
            if !updated.categoryOrder.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
                updated.categoryOrder.append(trimmed)
            }
            updateSettings(updated)
        }
    }
    
    /// Delete a custom category globally
    public func deleteCustomCategory(_ name: String) {
        var updated = settings
        updated.customCategories.removeAll(where: { $0.caseInsensitiveCompare(name) == .orderedSame })
        updated.categoryOrder.removeAll(where: { $0.caseInsensitiveCompare(name) == .orderedSame })
        updateSettings(updated)
        
        var modified = false
        for i in people.indices {
            if people[i].customCategory?.caseInsensitiveCompare(name) == .orderedSame {
                people[i].customCategory = nil
                people[i].category = .friends
                modified = true
            }
        }
        if modified {
            savePeople()
        }
        if selectedCategoryFilter?.caseInsensitiveCompare(name) == .orderedSame {
            selectedCategoryFilter = nil
        }
    }
    
    /// Move category position in user order
    public func reorderCategories(fromOffsets: IndexSet, toOffset: Int) {
        var order = orderedCategories.map(\.id)
        order.move(fromOffsets: fromOffsets, toOffset: toOffset)
        var updated = settings
        updated.categoryOrder = order
        updateSettings(updated)
    }
    
    /// Reset category ordering to standard defaults
    public func resetCategoryOrder() {
        var updated = settings
        updated.categoryOrder = PersonCategory.allCases.map(\.rawValue) + updated.customCategories
        updateSettings(updated)
    }
    
    /// The nearest upcoming birthday (Hero card)
    public var heroUpcomingPerson: BirthdayPerson? {
        sortedUpcomingPeople.first
    }
    
    // MARK: - Insights & Statistics
    
    /// The month with the most birthdays (e.g. May, 4)
    public var busiestMonth: (month: Int, count: Int, monthName: String)? {
        guard !people.isEmpty else { return nil }
        var counts: [Int: Int] = [:]
        for p in people {
            counts[p.birthMonth, default: 0] += 1
        }
        let currentMonth = Calendar.current.component(.month, from: Date())
        let ranked = (1...12).map { (month: $0, count: counts[$0] ?? 0) }
            .sorted { a, b in
                if a.count != b.count {
                    return a.count > b.count
                }
                if a.month == currentMonth { return true }
                if b.month == currentMonth { return false }
                return a.month < b.month
            }
        guard let best = ranked.first, best.count > 0 else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: settings.language.resolvedCode)
        let name = formatter.monthSymbols[max(0, min(11, best.month - 1))].capitalized
        return (best.month, best.count, name)
    }
    
    /// The most common zodiac sign
    public var mostCommonZodiac: (symbol: String, name: String, count: Int)? {
        guard !people.isEmpty else { return nil }
        var counts: [String: (symbol: String, name: String, count: Int)] = [:]
        for p in people {
            let sign = p.zodiacSign(for: settings.language)
            let key = sign.name
            let cur = counts[key]?.count ?? 0
            counts[key] = (sign.symbol, sign.name, cur + 1)
        }
        let sorted = counts.values.sorted { a, b in
            if a.count != b.count {
                return a.count > b.count
            }
            return a.name < b.name
        }
        return sorted.first
    }
    
    /// Average age of saved birthdays (for persons with birth year specified)
    public var averageAge: Double? {
        let ages = people.compactMap { $0.currentAge() }.filter { $0 >= 0 }
        guard !ages.isEmpty else { return nil }
        let sum = ages.reduce(0, +)
        return Double(sum) / Double(ages.count)
    }
    
    /// Upcoming milestone birthdays (18, 20, 30, 40, 50, etc.)
    public var milestoneBirthdays: [(person: BirthdayPerson, age: Int)] {
        let milestones: Set<Int> = [1, 18, 20, 25, 30, 40, 50, 60, 70, 75, 80, 90, 100]
        return sortedUpcomingPeople.compactMap { p in
            guard let age = p.upcomingAge(), milestones.contains(age) else { return nil }
            return (p, age)
        }
    }
    
    /// People occurring in the given season
    public func people(in season: Season) -> [BirthdayPerson] {
        people.filter { $0.season == season }
    }
    
    /// People occurring in the given month (1 to 12)
    public func people(inMonth month: Int) -> [BirthdayPerson] {
        people.filter { $0.birthMonth == month }
            .sorted { ($0.birthDay) < ($1.birthDay) }
    }
    
    /// Count of celebrations that have already occurred in the current calendar year up to today
    public var pastCelebrationsThisYearCount: Int {
        let calendar = Calendar.current
        let now = Date()
        let curM = calendar.component(.month, from: now)
        let curD = calendar.component(.day, from: now)
        return people.filter { p in
            (p.birthMonth < curM) || (p.birthMonth == curM && p.birthDay <= curD)
        }.count
    }
    
    /// Total count of celebrations in active list
    public var totalCelebrationsCount: Int {
        people.count
    }
    
    /// People belonging to a given zodiac symbol (♈, ♉, etc.)
    public func people(inZodiacSymbol symbol: String) -> [BirthdayPerson] {
        people.filter { $0.zodiacSign(for: .english).symbol == symbol }
    }
    
    /// Season with the most celebrations
    public var busiestSeason: (season: Season, count: Int)? {
        guard !people.isEmpty else { return nil }
        var counts: [Season: Int] = [.spring: 0, .summer: 0, .autumn: 0, .winter: 0]
        for p in people {
            counts[p.season, default: 0] += 1
        }
        let currentSeason = Season.current()
        let ranked = Season.allCases
            .map { (season: $0, count: counts[$0] ?? 0) }
            .sorted { a, b in
                if a.count != b.count {
                    return a.count > b.count
                }
                if a.season == currentSeason { return true }
                if b.season == currentSeason { return false }
                let idxA = Season.allCases.firstIndex(of: a.season) ?? 0
                let idxB = Season.allCases.firstIndex(of: b.season) ?? 0
                return idxA < idxB
            }
        guard let best = ranked.first, best.count > 0 else { return nil }
        return (best.season, best.count)
    }
    
    /// Total expenditure on purchased or given gifts
    public var totalGiftsSpent: Double {
        var total: Double = 0.0
        for person in people {
            for gift in person.gifts {
                if (gift.status == .purchased || gift.status == .given), let price = gift.price {
                    total += price
                }
            }
        }
        return total
    }
    
    public struct PendingGiftIdea: Identifiable {
        public var id: UUID { gift.id }
        public let person: BirthdayPerson
        public let gift: GiftItem
        
        public init(person: BirthdayPerson, gift: GiftItem) {
            self.person = person
            self.gift = gift
        }
    }
    
    /// All pending gift ideas with their associated person
    public var allPendingGiftIdeas: [PendingGiftIdea] {
        var list: [PendingGiftIdea] = []
        for person in people {
            for gift in person.gifts {
                if gift.status == .idea {
                    list.append(PendingGiftIdea(person: person, gift: gift))
                }
            }
        }
        return list
    }
    
    /// Total count of pending gift ideas
    public var pendingIdeasCount: Int {
        var count: Int = 0
        for person in people {
            for gift in person.gifts {
                if gift.status == .idea {
                    count += 1
                }
            }
        }
        return count
    }
    
    public struct PurchasedGiftItem: Identifiable {
        public var id: UUID { gift.id }
        public let person: BirthdayPerson
        public let gift: GiftItem
        
        public init(person: BirthdayPerson, gift: GiftItem) {
            self.person = person
            self.gift = gift
        }
    }
    
    /// All purchased or given gifts with their associated person
    public var allPurchasedGifts: [PurchasedGiftItem] {
        var list: [PurchasedGiftItem] = []
        for person in people {
            for gift in person.gifts {
                if gift.status == .purchased || gift.status == .given {
                    list.append(PurchasedGiftItem(person: person, gift: gift))
                }
            }
        }
        return list
    }
    
    /// Total count of purchased or given gifts
    public var purchasedGiftsCount: Int {
        var count: Int = 0
        for person in people {
            for gift in person.gifts {
                if gift.status == .purchased || gift.status == .given {
                    count += 1
                }
            }
        }
        return count
    }
    
    // MARK: - CRUD
    
    public func addPerson(_ person: BirthdayPerson) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            people.append(person)
        }
        savePeople()
        NotificationManager.shared.scheduleNotifications(for: person, settings: settings)
    }
    
    public func updatePerson(_ person: BirthdayPerson) {
        if let index = people.firstIndex(where: { $0.id == person.id }) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                people[index] = person
            }
            savePeople()
            NotificationManager.shared.scheduleNotifications(for: person, settings: settings)
        }
    }
    
    public func deletePerson(_ person: BirthdayPerson) {
        NotificationManager.shared.cancelNotifications(for: person)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            people.removeAll(where: { $0.id == person.id })
        }
        savePeople()
    }
    
    // MARK: - Gift Tracker
    
    public func addGift(to personId: UUID, gift: GiftItem) {
        if let index = people.firstIndex(where: { $0.id == personId }) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                people[index].gifts.append(gift)
            }
            savePeople()
        }
    }
    
    public func updateGift(for personId: UUID, gift: GiftItem) {
        if let pIndex = people.firstIndex(where: { $0.id == personId }) {
            if let gIndex = people[pIndex].gifts.firstIndex(where: { $0.id == gift.id }) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    people[pIndex].gifts[gIndex] = gift
                }
                savePeople()
            }
        }
    }
    
    public func deleteGift(from personId: UUID, giftId: UUID) {
        if let pIndex = people.firstIndex(where: { $0.id == personId }) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                people[pIndex].gifts.removeAll(where: { $0.id == giftId })
            }
            savePeople()
        }
    }
    
    public func importContacts(_ contacts: [ImportableContact]) {
        for contact in contacts where contact.isSelected && !contact.isAlreadyImported {
            let newPerson = BirthdayPerson(
                name: contact.name,
                birthDay: contact.birthDay,
                birthMonth: contact.birthMonth,
                birthYear: contact.birthYear,
                notifyOnSameDay: settings.defaultSameDayEnabled,
                notifyInAdvance: settings.defaultAdvanceEnabled,
                advanceDays: settings.defaultAdvanceDays,
                colorIndex: Int.random(in: 0..<CandleTheme.avatarColorPairs.count),
                avatarImageData: contact.imageData,
                linkedContactId: contact.id
            )
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                people.append(newPerson)
            }
            NotificationManager.shared.scheduleNotifications(for: newPerson, settings: settings)
        }
        savePeople()
    }
    
    public func updateSettings(_ newSettings: NotificationSettings) {
        self.settings = newSettings
        saveSettings()
        // Reschedule all notifications with new settings
        rescheduleAll()
    }
    
    public func rescheduleAll() {
        for person in people {
            NotificationManager.shared.scheduleNotifications(for: person, settings: settings)
        }
    }
    
    // MARK: - Backup & Restore
    
    // MARK: - Backup & Export Files (.json, .csv, .ics)
    
    /// Export complete structured backup in JSON format
    public func createBackupFileURL() -> URL? {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(people)
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Candle_Compleanni_Backup.json")
            try data.write(to: tempURL, options: .atomic)
            return tempURL
        } catch {
            print("Error exporting JSON backup: \(error)")
            return nil
        }
    }
    
    /// Export birthdays in CSV format readable by Excel, Numbers, or Google Sheets
    public func createCSVBackupFileURL() -> URL? {
        var csv = "Nome,Giorno,Mese,Anno,Note,Regali\n"
        for person in people {
            let cleanName = person.name.replacingOccurrences(of: "\"", with: "\"\"")
            let yearStr = person.birthYear.map { String($0) } ?? ""
            let cleanNotes = person.notes.replacingOccurrences(of: "\"", with: "\"\"").replacingOccurrences(of: "\n", with: " ")
            let giftTitles = person.gifts.map { "\($0.status.emoji) \($0.title) (\($0.formattedDate))" }.joined(separator: " | ").replacingOccurrences(of: "\"", with: "\"\"")
            csv += "\"\(cleanName)\",\(person.birthDay),\(person.birthMonth),\(yearStr),\"\(cleanNotes)\",\"\(giftTitles)\"\n"
        }
        do {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Candle_Compleanni.csv")
            try csv.data(using: .utf8)?.write(to: tempURL, options: .atomic)
            return tempURL
        } catch {
            print("Error exporting CSV backup: \(error)")
            return nil
        }
    }
    
    /// Export birthdays in iCalendar (.ics) format for Apple Calendar, Google Calendar, and Outlook
    public func createICSBackupFileURL() -> URL? {
        var ics = """
        BEGIN:VCALENDAR
        VERSION:2.0
        PRODID:-//Candle App//Birthday Calendar//EN
        CALSCALE:GREGORIAN
        METHOD:PUBLISH
        X-WR-CALNAME:Candle Birthdays
        
        """
        let yearNow = Calendar.current.component(.year, from: Date())
        for person in people {
            let uid = "\(person.id.uuidString)@candle.app"
            let startYear = person.birthYear ?? yearNow
            let dateStr = String(format: "%04d%02d%02d", startYear, person.birthMonth, person.birthDay)
            let cleanName = person.name.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: ",", with: "\\,")
            let cleanNotes = person.notes.replacingOccurrences(of: "\n", with: "\\n").replacingOccurrences(of: ",", with: "\\,")
            let desc = cleanNotes.isEmpty ? "Celebration managed with Candle" : cleanNotes
            let locationLine: String
            if let loc = person.celebrationLocation?.trimmingCharacters(in: .whitespacesAndNewlines), !loc.isEmpty {
                let cleanLoc = loc.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: ",", with: "\\,")
                locationLine = "LOCATION:\(cleanLoc)\n"
            } else {
                locationLine = ""
            }
            
            ics += """
            BEGIN:VEVENT
            UID:\(uid)
            SUMMARY:\(cleanName) - Birthday
            DTSTART;VALUE=DATE:\(dateStr)
            RRULE:FREQ=YEARLY
            \(locationLine)DESCRIPTION:\(desc)
            TRANSP:TRANSPARENT
            END:VEVENT
            
            """
        }
        ics += "END:VCALENDAR\n"
        
        do {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Candle_Compleanni.ics")
            try ics.data(using: .utf8)?.write(to: tempURL, options: .atomic)
            return tempURL
        } catch {
            print("Error exporting ICS backup: \(error)")
            return nil
        }
    }
    
    /// Import birthdays from any supported file (.json, .csv, .ics)
    public func importFromFile(url: URL, merge: Bool = true) throws -> (count: Int, format: String) {
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "csv":
            let count = try importFromCSV(url: url, merge: merge)
            return (count, "CSV")
        case "ics":
            let count = try importFromICS(url: url, merge: merge)
            return (count, "iCalendar (.ics)")
        default:
            let count = try importFromJSON(url: url, merge: merge)
            return (count, "JSON")
        }
    }
    
    public func importFromJSON(url: URL, merge: Bool = true) throws -> Int {
        let shouldStopAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if shouldStopAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        let data = try Data(contentsOf: url)
        let importedList = try JSONDecoder().decode([BirthdayPerson].self, from: data)
        return addImportedPeople(importedList, merge: merge)
    }
    
    public func importFromCSV(url: URL, merge: Bool = true) throws -> Int {
        let shouldStopAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if shouldStopAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        let content = try String(contentsOf: url, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        guard !lines.isEmpty else { return 0 }
        
        // Detect separator (comma or semicolon)
        let separator: Character = lines.first?.contains(";") == true ? ";" : ","
        
        var importedList: [BirthdayPerson] = []
        let startIndex = (lines[0].lowercased().contains("nome") || lines[0].lowercased().contains("name")) ? 1 : 0
        
        for i in startIndex..<lines.count {
            let row = parseCSVRow(lines[i], separator: separator)
            guard row.count >= 3 else { continue }
            
            let name = row[0].trimmingCharacters(in: .whitespaces)
            guard !name.isEmpty, let day = Int(row[1].trimmingCharacters(in: .whitespaces)),
                  let month = Int(row[2].trimmingCharacters(in: .whitespaces)),
                  (1...31).contains(day), (1...12).contains(month) else {
                continue
            }
            
            var year: Int? = nil
            if row.count >= 4, let parsedYear = Int(row[3].trimmingCharacters(in: .whitespaces)), parsedYear > 1900 && parsedYear < 2100 {
                year = parsedYear
            }
            
            let notes = row.count >= 5 ? row[4] : ""
            
            let person = BirthdayPerson(
                name: name,
                birthDay: day,
                birthMonth: month,
                birthYear: year,
                notes: notes,
                colorIndex: Int.random(in: 0...5)
            )
            importedList.append(person)
        }
        
        return addImportedPeople(importedList, merge: merge)
    }
    
    public func importFromICS(url: URL, merge: Bool = true) throws -> Int {
        let shouldStopAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if shouldStopAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        let content = try String(contentsOf: url, encoding: .utf8)
        let events = content.components(separatedBy: "BEGIN:VEVENT")
        var importedList: [BirthdayPerson] = []
        
        for event in events.dropFirst() {
            var name = ""
            var day = 0
            var month = 0
            var year: Int? = nil
            var notes = ""
            
            let lines = event.components(separatedBy: .newlines)
            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.starts(with: "SUMMARY:") {
                    let raw = String(trimmed.dropFirst(8))
                    name = raw.replacingOccurrences(of: " - Compleanno", with: "")
                              .replacingOccurrences(of: " - Birthday", with: "")
                              .replacingOccurrences(of: " Compleanno", with: "")
                              .replacingOccurrences(of: " Birthday", with: "")
                              .replacingOccurrences(of: "\\,", with: ",")
                              .trimmingCharacters(in: .whitespaces)
                } else if trimmed.starts(with: "DTSTART") {
                    let parts = trimmed.components(separatedBy: ":")
                    if let dateStr = parts.last?.trimmingCharacters(in: .whitespaces), dateStr.count >= 8 {
                        let yStr = String(dateStr.prefix(4))
                        let mStr = String(dateStr.dropFirst(4).prefix(2))
                        let dStr = String(dateStr.dropFirst(6).prefix(2))
                        
                        if let d = Int(dStr), let m = Int(mStr) {
                            day = d
                            month = m
                            if let y = Int(yStr), y > 1900 && y < 2100 {
                                year = y
                            }
                        }
                    }
                } else if trimmed.starts(with: "DESCRIPTION:") {
                    let raw = String(trimmed.dropFirst(12))
                    if !raw.contains("Candle") {
                        notes = raw.replacingOccurrences(of: "\\n", with: "\n").replacingOccurrences(of: "\\,", with: ",")
                    }
                }
            }
            
            if !name.isEmpty && (1...31).contains(day) && (1...12).contains(month) {
                let person = BirthdayPerson(
                    name: name,
                    birthDay: day,
                    birthMonth: month,
                    birthYear: year,
                    notes: notes,
                    colorIndex: Int.random(in: 0...5)
                )
                importedList.append(person)
            }
        }
        
        return addImportedPeople(importedList, merge: merge)
    }
    
    private func parseCSVRow(_ row: String, separator: Character) -> [String] {
        var fields: [String] = []
        var current = ""
        var insideQuotes = false
        
        for char in row {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == separator && !insideQuotes {
                fields.append(current.trimmingCharacters(in: CharacterSet(charactersIn: "\"")))
                current = ""
            } else {
                current.append(char)
            }
        }
        fields.append(current.trimmingCharacters(in: CharacterSet(charactersIn: "\"")))
        return fields
    }
    
    private func addImportedPeople(_ importedList: [BirthdayPerson], merge: Bool) -> Int {
        var countAdded = 0
        if !merge {
            NotificationManager.shared.cancelAll()
            self.people = importedList
            countAdded = importedList.count
        } else {
            for person in importedList {
                let alreadyExists = self.people.contains {
                    $0.name.caseInsensitiveCompare(person.name) == .orderedSame &&
                    $0.birthDay == person.birthDay &&
                    $0.birthMonth == person.birthMonth
                }
                if !alreadyExists {
                    self.people.append(person)
                    countAdded += 1
                }
            }
        }
        
        savePeople()
        rescheduleAll()
        return countAdded
    }
    
    // MARK: - Persistence
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var peopleURL: URL {
        documentsDirectory.appendingPathComponent(peopleFileName)
    }
    
    private var settingsURL: URL {
        documentsDirectory.appendingPathComponent(settingsFileName)
    }
    
    private func savePeople(syncToCloud: Bool = true) {
        do {
            let data = try JSONEncoder().encode(people)
            try data.write(to: peopleURL, options: [.atomicWrite])
            #if canImport(WidgetKit)
            WidgetCenter.shared.reloadAllTimelines()
            #endif
            
            if syncToCloud && settings.iCloudSyncEnabled {
                let uStore = NSUbiquitousKeyValueStore.default
                uStore.set(data, forKey: cloudPeopleKey)
                uStore.set(Date().timeIntervalSince1970, forKey: cloudTimestampKey)
                uStore.synchronize()
                lastICloudSyncDate = Date()
            }
        } catch {
            print("Error saving birthdays: \(error)")
        }
    }
    
    private func loadPeople() {
        if FileManager.default.fileExists(atPath: peopleURL.path) {
            do {
                let data = try Data(contentsOf: peopleURL)
                self.people = try JSONDecoder().decode([BirthdayPerson].self, from: data)
                return
            } catch {
                print("Error loading birthdays: \(error)")
            }
        }
        
        // No sample data: starts cleanly
        self.people = []
    }
    
    private func saveSettings() {
        do {
            let data = try JSONEncoder().encode(settings)
            try data.write(to: settingsURL, options: [.atomicWrite])
            
            if settings.iCloudSyncEnabled {
                let uStore = NSUbiquitousKeyValueStore.default
                uStore.set(data, forKey: cloudSettingsKey)
                uStore.synchronize()
            }
        } catch {
            print("Error saving settings: \(error)")
        }
    }
    
    private func loadSettings() {
        if FileManager.default.fileExists(atPath: settingsURL.path) {
            do {
                let data = try Data(contentsOf: settingsURL)
                self.settings = try JSONDecoder().decode(NotificationSettings.self, from: data)
            } catch {
                print("Error loading settings: \(error)")
            }
        }
    }
    
    // MARK: - iCloud Synchronization
    
    private func setupICloudSync() {
        NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: NSUbiquitousKeyValueStore.default,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleICloudExternalChange()
            }
        }
        
        NSUbiquitousKeyValueStore.default.synchronize()
        if settings.iCloudSyncEnabled {
            syncWithICloud(manual: false)
        }
    }
    
    public func syncWithICloud(manual: Bool = false) {
        guard settings.iCloudSyncEnabled else { return }
        isSyncingICloud = true
        
        let uStore = NSUbiquitousKeyValueStore.default
        uStore.synchronize()
        
        // 1. Check if cloud records exist
        if let cloudData = uStore.data(forKey: cloudPeopleKey) {
            do {
                let cloudPeople = try JSONDecoder().decode([BirthdayPerson].self, from: cloudData)
                let cloudTimestamp = uStore.double(forKey: cloudTimestampKey)
                
                var merged = self.people
                var didAddAny = false
                
                for cPerson in cloudPeople {
                    if let index = merged.firstIndex(where: { $0.id == cPerson.id }) {
                        if cloudTimestamp > (lastICloudSyncDate?.timeIntervalSince1970 ?? 0) {
                            merged[index] = cPerson
                            didAddAny = true
                        }
                    } else {
                        let duplicateByName = merged.contains {
                            $0.name.caseInsensitiveCompare(cPerson.name) == .orderedSame &&
                            $0.birthDay == cPerson.birthDay &&
                            $0.birthMonth == cPerson.birthMonth
                        }
                        if !duplicateByName {
                            merged.append(cPerson)
                            didAddAny = true
                        }
                    }
                }
                
                if didAddAny {
                    self.people = merged
                    savePeople(syncToCloud: false)
                    rescheduleAll()
                }
            } catch {
                print("Error decoding iCloud people: \(error)")
            }
        }
        
        // 2. Update Cloud with local records if missing
        if let localData = try? JSONEncoder().encode(self.people) {
            uStore.set(localData, forKey: cloudPeopleKey)
            uStore.set(Date().timeIntervalSince1970, forKey: cloudTimestampKey)
            uStore.synchronize()
        }
        
        lastICloudSyncDate = Date()
        isSyncingICloud = false
        
        if manual {
            CandleTheme.hapticNotification(type: .success)
        }
    }
    
    private func handleICloudExternalChange() {
        guard settings.iCloudSyncEnabled else { return }
        syncWithICloud(manual: false)
    }
}
