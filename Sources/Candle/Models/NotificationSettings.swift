import Foundation
import SwiftUI

public enum AppAppearance: String, Codable, CaseIterable, Identifiable, Sendable {
    case system = "Sistema"
    case light = "Chiara"
    case dark = "Scura"
    
    public var id: String { rawValue }
    
    public var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

public struct NotificationSettings: Codable, Equatable, Sendable {
    public var notificationHour: Int
    public var notificationMinute: Int
    public var defaultSameDayEnabled: Bool
    public var defaultAdvanceEnabled: Bool
    public var defaultAdvanceDays: Int
    public var appearance: AppAppearance
    public var language: AppLanguage
    public var accentColor: AppAccentColor
    public var iCloudSyncEnabled: Bool
    public var syncContactName: Bool
    public var syncContactPhoto: Bool
    public var syncContactBirthday: Bool
    public var customCategories: [String]
    public var categoryOrder: [String]
    
    public init(
        notificationHour: Int = 9,
        notificationMinute: Int = 0,
        defaultSameDayEnabled: Bool = true,
        defaultAdvanceEnabled: Bool = true,
        defaultAdvanceDays: Int = 3,
        appearance: AppAppearance = .system,
        language: AppLanguage = .english,
        accentColor: AppAccentColor = .candleAmber,
        iCloudSyncEnabled: Bool = true,
        syncContactName: Bool = false,
        syncContactPhoto: Bool = false,
        syncContactBirthday: Bool = true,
        customCategories: [String] = [],
        categoryOrder: [String] = []
    ) {
        self.notificationHour = notificationHour
        self.notificationMinute = notificationMinute
        self.defaultSameDayEnabled = defaultSameDayEnabled
        self.defaultAdvanceEnabled = defaultAdvanceEnabled
        self.defaultAdvanceDays = defaultAdvanceDays
        self.appearance = appearance
        self.language = language
        self.accentColor = accentColor
        self.iCloudSyncEnabled = iCloudSyncEnabled
        self.syncContactName = syncContactName
        self.syncContactPhoto = syncContactPhoto
        self.syncContactBirthday = syncContactBirthday
        self.customCategories = customCategories
        self.categoryOrder = categoryOrder
    }
    
    enum CodingKeys: String, CodingKey {
        case notificationHour, notificationMinute, defaultSameDayEnabled
        case defaultAdvanceEnabled, defaultAdvanceDays, appearance
        case language, accentColor, iCloudSyncEnabled
        case syncContactName, syncContactPhoto, syncContactBirthday
        case customCategories, categoryOrder
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.notificationHour = try container.decodeIfPresent(Int.self, forKey: .notificationHour) ?? 9
        self.notificationMinute = try container.decodeIfPresent(Int.self, forKey: .notificationMinute) ?? 0
        self.defaultSameDayEnabled = try container.decodeIfPresent(Bool.self, forKey: .defaultSameDayEnabled) ?? true
        self.defaultAdvanceEnabled = try container.decodeIfPresent(Bool.self, forKey: .defaultAdvanceEnabled) ?? true
        self.defaultAdvanceDays = try container.decodeIfPresent(Int.self, forKey: .defaultAdvanceDays) ?? 3
        self.appearance = try container.decodeIfPresent(AppAppearance.self, forKey: .appearance) ?? .system
        self.language = try container.decodeIfPresent(AppLanguage.self, forKey: .language) ?? .english
        self.accentColor = try container.decodeIfPresent(AppAccentColor.self, forKey: .accentColor) ?? .candleAmber
        self.iCloudSyncEnabled = try container.decodeIfPresent(Bool.self, forKey: .iCloudSyncEnabled) ?? true
        self.syncContactName = try container.decodeIfPresent(Bool.self, forKey: .syncContactName) ?? false
        self.syncContactPhoto = try container.decodeIfPresent(Bool.self, forKey: .syncContactPhoto) ?? false
        self.syncContactBirthday = try container.decodeIfPresent(Bool.self, forKey: .syncContactBirthday) ?? true
        self.customCategories = try container.decodeIfPresent([String].self, forKey: .customCategories) ?? []
        self.categoryOrder = try container.decodeIfPresent([String].self, forKey: .categoryOrder) ?? []
    }
    
    public static let standard = NotificationSettings()
}

