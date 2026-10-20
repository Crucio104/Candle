import Foundation
import EventKit

@MainActor
public final class CalendarSyncManager: ObservableObject {
    public static let shared = CalendarSyncManager()
    
    private let eventStore = EKEventStore()
    @Published public var isAuthorized: Bool = false
    @Published public var isSyncing: Bool = false
    
    public init() {
        checkStatus()
    }
    
    public func checkStatus() {
        let status = EKEventStore.authorizationStatus(for: .event)
        if #available(iOS 17.0, *) {
            self.isAuthorized = (status == .fullAccess || status == .writeOnly)
        } else {
            self.isAuthorized = (status == .authorized)
        }
    }
    
    public func requestAccess() async -> Bool {
        do {
            if #available(iOS 17.0, *) {
                let granted = try await eventStore.requestFullAccessToEvents()
                checkStatus()
                return granted
            } else {
                let granted = try await eventStore.requestAccess(to: .event)
                checkStatus()
                return granted
            }
        } catch {
            print("Error accessing calendar: \(error)")
            checkStatus()
            return false
        }
    }
    
    /// Syncs all birthdays stored in Candle into Apple Calendar
    public func syncBirthdays(_ people: [BirthdayPerson]) async throws -> Int {
        isSyncing = true
        defer { isSyncing = false }
        
        let granted = await requestAccess()
        guard granted else {
            throw CalendarSyncError.accessDenied
        }
        
        guard let defaultCalendar = eventStore.defaultCalendarForNewEvents else {
            throw CalendarSyncError.noCalendarFound
        }
        
        var count = 0
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        
        for person in people {
            // Check if an event already exists for this person to avoid duplicates
            var comp = DateComponents()
            comp.year = currentYear
            comp.month = person.birthMonth
            comp.day = person.birthDay
            
            guard let startDate = calendar.date(from: comp) else { continue }
            let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? startDate
            
            let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [defaultCalendar])
            let existingEvents = eventStore.events(matching: predicate)
            let alreadyExists = existingEvents.contains { event in
                event.title?.contains(person.name) == true
            }
            
            if !alreadyExists {
                let event = EKEvent(eventStore: eventStore)
                event.title = "🎂 \(person.name)"
                event.calendar = defaultCalendar
                event.isAllDay = true
                event.startDate = startDate
                event.endDate = startDate
                
                // Yearly recurrence
                let recurrence = EKRecurrenceRule(
                    recurrenceWith: .yearly,
                    interval: 1,
                    end: nil
                )
                event.recurrenceRules = [recurrence]
                
                if !person.notes.isEmpty {
                    event.notes = person.notes
                }
                
                // Alarm on the morning of birthday at 09:00 AM
                event.addAlarm(EKAlarm(relativeOffset: 9 * 3600))
                
                try eventStore.save(event, span: .futureEvents)
                count += 1
            }
        }
        
        return count
    }
    
    public enum CalendarSyncError: LocalizedError {
        case accessDenied
        case noCalendarFound
        
        public var errorDescription: String? {
            switch self {
            case .accessDenied:
                return "Calendar access was denied in iOS Settings."
            case .noCalendarFound:
                return "No default calendar found on this device."
            }
        }
    }
}
