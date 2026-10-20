import Foundation
import UserNotifications
import UIKit

@MainActor
public final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    public static let shared = NotificationManager()
    
    @Published public var isAuthorized: Bool = false
    @Published public var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    public static let categoryBirthday = "CANDLE_BIRTHDAY_CATEGORY"
    public static let actionSnooze = "CANDLE_ACTION_SNOOZE"
    
    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        registerCategories()
        checkStatus()
        clearBadge()
    }
    
    private func registerCategories() {
        let snoozeAction = UNNotificationAction(
            identifier: Self.actionSnooze,
            title: "⏰ Snooze 1h",
            options: []
        )
        let birthdayCategory = UNNotificationCategory(
            identifier: Self.categoryBirthday,
            actions: [snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([birthdayCategory])
    }
    
    public func clearBadge() {
        Task { @MainActor in
            if #available(iOS 16.0, *) {
                try? await UNUserNotificationCenter.current().setBadgeCount(0)
            } else {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }
    }
    
    public func checkStatus() {
        Task { @MainActor in
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            self.authorizationStatus = settings.authorizationStatus
            self.isAuthorized = (settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional)
            clearBadge()
        }
    }
    
    public func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            checkStatus()
            clearBadge()
            return granted
        } catch {
            print("Error requesting notification authorization: \(error)")
            checkStatus()
            return false
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    public nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .list])
        } else {
            completionHandler([.alert, .sound])
        }
    }
    
    public nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.actionIdentifier == "CANDLE_ACTION_SNOOZE" {
            let originalContent = response.notification.request.content
            let snoozeContent = (originalContent.mutableCopy() as? UNMutableNotificationContent) ?? UNMutableNotificationContent()
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
            let snoozeRequest = UNNotificationRequest(
                identifier: "snooze-\(UUID().uuidString)",
                content: snoozeContent,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(snoozeRequest)
        }
        completionHandler()
    }
    
    // MARK: - Birthday Scheduling
    
    public func scheduleNotifications(for person: BirthdayPerson, settings: NotificationSettings) {
        cancelNotifications(for: person)
        
        guard !person.isOneShotExpired else { return }
        
        let center = UNUserNotificationCenter.current()
        let calendar = Calendar.current
        
        // 1. Same-day event notification
        if person.notifyOnSameDay {
            let content = UNMutableNotificationContent()
            content.sound = .default
            content.categoryIdentifier = Self.categoryBirthday
            
            if person.eventType == .special {
                if person.recurrence == .monthly {
                    content.title = "⭐️ Ricorrenza mensile di \(person.name)!"
                    content.body = "Oggi ricorre l'evento speciale di \(person.name)!"
                } else if person.recurrence == .oneTime {
                    content.title = "🎯 Occasione speciale di \(person.name)!"
                    content.body = "Oggi è il giorno speciale di \(person.name)!"
                } else {
                    content.title = "⭐️ Occasione speciale di \(person.name)!"
                    content.body = "Oggi ricorre l'occasione speciale di \(person.name)!"
                }
            } else if person.eventType == .anniversary {
                if person.recurrence == .monthly {
                    if let count = person.upcomingMesiversarioNumber() {
                        if count % 12 == 0 {
                            let years = count / 12
                            content.title = "💍 \(years)° Anniversario di \(person.name)!"
                            content.body = "Oggi ricorre il \(years)° anniversario di \(person.name)! Festeggia e fai gli auguri."
                        } else {
                            content.title = "💍 \(count)° Mesiversario di \(person.name)!"
                            content.body = "Oggi ricorre il \(count)° mesiversario di \(person.name)! Festeggia e fai gli auguri."
                        }
                    } else {
                        content.title = "💍 Mesiversario di \(person.name)!"
                        content.body = "Oggi è il mesiversario di \(person.name)! Festeggia e fai gli auguri."
                    }
                } else {
                    content.title = "💍 Anniversario di \(person.name)!"
                    content.body = "Oggi è l'anniversario di \(person.name)! Festeggia e fai gli auguri."
                }
            } else if person.eventType == .nameday {
                content.title = "💐 Onomastico di \(person.name)!"
                content.body = "Oggi è l'onomastico di \(person.name)! Non dimenticare gli auguri."
            } else if let age = person.upcomingAge() {
                if age == 0 {
                    content.title = "🍼 \(person.name) è nata/o oggi!"
                    content.body = "Oggi è il suo giorno speciale di nascita! Fai gli auguri con affetto."
                } else {
                    content.title = "🎉 Compleanno di \(person.name)!"
                    content.body = "Oggi compie \(age) anni! Non dimenticare di fargli gli auguri."
                }
            } else {
                content.title = "🎉 Compleanno di \(person.name)!"
                content.body = "Oggi è il suo compleanno! Fagli gli auguri con affetto."
            }
            
            var dateComponents = DateComponents()
            let repeats = (person.recurrence != .oneTime)
            if person.recurrence == .monthly {
                dateComponents.day = person.birthDay
            } else if person.recurrence == .oneTime {
                let targetYear = person.birthYear ?? calendar.component(.year, from: Date())
                dateComponents.year = targetYear
                dateComponents.month = person.birthMonth
                dateComponents.day = person.birthDay
            } else {
                dateComponents.month = person.birthMonth
                dateComponents.day = person.birthDay
            }
            dateComponents.hour = settings.notificationHour
            dateComponents.minute = settings.notificationMinute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
            let request = UNNotificationRequest(
                identifier: sameDayNotificationId(for: person.id),
                content: content,
                trigger: trigger
            )
            
            center.add(request) { error in
                if let error = error {
                    print("Error scheduling same-day notification: \(error)")
                }
            }
        }
        
        // 2. Advance reminder notification
        if person.notifyInAdvance && person.advanceDays > 0 {
            let content = UNMutableNotificationContent()
            content.sound = .default
            
            let daysText = person.advanceDays == 1 ? "domani" : "tra \(person.advanceDays) giorni"
            if person.eventType == .special {
                content.title = "⭐️ Ricorrenza di \(person.name) in arrivo"
                content.body = "L'occasione speciale sarà \(daysText)! Preparati a festeggiare."
            } else if person.eventType == .anniversary {
                if person.recurrence == .monthly {
                    if let count = person.upcomingMesiversarioNumber() {
                        if count % 12 == 0 {
                            let years = count / 12
                            content.title = "💍 \(years)° Anniversario di \(person.name) in arrivo"
                            content.body = "Il \(years)° anniversario sarà \(daysText)! Hai già pensato al regalo o agli auguri?"
                        } else {
                            content.title = "💍 \(count)° Mesiversario di \(person.name) in arrivo"
                            content.body = "Il \(count)° mesiversario sarà \(daysText)! Hai già pensato a una sorpresa o agli auguri?"
                        }
                    } else {
                        content.title = "💍 Mesiversario di \(person.name) in arrivo"
                        content.body = "Il mesiversario sarà \(daysText)! Hai già pensato a una sorpresa o agli auguri?"
                    }
                } else {
                    content.title = "💍 Anniversario di \(person.name) in arrivo"
                    content.body = "L'anniversario sarà \(daysText)! Hai già pensato al regalo o agli auguri?"
                }
            } else if person.eventType == .nameday {
                content.title = "💐 Onomastico di \(person.name) in arrivo"
                content.body = "L'onomastico sarà \(daysText)! Preparati a fare gli auguri."
            } else if let age = person.upcomingAge() {
                if age == 0 {
                    content.title = "🎁 Nascita di \(person.name) in arrivo"
                    content.body = "Nascerà \(daysText)! Hai già pensato a un regalo o ai preparativi?"
                } else {
                    content.title = "🎁 Compleanno di \(person.name) in arrivo"
                    content.body = "Compirà \(age) anni \(daysText)! Hai già pensato a un regalo o agli auguri?"
                }
            } else {
                content.title = "🎁 Compleanno di \(person.name) in arrivo"
                content.body = "Il suo compleanno sarà \(daysText)! Preparati a festeggiare."
            }
            
            let nextTarget = person.nextBirthdayDate()
            if let advanceDate = calendar.date(byAdding: .day, value: -person.advanceDays, to: nextTarget) {
                let advanceMonth = calendar.component(.month, from: advanceDate)
                let advanceDay = calendar.component(.day, from: advanceDate)
                
                var triggerComponents = DateComponents()
                let repeats = (person.recurrence != .oneTime)
                if person.recurrence == .oneTime {
                    triggerComponents.year = calendar.component(.year, from: advanceDate)
                    triggerComponents.month = advanceMonth
                } else if person.recurrence != .monthly {
                    triggerComponents.month = advanceMonth
                }
                triggerComponents.day = advanceDay
                triggerComponents.hour = settings.notificationHour
                triggerComponents.minute = settings.notificationMinute
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: repeats)
                let request = UNNotificationRequest(
                    identifier: advanceNotificationId(for: person.id),
                    content: content,
                    trigger: trigger
                )
                
                center.add(request) { error in
                    if let error = error {
                        print("Error scheduling advance notification: \(error)")
                    }
                }
            }
        }
    }
    
    public func cancelNotifications(for person: BirthdayPerson) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [
            sameDayNotificationId(for: person.id),
            advanceNotificationId(for: person.id)
        ])
    }
    
    public func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Test Notification (Foreground & Background support)
    
    public func sendTestNotification(delay: TimeInterval = 2.0, lang: AppLanguage = .english) async {
        // If not determined yet, request authorization
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            let granted = await requestAuthorization()
            guard granted else { return }
        } else if settings.authorizationStatus == .denied {
            return
        }
        
        let content = UNMutableNotificationContent()
        switch lang {
        case .italian:
            content.title = "🕯️ Candle — Notifica di Prova!"
            content.body = "🎉 Le notifiche funzionano alla perfezione! Riceverai tutti i promemoria dei compleanni in tempo."
        case .spanish:
            content.title = "🕯️ Candle — ¡Notificación de Prueba!"
            content.body = "🎉 ¡Las notificaciones funcionan perfectamente! Recibirás los recordatorios a tiempo."
        case .french:
            content.title = "🕯️ Candle — Notification de Test !"
            content.body = "🎉 Les notifications fonctionnent parfaitement ! Vous recevrez vos rappels à temps."
        case .german:
            content.title = "🕯️ Candle — Test-Benachrichtigung!"
            content.body = "🎉 Benachrichtigungen funktionieren perfekt! Du wirst rechtzeitig an Geburtstage erinnert."
        case .portuguese:
            content.title = "🕯️ Candle — Notificação de Teste!"
            content.body = "🎉 As notificações funcionam perfeitamente! Você receberá os lembretes no horário."
        case .english:
            content.title = "🕯️ Candle — Test Notification!"
            content.body = "🎉 Notifications are working perfectly! You will receive all your birthday alerts on time."
        }
        
        content.sound = .default
        clearBadge()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1.0, delay), repeats: false)
        let identifier = "candle-test-\(UUID().uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } catch {
            print("Error scheduling test notification: \(error)")
        }
    }
    
    private func sameDayNotificationId(for id: UUID) -> String {
        "candle-bday-sameday-\(id.uuidString)"
    }
    
    private func advanceNotificationId(for id: UUID) -> String {
        "candle-bday-advance-\(id.uuidString)"
    }
}
