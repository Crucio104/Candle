import Foundation
import SwiftUI

public enum GiftStatus: String, Codable, CaseIterable, Identifiable, Sendable {
    case idea = "idea"
    case purchased = "purchased"
    case given = "given"
    
    public var id: String { rawValue }
    
    public func localizedName(for lang: AppLanguage) -> String {
        switch lang {
        case .italian:
            switch self {
            case .idea: return "Idea"
            case .purchased: return "Comprato"
            case .given: return "Regalato"
            }
        case .spanish:
            switch self {
            case .idea: return "Idea"
            case .purchased: return "Comprado"
            case .given: return "Entregado"
            }
        case .french:
            switch self {
            case .idea: return "Idée"
            case .purchased: return "Acheté"
            case .given: return "Offert"
            }
        case .german:
            switch self {
            case .idea: return "Idee"
            case .purchased: return "Gekauft"
            case .given: return "Geschenkt"
            }
        case .portuguese:
            switch self {
            case .idea: return "Ideia"
            case .purchased: return "Comprado"
            case .given: return "Entregue"
            }
        case .english:
            switch self {
            case .idea: return "Idea"
            case .purchased: return "Bought"
            case .given: return "Given"
            }
        }
    }
    
    public var icon: String {
        switch self {
        case .idea: return "lightbulb"
        case .purchased: return "bag"
        case .given: return "gift.fill"
        }
    }
    
    public var emoji: String {
        switch self {
        case .idea: return "💡"
        case .purchased: return "🛍️"
        case .given: return "🎁"
        }
    }
}

public enum PersonCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case family = "family"
    case friends = "friends"
    case work = "work"
    case partner = "partner"
    case other = "other"
    
    public var id: String { rawValue }
    
    public var emoji: String {
        switch self {
        case .family: return "🏡"
        case .friends: return "🎉"
        case .work: return "💼"
        case .partner: return "❤️"
        case .other: return "🎈"
        }
    }
}

public enum EventType: String, Codable, CaseIterable, Identifiable, Sendable {
    case birthday = "birthday"
    case anniversary = "anniversary"
    case nameday = "nameday"
    case special = "special"
    
    public var id: String { rawValue }
    
    public var emoji: String {
        switch self {
        case .birthday: return "🎂"
        case .anniversary: return "💍"
        case .nameday: return "💐"
        case .special: return "⭐️"
        }
    }
}

public enum EventRecurrence: String, Codable, CaseIterable, Identifiable, Sendable {
    case yearly = "yearly"
    case monthly = "monthly"
    case oneTime = "one_time"
    
    public var id: String { rawValue }
    
    public var emoji: String {
        switch self {
        case .yearly: return "📅"
        case .monthly: return "🔄"
        case .oneTime: return "🎯"
        }
    }
    
    public func localizedName(for lang: AppLanguage, eventType: EventType? = nil) -> String {
        if self == .oneTime {
            switch lang {
            case .italian: return "Evento Singolo"
            case .spanish: return "Evento Único"
            case .french: return "Événement Unique"
            case .german: return "Einmaliges Event"
            case .portuguese: return "Evento Único"
            case .english: return "One-Time Event"
            }
        }
        if eventType == .anniversary {
            switch lang {
            case .italian:
                return self == .yearly ? "Annuale (Anniversario)" : "Mensile (Mesiversario)"
            case .spanish:
                return self == .yearly ? "Anual (Aniversario)" : "Mensual (Mesiversario)"
            case .french:
                return self == .yearly ? "Annuel (Anniversaire)" : "Mensuel (Mois-versaire)"
            case .german:
                return self == .yearly ? "Jährlich (Jahrestag)" : "Monatlich (Monatstag)"
            case .portuguese:
                return self == .yearly ? "Anual (Aniversário)" : "Mensal (Mesversário)"
            case .english:
                return self == .yearly ? "Yearly (Anniversary)" : "Monthly (Mesiversary)"
            }
        }
        switch lang {
        case .italian:
            switch self {
            case .yearly: return "Ogni Anno"
            case .monthly: return "Ogni Mese"
            case .oneTime: return "Evento Singolo"
            }
        case .spanish:
            switch self {
            case .yearly: return "Cada Año"
            case .monthly: return "Cada Mes"
            case .oneTime: return "Evento Único"
            }
        case .french:
            switch self {
            case .yearly: return "Chaque Année"
            case .monthly: return "Chaque Mois"
            case .oneTime: return "Événement Unique"
            }
        case .german:
            switch self {
            case .yearly: return "Jedes Jahr"
            case .monthly: return "Jeden Monat"
            case .oneTime: return "Einmaliges Event"
            }
        case .portuguese:
            switch self {
            case .yearly: return "A Cada Ano"
            case .monthly: return "A Cada Mês"
            case .oneTime: return "Evento Único"
            }
        case .english:
            switch self {
            case .yearly: return "Every Year"
            case .monthly: return "Every Month"
            case .oneTime: return "One-Time"
            }
        }
    }
}

public enum WishesTone: String, CaseIterable, Identifiable, Codable, Sendable {
    case warm = "warm"
    case formal = "formal"
    case custom = "custom"
    
    public var id: String { rawValue }
    
    public var emoji: String {
        switch self {
        case .warm: return "💖"
        case .formal: return "👔"
        case .custom: return "✍️"
        }
    }
}

extension PersonCategory {
    public func localizedName(for lang: AppLanguage) -> String {
        switch lang {
        case .italian:
            switch self {
            case .family: return "Famiglia"
            case .friends: return "Amici"
            case .work: return "Lavoro"
            case .partner: return "Partner"
            case .other: return "Altro"
            }
        case .spanish:
            switch self {
            case .family: return "Familia"
            case .friends: return "Amigos"
            case .work: return "Trabajo"
            case .partner: return "Pareja"
            case .other: return "Otro"
            }
        case .french:
            switch self {
            case .family: return "Famille"
            case .friends: return "Amis"
            case .work: return "Travail"
            case .partner: return "Partenaire"
            case .other: return "Autre"
            }
        case .german:
            switch self {
            case .family: return "Familie"
            case .friends: return "Freunde"
            case .work: return "Arbeit"
            case .partner: return "Partner"
            case .other: return "Andere"
            }
        case .portuguese:
            switch self {
            case .family: return "Família"
            case .friends: return "Amigos"
            case .work: return "Trabalho"
            case .partner: return "Parceiro"
            case .other: return "Outro"
            }
        case .english:
            switch self {
            case .family: return "Family"
            case .friends: return "Friends"
            case .work: return "Work"
            case .partner: return "Partner"
            case .other: return "Other"
            }
        }
    }
}

extension EventType {
    public func localizedName(for lang: AppLanguage) -> String {
        switch lang {
        case .italian:
            switch self {
            case .birthday: return "Compleanno"
            case .anniversary: return "Anniversario"
            case .nameday: return "Onomastico"
            case .special: return "Speciale"
            }
        case .spanish:
            switch self {
            case .birthday: return "Cumpleaños"
            case .anniversary: return "Aniversario"
            case .nameday: return "Santo"
            case .special: return "Especial"
            }
        case .french:
            switch self {
            case .birthday: return "Anniversaire"
            case .anniversary: return "Mariage / Fête"
            case .nameday: return "Fête prénom"
            case .special: return "Spécial"
            }
        case .german:
            switch self {
            case .birthday: return "Geburtstag"
            case .anniversary: return "Jahrestag"
            case .nameday: return "Namenstag"
            case .special: return "Besonderes"
            }
        case .portuguese:
            switch self {
            case .birthday: return "Aniversário"
            case .anniversary: return "Bodas / Aniversário"
            case .nameday: return "Dia do Nome"
            case .special: return "Especial"
            }
        case .english:
            switch self {
            case .birthday: return "Birthday"
            case .anniversary: return "Anniversary"
            case .nameday: return "Name Day"
            case .special: return "Special Occasion"
            }
        }
    }
}

extension WishesTone {
    public func localizedName(for lang: AppLanguage) -> String {
        switch lang {
        case .italian:
            switch self {
            case .warm: return "Affettuoso"
            case .formal: return "Elegante"
            case .custom: return "Personalizzato"
            }
        case .spanish:
            switch self {
            case .warm: return "Cariñoso"
            case .formal: return "Formal"
            case .custom: return "Personalizado"
            }
        case .french:
            switch self {
            case .warm: return "Chaleureux"
            case .formal: return "Élégant"
            case .custom: return "Personnalisé"
            }
        case .german:
            switch self {
            case .warm: return "Herzlich"
            case .formal: return "Förmlich"
            case .custom: return "Individuell"
            }
        case .portuguese:
            switch self {
            case .warm: return "Carinhoso"
            case .formal: return "Formal"
            case .custom: return "Personalizado"
            }
        case .english:
            switch self {
            case .warm: return "Heartfelt"
            case .formal: return "Polite"
            case .custom: return "Custom"
            }
        }
    }
    
    public func template(
        name: String,
        age: Int?,
        eventType: EventType,
        recurrence: EventRecurrence = .yearly,
        mesiversarioCount: Int? = nil,
        customMessage: String? = nil,
        lang: AppLanguage
    ) -> String {
        if self == .custom {
            if let custom = customMessage?.trimmingCharacters(in: .whitespacesAndNewlines), !custom.isEmpty {
                return custom
            }
            switch lang {
            case .italian: return "Tanti auguri speciali a te, \(name)! ✨"
            case .spanish: return "¡Muchas felicidades y los mejores deseos, \(name)! ✨"
            case .french: return "Tous mes vœux chaleureux pour toi, \(name) ! ✨"
            case .german: return "Die allerbesten Wünsche für dich, \(name)! ✨"
            case .portuguese: return "Muitas felicidades e tudo de bom para você, \(name)! ✨"
            case .english: return "Wishing you all the best and much happiness, \(name)! ✨"
            }
        }
        
        if eventType == .anniversary {
            if recurrence == .monthly {
                if let count = mesiversarioCount, count > 0 {
                    if count % 12 == 0 {
                        let years = count / 12
                        switch lang {
                        case .italian: return "Felice \(years)° anniversario a voi! 🥂💍 Un altro anno d'amore insieme, vi auguro infinita felicità!"
                        case .spanish: return "¡Feliz \(years).º aniversario! 🥂💍 ¡Un año más de amor juntos, les deseo toda la felicidad!"
                        case .french: return "Joyeux \(years == 1 ? "1er" : "\(years)e") anniversaire de mariage ! 🥂💍 Plein d'amour et de bonheur à vous !"
                        case .german: return "Alles Gute zum \(years). Jahrestag! 🥂💍 Auf eure gemeinsame Liebe und Zukunft!"
                        case .portuguese: return "Feliz \(years)º aniversário de casamento! 🥂💍 Mais um ano de união e amor!"
                        case .english:
                            let s = years == 1 ? "st" : (years == 2 ? "nd" : (years == 3 ? "rd" : "th"))
                            return "Happy \(years)\(s) Anniversary! 🥂💍 Celebrating another wonderful year together!"
                        }
                    } else {
                        switch lang {
                        case .italian: return "Buon \(count)° mesiversario a voi! 🥂💖 Che il vostro amore cresca ogni mese di più!"
                        case .spanish: return "¡Feliz \(count).º mesiversario! 🥂💖 ¡Que su amor siga creciendo cada mes!"
                        case .french: return "Joyeux \(count)e mois-versaire ! 🥂💖 Que votre amour grandisse chaque mois !"
                        case .german: return "Alles Gute zum \(count). Monatstag! 🥂💖 Auf viele weitere wundervolle Monate!"
                        case .portuguese: return "Feliz \(count)º mesversário! 🥂💖 Que o amor de vocês cresça a cada mês!"
                        case .english:
                            let s = count == 1 ? "st" : (count == 2 ? "nd" : (count == 3 ? "rd" : "th"))
                            return "Happy \(count)\(s) Mesiversary! 🥂💖 Wishing you endless love and happiness!"
                        }
                    }
                } else {
                    switch lang {
                    case .italian: return "Felice mesiversario a voi! 🥂💖 Vi auguro tanta felicità e amore insieme ogni mese!"
                    case .spanish: return "¡Feliz mesiversario! 🥂💖 ¡Les deseo mucho amor y felicidad juntos cada mes!"
                    case .french: return "Joyeux mois-versaire ! 🥂💖 Plein de bonheur et d'amour à vous chaque mois !"
                    case .german: return "Alles Gute zum Monatstag! 🥂💖 Viel Liebe und Freude auf eurem gemeinsamen Weg!"
                    case .portuguese: return "Feliz mesversário! 🥂💖 Desejo muito amor e cumplicidade todo mês!"
                    case .english: return "Happy Mesiversary! 🥂💖 Wishing you continued love and happiness together!"
                    }
                }
            } else {
                switch lang {
                case .italian: return "Felice anniversario a voi! 🥂💍 Vi auguro tanta felicità e amore insieme!"
                case .spanish: return "¡Feliz aniversario! 🥂💍 ¡Les deseo mucho amor y felicidad juntos!"
                case .french: return "Joyeux anniversaire de mariage ! 🥂💍 Plein de bonheur et d'amour à vous !"
                case .german: return "Alles Gute zum Jahrestag! 🥂💍 Viel Liebe und Freude auf eurem gemeinsamen Weg!"
                case .portuguese: return "Feliz aniversário de casamento! 🥂💍 Desejo muito amor e cumplicidade!"
                case .english: return "Happy Anniversary! 🥂💍 Wishing you continued love and happiness together!"
                }
            }
        } else if eventType == .nameday {
            switch lang {
            case .italian: return "Buon onomastico \(name)! 💐✨ Ti auguro una splendida giornata di festa!"
            case .spanish: return "¡Feliz día de tu santo, \(name)! 💐✨ ¡Que tengas un día maravilloso!"
            case .french: return "Bonne fête \(name) ! 💐✨ Passe une très belle journée !"
            case .german: return "Alles Gute zum Namenstag, \(name)! 💐✨ Einen wundervollen Tag wünsche ich dir!"
            case .portuguese: return "Feliz dia do seu nome, \(name)! 💐✨ Tenha um dia muito especial!"
            case .english: return "Happy Name Day, \(name)! 💐✨ Wishing you a delightful day!"
            }
        } else if eventType == .special {
            switch lang {
            case .italian: return "Buona ricorrenza speciale \(name)! ⭐️✨ Ti auguro una splendida giornata!"
            case .spanish: return "¡Feliz día especial, \(name)! ⭐️✨ ¡Que tengas un día maravilloso!"
            case .french: return "Joyeuse occasion spéciale \(name) ! ⭐️✨ Passe une excellente journée !"
            case .german: return "Alles Gute zu diesem besonderen Anlass, \(name)! ⭐️✨"
            case .portuguese: return "Feliz ocasião especial, \(name)! ⭐️✨ Tenha um dia maravilhoso!"
            case .english: return "Happy special occasion, \(name)! ⭐️✨ Wishing you a delightful day!"
            }
        }
        
        // Birthday message based on selected tone
        switch (self, lang) {
        case (.warm, .italian):
            if let a = age, a > 0 {
                return "Tanti auguri di buon compleanno \(name)! 🎂🎉 Felici \(a) anni, che questo nuovo anno ti porti gioia e serenità!"
            } else {
                return "Tanti carissimi auguri di buon compleanno \(name)! 🎂🎉 Ti auguro una giornata piena di sorrisi e affetto!"
            }
        case (.formal, .italian):
            if let a = age, a > 0 {
                return "I miei più sinceri auguri di buon compleanno per il Suo \(a)° compleanno, \(name). Con stima e cordialità."
            } else {
                return "Desidero rivolgerLe i miei più calorosi auguri di buon compleanno, \(name). I migliori auguri per il futuro."
            }
            
        case (.warm, .spanish):
            return "¡Feliz cumpleaños, \(name)! 🎂🎉 ¡Te deseo un día lleno de amor, risas y momentos inolvidables!"
        case (.formal, .spanish):
            return "Le envío mis más cordiales felicitaciones en el día de su cumpleaños, \(name). Mucho éxito y salud."
            
        case (.warm, .french):
            return "Joyeux anniversaire \(name) ! 🎂🎉 Que cette nouvelle année t'apporte tout le bonheur que tu mérites !"
        case (.formal, .french):
            return "Je vous adresse mes vœux les plus sincères et chaleureux pour votre anniversaire, \(name)."
            
        case (.warm, .german):
            return "Herzlichen Glückwunsch zum Geburtstag, \(name)! 🎂🎉 Möge dein neues Lebensjahr voller Glück sein!"
        case (.formal, .german):
            return "Zu Ihrem Geburtstag wünsche ich Ihnen alles Gute, viel Erfolg und beste Gesundheit, \(name)."
            
        case (.warm, .portuguese):
            return "Feliz aniversário, \(name)! 🎂🎉 Que seu novo ano seja repleto de amor, saúde e realizações!"
        case (.formal, .portuguese):
            return "Desejo a você um feliz aniversário com muita saúde e realizações, \(name). Meus sinceros cumprimentos."
            
        case (.warm, .english):
            if let a = age, a > 0 {
                return "Happy Birthday \(name)! 🎂🎉 Wishing you a wonderful \(a)th birthday filled with joy and love!"
            } else {
                return "Happy Birthday \(name)! 🎂🎉 Wishing you a bright, happy, and memorable year ahead!"
            }
        case (.formal, .english):
            return "Wishing you a very happy birthday and continued success in the year ahead, \(name)."
        default:
            return "Happy Birthday \(name)! 🎂🎉 Wishing you all the best!"
        }
    }
}

public struct GiftItem: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID
    public var title: String
    public var status: GiftStatus
    public var year: Int
    public var month: Int
    public var notes: String
    public var price: Double?
    public var url: String?
    public var isPrivate: Bool
    
    public init(
        id: UUID = UUID(),
        title: String,
        status: GiftStatus = .idea,
        year: Int = Calendar.current.component(.year, from: Date()),
        month: Int = Calendar.current.component(.month, from: Date()),
        notes: String = "",
        price: Double? = nil,
        url: String? = nil,
        isPrivate: Bool = false
    ) {
        self.id = id
        self.title = title
        self.status = status
        self.year = year
        self.month = month
        self.notes = notes
        self.price = price
        self.url = url
        self.isPrivate = isPrivate
    }
    
    public var formattedDate: String {
        if month >= 1 && month <= 12 {
            return String(format: "%02d.%d", month, year)
        } else {
            return "\(year)"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, status, year, month, notes, price, url, isPrivate
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.status = try container.decode(GiftStatus.self, forKey: .status)
        self.year = try container.decodeIfPresent(Int.self, forKey: .year) ?? Calendar.current.component(.year, from: Date())
        self.month = try container.decodeIfPresent(Int.self, forKey: .month) ?? Calendar.current.component(.month, from: Date())
        self.notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        self.price = try container.decodeIfPresent(Double.self, forKey: .price)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
        self.isPrivate = try container.decodeIfPresent(Bool.self, forKey: .isPrivate) ?? false
    }
}

public enum Season: String, CaseIterable, Identifiable, Codable, Sendable {
    case spring
    case summer
    case autumn
    case winter
    
    public var id: String { rawValue }
    
    public var emoji: String {
        switch self {
        case .spring: return "🌸"
        case .summer: return "☀️"
        case .autumn: return "🍂"
        case .winter: return "❄️"
        }
    }
    
    public var accentColor: Color {
        switch self {
        case .spring: return Color(red: 0.22, green: 0.78, blue: 0.45)
        case .summer: return Color(red: 1.0, green: 0.62, blue: 0.05)
        case .autumn: return Color(red: 0.95, green: 0.45, blue: 0.22)
        case .winter: return Color(red: 0.25, green: 0.65, blue: 0.95)
        }
    }
    
    public func localizedName(for lang: AppLanguage) -> String {
        switch lang {
        case .italian:
            switch self {
            case .spring: return "Primavera"
            case .summer: return "Estate"
            case .autumn: return "Autunno"
            case .winter: return "Inverno"
            }
        case .spanish:
            switch self {
            case .spring: return "Primavera"
            case .summer: return "Verano"
            case .autumn: return "Otoño"
            case .winter: return "Invierno"
            }
        case .french:
            switch self {
            case .spring: return "Printemps"
            case .summer: return "Été"
            case .autumn: return "Automne"
            case .winter: return "Hiver"
            }
        case .german:
            switch self {
            case .spring: return "Frühling"
            case .summer: return "Sommer"
            case .autumn: return "Herbst"
            case .winter: return "Winter"
            }
        case .portuguese:
            switch self {
            case .spring: return "Primavera"
            case .summer: return "Verão"
            case .autumn: return "Outono"
            case .winter: return "Inverno"
            }
        case .english:
            switch self {
            case .spring: return "Spring"
            case .summer: return "Summer"
            case .autumn: return "Autumn"
            case .winter: return "Winter"
            }
        }
    }
    
    /// Current calendar season based on date
    public static func current(date: Date = Date(), calendar: Calendar = .current) -> Season {
        let m = calendar.component(.month, from: date)
        let d = calendar.component(.day, from: date)
        switch (m, d) {
        case (3, 21...31), (4, 1...30), (5, 1...31), (6, 1...20):
            return .spring
        case (6, 21...30), (7, 1...31), (8, 1...31), (9, 1...22):
            return .summer
        case (9, 23...30), (10, 1...31), (11, 1...30), (12, 1...20):
            return .autumn
        default:
            return .winter
        }
    }
}

public struct MemoryPhoto: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID
    public var imageData: Data
    public var caption: String
    public var date: Date
    
    public init(id: UUID = UUID(), imageData: Data, caption: String = "", date: Date = Date()) {
        self.id = id
        self.imageData = imageData
        self.caption = caption
        self.date = date
    }
}


public struct CelebrationVenue: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID
    public var name: String
    public var address: String?
    public var latitude: Double?
    public var longitude: Double?
    public var year: Int?
    public var dateTag: String?
    public var notes: String?
    public var dateAdded: Date
    
    enum CodingKeys: String, CodingKey {
        case id, name, address, latitude, longitude, year, dateTag, notes, dateAdded
    }
    
    public init(
        id: UUID = UUID(),
        name: String,
        address: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        year: Int? = nil,
        dateTag: String? = nil,
        notes: String? = nil,
        dateAdded: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.year = year
        self.dateTag = dateTag
        self.notes = notes
        self.dateAdded = dateAdded
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.address = try container.decodeIfPresent(String.self, forKey: .address)
        self.latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        self.longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        self.year = try container.decodeIfPresent(Int.self, forKey: .year)
        self.dateTag = try container.decodeIfPresent(String.self, forKey: .dateTag)
        self.notes = try container.decodeIfPresent(String.self, forKey: .notes)
        self.dateAdded = try container.decodeIfPresent(Date.self, forKey: .dateAdded) ?? Date()
    }
    
    public static func currentDateTag() -> String {
        let df = DateFormatter()
        df.dateFormat = "MM.yyyy"
        return df.string(from: Date())
    }
    
    public var formattedDateTag: String? {
        if let tag = dateTag?.trimmingCharacters(in: .whitespacesAndNewlines), !tag.isEmpty {
            return tag
        }
        if let y = year {
            return "\(y)"
        }
        return nil
    }
    
    public var displayName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { return trimmed }
        if let addr = address?.trimmingCharacters(in: .whitespacesAndNewlines), !addr.isEmpty {
            return addr
        }
        return "Location"
    }
}

public struct BirthdayPerson: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID
    public var name: String
    public var birthDay: Int
    public var birthMonth: Int
    public var birthYear: Int?
    public var notes: String
    public var notifyOnSameDay: Bool
    public var notifyInAdvance: Bool
    public var advanceDays: Int
    public var colorIndex: Int
    public var avatarImageData: Data?
    public var gifts: [GiftItem]
    public var linkedContactId: String?
    public var category: PersonCategory
    public var eventType: EventType
    public var recurrence: EventRecurrence
    public var customWishMessage: String?
    public var lastWishToneSent: WishesTone?
    public var isPrivate: Bool
    public var celebrationLocation: String?
    public var celebrationVenues: [CelebrationVenue]
    public var memoryPhotos: [MemoryPhoto]
    public var customCategory: String?
    
    public var categoryId: String {
        if let custom = customCategory?.trimmingCharacters(in: .whitespacesAndNewlines), !custom.isEmpty {
            return custom
        }
        return category.rawValue
    }
    
    public func categoryDisplayName(for lang: AppLanguage) -> String {
        if let custom = customCategory?.trimmingCharacters(in: .whitespacesAndNewlines), !custom.isEmpty {
            return custom
        }
        return category.localizedName(for: lang)
    }
    
    public var categoryEmoji: String {
        if let custom = customCategory?.trimmingCharacters(in: .whitespacesAndNewlines), !custom.isEmpty {
            return "🏷️"
        }
        return category.emoji
    }
    
    public var allVenues: [CelebrationVenue] {
        if !celebrationVenues.isEmpty {
            return celebrationVenues
        }
        if let loc = celebrationLocation?.trimmingCharacters(in: .whitespacesAndNewlines), !loc.isEmpty {
            return [CelebrationVenue(name: loc)]
        }
        return []
    }
    
    public var hasCelebrationLocation: Bool {
        if !celebrationVenues.isEmpty { return true }
        if let loc = celebrationLocation?.trimmingCharacters(in: .whitespacesAndNewlines), !loc.isEmpty {
            return true
        }
        return false
    }
    
    public init(
        id: UUID = UUID(),
        name: String,
        birthDay: Int,
        birthMonth: Int,
        birthYear: Int? = nil,
        notes: String = "",
        notifyOnSameDay: Bool = true,
        notifyInAdvance: Bool = true,
        advanceDays: Int = 3,
        colorIndex: Int = 0,
        avatarImageData: Data? = nil,
        gifts: [GiftItem] = [],
        linkedContactId: String? = nil,
        category: PersonCategory = .friends,
        eventType: EventType = .birthday,
        recurrence: EventRecurrence = .yearly,
        customWishMessage: String? = nil,
        lastWishToneSent: WishesTone? = nil,
        isPrivate: Bool = false,
        celebrationLocation: String? = nil,
        celebrationVenues: [CelebrationVenue] = [],
        memoryPhotos: [MemoryPhoto] = [],
        customCategory: String? = nil
    ) {
        self.id = id
        self.name = name
        self.birthDay = birthDay
        self.birthMonth = birthMonth
        self.birthYear = birthYear
        self.notes = notes
        self.notifyOnSameDay = notifyOnSameDay
        self.notifyInAdvance = notifyInAdvance
        self.advanceDays = advanceDays
        self.colorIndex = colorIndex
        self.avatarImageData = avatarImageData
        self.gifts = gifts
        self.linkedContactId = linkedContactId
        self.category = category
        self.customCategory = customCategory
        self.eventType = eventType
        self.recurrence = recurrence
        self.customWishMessage = customWishMessage
        self.lastWishToneSent = lastWishToneSent
        self.isPrivate = isPrivate
        self.celebrationLocation = celebrationLocation
        var venues = celebrationVenues
        if venues.isEmpty, let loc = celebrationLocation, !loc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            venues.append(CelebrationVenue(name: loc))
        }
        self.celebrationVenues = venues
        self.memoryPhotos = memoryPhotos
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, birthDay, birthMonth, birthYear, notes
        case notifyOnSameDay, notifyInAdvance, advanceDays, colorIndex
        case avatarImageData, gifts, linkedContactId, category, eventType, recurrence
        case customWishMessage, lastWishToneSent
        case isPrivate, celebrationLocation, celebrationVenues, memoryPhotos
        case customCategory
    }
    
    private enum LegacyKeys: String, CodingKey {
        case celebrationLatitude, celebrationLongitude
        case memoryImageData, memoryCaption, memoryDate, tags
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.birthDay = try container.decode(Int.self, forKey: .birthDay)
        self.birthMonth = try container.decode(Int.self, forKey: .birthMonth)
        self.birthYear = try container.decodeIfPresent(Int.self, forKey: .birthYear)
        self.notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        self.notifyOnSameDay = try container.decodeIfPresent(Bool.self, forKey: .notifyOnSameDay) ?? true
        self.notifyInAdvance = try container.decodeIfPresent(Bool.self, forKey: .notifyInAdvance) ?? true
        self.advanceDays = try container.decodeIfPresent(Int.self, forKey: .advanceDays) ?? 3
        self.colorIndex = try container.decodeIfPresent(Int.self, forKey: .colorIndex) ?? 0
        self.avatarImageData = try container.decodeIfPresent(Data.self, forKey: .avatarImageData)
        self.gifts = try container.decodeIfPresent([GiftItem].self, forKey: .gifts) ?? []
        self.linkedContactId = try container.decodeIfPresent(String.self, forKey: .linkedContactId)
        self.category = try container.decodeIfPresent(PersonCategory.self, forKey: .category) ?? .friends
        self.customCategory = try container.decodeIfPresent(String.self, forKey: .customCategory)
        self.eventType = try container.decodeIfPresent(EventType.self, forKey: .eventType) ?? .birthday
        self.recurrence = try container.decodeIfPresent(EventRecurrence.self, forKey: .recurrence) ?? .yearly
        self.customWishMessage = try container.decodeIfPresent(String.self, forKey: .customWishMessage)
        self.lastWishToneSent = try container.decodeIfPresent(WishesTone.self, forKey: .lastWishToneSent)
        self.isPrivate = try container.decodeIfPresent(Bool.self, forKey: .isPrivate) ?? false
        
        var venues = (try? container.decodeIfPresent([CelebrationVenue].self, forKey: .celebrationVenues)) ?? []
        let legacyLoc = try container.decodeIfPresent(String.self, forKey: .celebrationLocation)
        let legacyContainer = try? decoder.container(keyedBy: LegacyKeys.self)
        let legacyLat = try? legacyContainer?.decodeIfPresent(Double.self, forKey: .celebrationLatitude)
        let legacyLon = try? legacyContainer?.decodeIfPresent(Double.self, forKey: .celebrationLongitude)
        if venues.isEmpty, let loc = legacyLoc, !loc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            venues.append(CelebrationVenue(name: loc, latitude: legacyLat, longitude: legacyLon))
        }
        self.celebrationVenues = venues
        self.celebrationLocation = legacyLoc ?? venues.first?.displayName
        
        var decodedPhotos = (try? container.decodeIfPresent([MemoryPhoto].self, forKey: .memoryPhotos)) ?? []
        if decodedPhotos.isEmpty {
            if let legacyData = try? legacyContainer?.decodeIfPresent(Data.self, forKey: .memoryImageData) {
                let legacyCaption = (try? legacyContainer?.decodeIfPresent(String.self, forKey: .memoryCaption)) ?? ""
                let legacyDate = (try? legacyContainer?.decodeIfPresent(Date.self, forKey: .memoryDate)) ?? Date()
                decodedPhotos.append(MemoryPhoto(imageData: legacyData, caption: legacyCaption, date: legacyDate))
            }
        }
        self.memoryPhotos = decodedPhotos
    }
    
    /// Season of the year when the celebration occurs
    public var season: Season {
        switch (birthMonth, birthDay) {
        case (3, 21...31), (4, 1...30), (5, 1...31), (6, 1...20):
            return .spring
        case (6, 21...30), (7, 1...31), (8, 1...31), (9, 1...22):
            return .summer
        case (9, 23...30), (10, 1...31), (11, 1...30), (12, 1...20):
            return .autumn
        default:
            return .winter
        }
    }
    
    // MARK: - Date Calculations
    
    /// True if the event is a one-shot special occasion
    public var isOneShot: Bool {
        recurrence == .oneTime
    }
    
    /// Returns true if this one-shot event has already reached and passed its date (so it should no longer appear in the future)
    public func isOneShotExpired(relativeTo referenceDate: Date = Date(), calendar: Calendar = .current) -> Bool {
        guard recurrence == .oneTime else { return false }
        let currentYear = calendar.component(.year, from: referenceDate)
        let targetYear = birthYear ?? currentYear
        var comp = DateComponents()
        comp.year = targetYear
        comp.month = birthMonth
        comp.day = birthDay
        guard let targetDate = calendar.date(from: comp) else { return false }
        let startOfTarget = calendar.startOfDay(for: targetDate)
        let startOfToday = calendar.startOfDay(for: referenceDate)
        // If today is strictly after the target day, it is expired!
        return startOfToday > startOfTarget
    }
    
    public var isOneShotExpired: Bool {
        isOneShotExpired()
    }
    
    /// Calculates the next occurrence date of the celebration relative to a reference date (default: today)
    public func nextBirthdayDate(relativeTo referenceDate: Date = Date(), calendar: Calendar = .current) -> Date {
        let startOfToday = calendar.startOfDay(for: referenceDate)
        
        // EDGE CASE: If event has a start year in the future, first recurrence is the start date itself
        if let startYear = birthYear {
            var startComp = DateComponents()
            startComp.year = startYear
            startComp.month = birthMonth
            startComp.day = birthDay
            if let startDate = calendar.date(from: startComp),
               calendar.startOfDay(for: startDate) > startOfToday {
                return startDate
            }
        }
        
        if recurrence == .oneTime {
            let currentYear = calendar.component(.year, from: referenceDate)
            let targetYear = birthYear ?? currentYear
            var comp = DateComponents()
            comp.year = targetYear
            comp.month = birthMonth
            let base = calendar.date(from: comp) ?? referenceDate
            let daysInMonth = calendar.range(of: .day, in: .month, for: base)?.count ?? 30
            comp.day = min(birthDay, daysInMonth)
            let targetDate = calendar.date(from: comp) ?? referenceDate
            return targetDate
        }
        
        if recurrence == .monthly {
            let currentYear = calendar.component(.year, from: referenceDate)
            let currentMonth = calendar.component(.month, from: referenceDate)
            
            var components = DateComponents()
            components.year = currentYear
            components.month = currentMonth
            
            // EDGE CASE: Clamping valid days in the current month (e.g. 31st in a 30-day month or Feb 29)
            let baseThisMonth = calendar.date(from: components) ?? referenceDate
            let daysInThisMonth = calendar.range(of: .day, in: .month, for: baseThisMonth)?.count ?? 30
            components.day = min(birthDay, daysInThisMonth)
            
            if let targetThisMonth = calendar.date(from: components),
               calendar.startOfDay(for: targetThisMonth) >= startOfToday {
                return targetThisMonth
            } else {
                // Already passed this month: take the same day in the next month
                var nextMonthComp = DateComponents()
                nextMonthComp.month = 1
                if let nextMonthDate = calendar.date(byAdding: nextMonthComp, to: referenceDate) {
                    var nextComp = DateComponents()
                    nextComp.year = calendar.component(.year, from: nextMonthDate)
                    nextComp.month = calendar.component(.month, from: nextMonthDate)
                    let daysInNextMonth = calendar.range(of: .day, in: .month, for: nextMonthDate)?.count ?? 30
                    nextComp.day = min(birthDay, daysInNextMonth)
                    return calendar.date(from: nextComp) ?? calendar.date(byAdding: .day, value: 30, to: referenceDate) ?? referenceDate
                }
            }
        }
        
        let currentYear = calendar.component(.year, from: referenceDate)
        
        var components = DateComponents()
        components.year = currentYear
        components.month = birthMonth
        
        // EDGE CASE: Clamping valid days (e.g. Feb 29 on non-leap years falls on Feb 28)
        let baseThisYear = calendar.date(from: components) ?? referenceDate
        let daysThisYear = calendar.range(of: .day, in: .month, for: baseThisYear)?.count ?? 30
        components.day = min(birthDay, daysThisYear)
        
        let targetThisYear = calendar.date(from: components) ?? referenceDate
        let startOfTarget = calendar.startOfDay(for: targetThisYear)
        
        if startOfTarget >= startOfToday {
            return targetThisYear
        } else {
            // Already passed this year: next occurrence is next year
            components.year = currentYear + 1
            let baseNextYear = calendar.date(from: components) ?? referenceDate
            let daysNextYear = calendar.range(of: .day, in: .month, for: baseNextYear)?.count ?? 30
            components.day = min(birthDay, daysNextYear)
            return calendar.date(from: components) ?? referenceDate
        }
    }
    
    /// Days remaining until the next celebration date
    public func daysRemaining(relativeTo referenceDate: Date = Date(), calendar: Calendar = .current) -> Int {
        if isOneShotExpired(relativeTo: referenceDate, calendar: calendar) {
            return Int.max
        }
        let nextDate = nextBirthdayDate(relativeTo: referenceDate, calendar: calendar)
        let startOfToday = calendar.startOfDay(for: referenceDate)
        let startOfNext = calendar.startOfDay(for: nextDate)
        
        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfNext)
        return max(0, components.day ?? 0)
    }
    
    public var isToday: Bool {
        guard !isOneShotExpired else { return false }
        return daysRemaining() == 0
    }
    
    public var isTomorrow: Bool {
        guard !isOneShotExpired else { return false }
        return daysRemaining() == 1
    }
    
    /// Mesiversary count number (e.g. 1, 2, 6, 12...) if anniversary is recurring monthly
    public func upcomingMesiversarioNumber(relativeTo referenceDate: Date = Date(), calendar: Calendar = .current) -> Int? {
        guard eventType == .anniversary, recurrence == .monthly, let birthYear = birthYear else { return nil }
        let nextDate = nextBirthdayDate(relativeTo: referenceDate, calendar: calendar)
        let nextYear = calendar.component(.year, from: nextDate)
        let nextMonth = calendar.component(.month, from: nextDate)
        let months = (nextYear - birthYear) * 12 + (nextMonth - birthMonth)
        return months > 0 ? months : nil
    }
    
    public enum AnniversaryMilestone: Equatable, Sendable {
        case anniversary(years: Int)
        case mesiversario(months: Int)
        case genericMesiversario
    }
    
    /// Total count of months spent together from the start date until reference date
    public func monthsPassedTogether(relativeTo referenceDate: Date = Date(), calendar: Calendar = .current) -> Int? {
        guard let birthYear = birthYear else { return nil }
        var startComp = DateComponents()
        startComp.year = birthYear
        startComp.month = birthMonth
        startComp.day = birthDay
        guard let startDate = calendar.date(from: startComp) else { return nil }
        
        let startDay = calendar.startOfDay(for: startDate)
        let refDay = calendar.startOfDay(for: referenceDate)
        guard refDay >= startDay else { return 0 }
        
        let diff = calendar.dateComponents([.month], from: startDay, to: refDay)
        return max(0, diff.month ?? 0)
    }
    
    /// Localized string for count of months spent together (e.g. "28 months", "1 month")
    public func localizedMonthsTogether(for lang: AppLanguage = .english, relativeTo referenceDate: Date = Date(), calendar: Calendar = .current) -> String? {
        guard let months = monthsPassedTogether(relativeTo: referenceDate, calendar: calendar) else { return nil }
        let code = lang.resolvedCode
        if months == 0 {
            switch code {
            case "it": return "< 1 mese"
            case "es": return "< 1 mes"
            case "fr": return "< 1 mois"
            case "de": return "< 1 Monat"
            case "pt": return "< 1 mês"
            default: return "< 1 month"
            }
        } else if months == 1 {
            switch code {
            case "it": return "1 mese"
            case "es": return "1 mes"
            case "fr": return "1 mois"
            case "de": return "1 Monat"
            case "pt": return "1 mês"
            default: return "1 month"
            }
        } else {
            switch code {
            case "it": return "\(months) mesi"
            case "es": return "\(months) meses"
            case "fr": return "\(months) mois"
            case "de": return "\(months) Monate"
            case "pt": return "\(months) meses"
            default: return "\(months) months"
            }
        }
    }
    
    /// Next annual anniversary date
    public func nextYearlyAnniversaryDate(relativeTo referenceDate: Date = Date(), calendar: Calendar = .current) -> Date {
        let startOfToday = calendar.startOfDay(for: referenceDate)
        let currentYear = calendar.component(.year, from: referenceDate)
        
        var comp = DateComponents()
        comp.year = currentYear
        comp.month = birthMonth
        
        let baseDate = calendar.date(from: comp) ?? referenceDate
        let maxDays = calendar.range(of: .day, in: .month, for: baseDate)?.count ?? 30
        comp.day = min(birthDay, maxDays)
        
        let targetThisYear = calendar.date(from: comp) ?? referenceDate
        if calendar.startOfDay(for: targetThisYear) >= startOfToday {
            return targetThisYear
        } else {
            comp.year = currentYear + 1
            let nextYearDate = calendar.date(from: comp) ?? referenceDate
            let maxDaysNext = calendar.range(of: .day, in: .month, for: nextYearDate)?.count ?? 30
            comp.day = min(birthDay, maxDaysNext)
            return calendar.date(from: comp) ?? referenceDate
        }
    }
    
    /// Anniversary count in years
    public func anniversaryNumber(relativeTo referenceDate: Date = Date(), calendar: Calendar = .current) -> Int? {
        guard let birthYear = birthYear else { return nil }
        let nextYearlyDate = nextYearlyAnniversaryDate(relativeTo: referenceDate, calendar: calendar)
        let nextYear = calendar.component(.year, from: nextYearlyDate)
        let years = nextYear - birthYear
        return max(1, years)
    }
    
    /// Localized anniversary ordinal (e.g. "1st", "2nd")
    public func localizedAnniversaryNumber(for lang: AppLanguage = .english, relativeTo referenceDate: Date = Date(), calendar: Calendar = .current) -> String? {
        guard let num = anniversaryNumber(relativeTo: referenceDate, calendar: calendar) else { return nil }
        switch lang.resolvedCode {
        case "it": return "\(num)°"
        case "es": return "\(num).º"
        case "fr": return num == 1 ? "1er" : "\(num)e"
        case "de": return "\(num)."
        case "pt": return "\(num)º"
        default:
            let s = (num % 10 == 1 && num % 100 != 11) ? "st" :
                    (num % 10 == 2 && num % 100 != 12) ? "nd" :
                    (num % 10 == 3 && num % 100 != 13) ? "rd" : "th"
            return "\(num)\(s)"
        }
    }
    
    /// Determines whether the next milestone is an Anniversary or a Mesiversary
    public func upcomingMilestone(relativeTo referenceDate: Date = Date(), calendar: Calendar = .current) -> AnniversaryMilestone? {
        guard eventType == .anniversary else { return nil }
        if recurrence == .monthly {
            if let months = upcomingMesiversarioNumber(relativeTo: referenceDate, calendar: calendar) {
                if months > 0 && months % 12 == 0 {
                    return .anniversary(years: months / 12)
                } else {
                    return .mesiversario(months: months)
                }
            }
            return .genericMesiversario
        } else {
            if let years = anniversaryNumber(relativeTo: referenceDate, calendar: calendar) {
                return .anniversary(years: years)
            }
            return nil
        }
    }
    
    /// Localized milestone title (e.g. "1st Anniversary" or "8th Mesiversary")
    public func localizedMilestoneTitle(for lang: AppLanguage = .english) -> String? {
        guard let milestone = upcomingMilestone() else { return nil }
        switch milestone {
        case .anniversary(let years):
            switch lang.resolvedCode {
            case "it": return "\(years)° Anniversario"
            case "es": return "\(years).º Aniversario"
            case "fr": return "\(years == 1 ? "1er" : "\(years)e") Anniversaire"
            case "de": return "\(years). Jahrestag"
            case "pt": return "\(years)º Aniversário"
            default:
                let s = years == 1 ? "st" : (years == 2 ? "nd" : (years == 3 ? "rd" : "th"))
                return "\(years)\(s) Anniversary"
            }
        case .mesiversario(let months):
            switch lang.resolvedCode {
            case "it": return "\(months)° Mesiversario"
            case "es": return "\(months).º Mesiversario"
            case "fr": return "\(months)e Mois-versaire"
            case "de": return "\(months). Monatstag"
            case "pt": return "\(months)º Mesversário"
            default:
                let s = months == 1 ? "st" : (months == 2 ? "nd" : (months == 3 ? "rd" : "th"))
                return "\(months)\(s) Mesiversary"
            }
        case .genericMesiversario:
            switch lang.resolvedCode {
            case "it": return "Mesiversario"
            case "es": return "Mesiversario"
            case "fr": return "Mois-versaire"
            case "de": return "Monatstag"
            case "pt": return "Mesversário"
            default: return "Mesiversary"
            }
        }
    }
    
    /// Display name of the celebration type for badges and lists
    public func displayEventTypeName(for lang: AppLanguage = .english) -> String {
        if eventType == .anniversary && recurrence == .monthly {
            return localizedMilestoneTitle(for: lang) ?? eventType.localizedName(for: lang)
        }
        return eventType.localizedName(for: lang)
    }
    
    /// Age the person will turn on their upcoming birthday
    public func upcomingAge(relativeTo referenceDate: Date = Date(), calendar: Calendar = .current) -> Int? {
        guard recurrence != .monthly else { return nil }
        guard let birthYear = birthYear else { return nil }
        let nextDate = nextBirthdayDate(relativeTo: referenceDate, calendar: calendar)
        let nextYear = calendar.component(.year, from: nextDate)
        return nextYear - birthYear
    }
    
    /// Current calculated age
    public func currentAge(relativeTo referenceDate: Date = Date(), calendar: Calendar = .current) -> Int? {
        guard recurrence != .monthly else { return nil }
        guard let birthYear = birthYear else { return nil }
        let currentYear = calendar.component(.year, from: referenceDate)
        let hasPassedThisYear = nextBirthdayDate(relativeTo: referenceDate, calendar: calendar) > referenceDate && !isToday
        if isToday {
            return currentYear - birthYear
        }
        return hasPassedThisYear ? (currentYear - birthYear - 1) : (currentYear - birthYear)
    }
    
    /// Name of the weekday for the upcoming event (e.g. "Sunday", "Friday")
    public func upcomingWeekday(for lang: AppLanguage = .english, relativeTo referenceDate: Date = Date(), calendar: Calendar = .current) -> String {
        let nextDate = nextBirthdayDate(relativeTo: referenceDate, calendar: calendar)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: lang.resolvedCode)
        formatter.dateFormat = "EEEE"
        return formatter.string(from: nextDate).capitalized
    }
    
    /// Localized zodiac sign across supported languages
    public func zodiacSign(for lang: AppLanguage = .english) -> (symbol: String, name: String) {
        let code = lang.resolvedCode
        switch (birthMonth, birthDay) {
        case (3, 21...31), (4, 1...19):
            let name = switch code {
            case "it": "Ariete"
            case "es": "Aries"
            case "fr": "Bélier"
            case "de": "Widder"
            case "pt": "Áries"
            default: "Aries"
            }
            return ("♈", name)
        case (4, 20...30), (5, 1...20):
            let name = switch code {
            case "it": "Toro"
            case "es": "Tauro"
            case "fr": "Taureau"
            case "de": "Stier"
            case "pt": "Touro"
            default: "Taurus"
            }
            return ("♉", name)
        case (5, 21...31), (6, 1...20):
            let name = switch code {
            case "it": "Gemelli"
            case "es": "Géminis"
            case "fr": "Gémeaux"
            case "de": "Zwillinge"
            case "pt": "Gêmeos"
            default: "Gemini"
            }
            return ("♊", name)
        case (6, 21...30), (7, 1...22):
            let name = switch code {
            case "it": "Cancro"
            case "es": "Cáncer"
            case "fr": "Cancer"
            case "de": "Krebs"
            case "pt": "Câncer"
            default: "Cancer"
            }
            return ("♋", name)
        case (7, 23...31), (8, 1...22):
            let name = switch code {
            case "it": "Leone"
            case "es": "Leo"
            case "fr": "Lion"
            case "de": "Löwe"
            case "pt": "Leão"
            default: "Leo"
            }
            return ("♌", name)
        case (8, 23...31), (9, 1...22):
            let name = switch code {
            case "it": "Vergine"
            case "es": "Virgo"
            case "fr": "Vierge"
            case "de": "Jungfrau"
            case "pt": "Virgem"
            default: "Virgo"
            }
            return ("♍", name)
        case (9, 23...30), (10, 1...22):
            let name = switch code {
            case "it": "Bilancia"
            case "es": "Libra"
            case "fr": "Balance"
            case "de": "Waage"
            case "pt": "Libra"
            default: "Libra"
            }
            return ("♎", name)
        case (10, 23...31), (11, 1...21):
            let name = switch code {
            case "it": "Scorpione"
            case "es": "Escorpio"
            case "fr": "Scorpion"
            case "de": "Skorpion"
            case "pt": "Escorpião"
            default: "Scorpio"
            }
            return ("♏", name)
        case (11, 22...30), (12, 1...21):
            let name = switch code {
            case "it": "Sagittario"
            case "es": "Sagitario"
            case "fr": "Sagittaire"
            case "de": "Schütze"
            case "pt": "Sagitário"
            default: "Sagittarius"
            }
            return ("♐", name)
        case (12, 22...31), (1, 1...19):
            let name = switch code {
            case "it": "Capricorno"
            case "es": "Capricornio"
            case "fr": "Capricorne"
            case "de": "Steinbock"
            case "pt": "Capricórnio"
            default: "Capricorn"
            }
            return ("♑", name)
        case (1, 20...31), (2, 1...18):
            let name = switch code {
            case "it": "Acquario"
            case "es": "Acuario"
            case "fr": "Verseau"
            case "de": "Wassermann"
            case "pt": "Aquário"
            default: "Aquarius"
            }
            return ("♒", name)
        case (2, 19...29), (3, 1...20):
            let name = switch code {
            case "it": "Pesci"
            case "es": "Piscis"
            case "fr": "Poissons"
            case "de": "Fische"
            case "pt": "Peixes"
            default: "Pisces"
            }
            return ("♓", name)
        default:
            return ("✨", "Unknown")
        }
    }
    
    /// Chinese Zodiac sign based on birth year
    public func chineseZodiac(for lang: AppLanguage = .english) -> (emoji: String, name: String)? {
        guard let year = birthYear else { return nil }
        let animals: [(emoji: String, en: String, it: String, es: String, fr: String, de: String, pt: String)] = [
            ("🐀", "Rat", "Topo", "Rata", "Rat", "Ratte", "Rato"),
            ("🐂", "Ox", "Bue", "Buey", "Bœuf", "Büffel", "Boi"),
            ("🐅", "Tiger", "Tigre", "Tigre", "Tigre", "Tiger", "Tigre"),
            ("🐇", "Rabbit", "Coniglio", "Conejo", "Lapin", "Hase", "Coelho"),
            ("🐉", "Dragon", "Drago", "Dragón", "Dragon", "Drache", "Dragão"),
            ("🐍", "Snake", "Serpente", "Serpiente", "Serpent", "Schlange", "Serpente"),
            ("🐎", "Horse", "Cavallo", "Caballo", "Cheval", "Pferd", "Cavalo"),
            ("🐐", "Goat", "Capra", "Cabra", "Chèvre", "Ziege", "Cabra"),
            ("🐒", "Monkey", "Scimmia", "Mono", "Singe", "Affe", "Macaco"),
            ("🐓", "Rooster", "Gallo", "Gallo", "Coq", "Hahn", "Galo"),
            ("🐕", "Dog", "Cane", "Perro", "Chien", "Hund", "Cão"),
            ("🐖", "Pig", "Maiale", "Cerdo", "Cochon", "Schwein", "Porco")
        ]
        let index = ((year - 4) % 12 + 12) % 12
        let item = animals[index]
        let name: String
        switch lang.resolvedCode {
        case "it": name = item.it
        case "es": name = item.es
        case "fr": name = item.fr
        case "de": name = item.de
        case "pt": name = item.pt
        default: name = item.en
        }
        return (item.emoji, name)
    }
    
    /// Localized name of the month
    public func monthName(for lang: AppLanguage = .english) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: lang.resolvedCode)
        return formatter.monthSymbols[max(0, min(11, birthMonth - 1))].capitalized
    }
    
    /// Human-readable formatted date (e.g. "May 14, 1996" or "14 May 1996")
    public func formattedBirthday(for lang: AppLanguage = .english) -> String {
        let isLatin = lang.resolvedCode == "it" || lang.resolvedCode == "es" || lang.resolvedCode == "fr" || lang.resolvedCode == "pt" || lang.resolvedCode == "de"
        let mName = monthName(for: lang)
        if let birthYear = birthYear {
            return isLatin ? "\(birthDay) \(mName) \(birthYear)" : "\(mName) \(birthDay), \(birthYear)"
        } else {
            return isLatin ? "\(birthDay) \(mName)" : "\(mName) \(birthDay)"
        }
    }
    
    /// Formatted date showing only day number and month without year (e.g. "14 Maggio" or "May 14")
    public func formattedDayAndMonth(for lang: AppLanguage = .english) -> String {
        let isLatin = lang.resolvedCode == "it" || lang.resolvedCode == "es" || lang.resolvedCode == "fr" || lang.resolvedCode == "pt" || lang.resolvedCode == "de"
        let mName = monthName(for: lang)
        return isLatin ? "\(birthDay) \(mName)" : "\(mName) \(birthDay)"
    }
    
    /// Initials of the person's name (up to 2 characters)
    public var initials: String {
        let parts = name.split(separator: " ").prefix(2)
        let inits = parts.compactMap { $0.first }.map { String($0).uppercased() }
        return inits.isEmpty ? "" : inits.joined()
    }
    
    /// Birthstone of the birth month
    public func birthstone(for lang: AppLanguage = .english) -> BirthstoneInfo {
        BirthstoneInfo.forMonth(birthMonth, lang: lang)
    }
    
    /// Historical trivia and notable people sharing the same date
    public func dayTrivia(for lang: AppLanguage = .english) -> DayTrivia {
        DayTrivia.forDate(month: birthMonth, day: birthDay, lang: lang)
    }
}

public enum AstrologicalElement: String, CaseIterable, Identifiable, Sendable {
    case fire = "fire"
    case earth = "earth"
    case air = "air"
    case water = "water"
    
    public var id: String { rawValue }
    
    public var emoji: String {
        switch self {
        case .fire: return "🔥"
        case .earth: return "🌍"
        case .air: return "💨"
        case .water: return "💧"
        }
    }
    
    public var accentColor: Color {
        switch self {
        case .fire: return Color.orange
        case .earth: return Color(red: 0.35, green: 0.72, blue: 0.38)
        case .air: return Color(red: 0.35, green: 0.65, blue: 0.95)
        case .water: return Color(red: 0.45, green: 0.45, blue: 0.95)
        }
    }
    
    public func localizedName(for lang: AppLanguage) -> String {
        switch self {
        case .fire:
            switch lang {
            case .italian: return "Fuoco"
            case .spanish, .portuguese: return "Fuego"
            case .french: return "Feu"
            case .german: return "Feuer"
            case .english: return "Fire"
            }
        case .earth:
            switch lang {
            case .italian, .portuguese: return "Terra"
            case .spanish: return "Tierra"
            case .french: return "Terre"
            case .german: return "Erde"
            case .english: return "Earth"
            }
        case .air:
            switch lang {
            case .italian: return "Aria"
            case .spanish, .french, .portuguese: return "Air"
            case .german: return "Luft"
            case .english: return "Air"
            }
        case .water:
            switch lang {
            case .italian: return "Acqua"
            case .spanish: return "Agua"
            case .french: return "Eau"
            case .german: return "Wasser"
            case .portuguese: return "Água"
            case .english: return "Water"
            }
        }
    }
}

public struct ZodiacSignInfo: Identifiable, Sendable {
    public var id: String { symbol }
    public let symbol: String
    public let englishName: String
    public let element: AstrologicalElement
    public let dateRange: String
    
    public func localizedName(for lang: AppLanguage) -> String {
        switch symbol {
        case "♈": return lang == .italian ? "Ariete" : (lang == .spanish || lang == .portuguese ? "Aries" : (lang == .french ? "Bélier" : (lang == .german ? "Widder" : "Aries")))
        case "♉": return lang == .italian ? "Toro" : (lang == .spanish ? "Tauro" : (lang == .french ? "Taureau" : (lang == .german ? "Stier" : (lang == .portuguese ? "Touro" : "Taurus"))))
        case "♊": return lang == .italian ? "Gemelli" : (lang == .spanish ? "Géminis" : (lang == .french ? "Gémeaux" : (lang == .german ? "Zwillinge" : (lang == .portuguese ? "Gêmeos" : "Gemini"))))
        case "♋": return lang == .italian ? "Cancro" : (lang == .spanish || lang == .portuguese ? "Cáncer" : (lang == .french ? "Cancer" : (lang == .german ? "Krebs" : "Cancer")))
        case "♌": return lang == .italian ? "Leone" : (lang == .spanish ? "Leo" : (lang == .french ? "Lion" : (lang == .german ? "Löwe" : (lang == .portuguese ? "Leão" : "Leo"))))
        case "♍": return lang == .italian ? "Vergine" : (lang == .spanish ? "Virgo" : (lang == .french ? "Vierge" : (lang == .german ? "Jungfrau" : (lang == .portuguese ? "Virgem" : "Virgo"))))
        case "♎": return lang == .italian ? "Bilancia" : (lang == .spanish || lang == .portuguese ? "Libra" : (lang == .french ? "Balance" : (lang == .german ? "Waage" : "Libra")))
        case "♏": return lang == .italian ? "Scorpione" : (lang == .spanish ? "Escorpio" : (lang == .french ? "Scorpion" : (lang == .german ? "Skorpion" : (lang == .portuguese ? "Escorpião" : "Scorpio"))))
        case "♐": return lang == .italian ? "Sagittario" : (lang == .spanish ? "Sagitario" : (lang == .french ? "Sagittaire" : (lang == .german ? "Schütze" : (lang == .portuguese ? "Sagitário" : "Sagittarius"))))
        case "♑": return lang == .italian ? "Capricorno" : (lang == .spanish ? "Capricornio" : (lang == .french ? "Capricorne" : (lang == .german ? "Steinbock" : (lang == .portuguese ? "Capricórnio" : "Capricorn"))))
        case "♒": return lang == .italian ? "Acquario" : (lang == .spanish ? "Acuario" : (lang == .french ? "Verseau" : (lang == .german ? "Wassermann" : (lang == .portuguese ? "Aquário" : "Aquarius"))))
        case "♓": return lang == .italian ? "Pesci" : (lang == .spanish ? "Piscis" : (lang == .french ? "Poissons" : (lang == .german ? "Fische" : (lang == .portuguese ? "Peixes" : "Pisces"))))
        default: return englishName
        }
    }
    
    public static let allSigns: [ZodiacSignInfo] = [
        // Fire
        ZodiacSignInfo(symbol: "♈", englishName: "Aries", element: .fire, dateRange: "21 Mar - 19 Apr"),
        ZodiacSignInfo(symbol: "♌", englishName: "Leo", element: .fire, dateRange: "23 Jul - 22 Aug"),
        ZodiacSignInfo(symbol: "♐", englishName: "Sagittarius", element: .fire, dateRange: "22 Nov - 21 Dec"),
        // Earth
        ZodiacSignInfo(symbol: "♉", englishName: "Taurus", element: .earth, dateRange: "20 Apr - 20 May"),
        ZodiacSignInfo(symbol: "♍", englishName: "Virgo", element: .earth, dateRange: "23 Aug - 22 Sep"),
        ZodiacSignInfo(symbol: "♑", englishName: "Capricorn", element: .earth, dateRange: "22 Dec - 19 Jan"),
        // Air
        ZodiacSignInfo(symbol: "♊", englishName: "Gemini", element: .air, dateRange: "21 May - 20 Jun"),
        ZodiacSignInfo(symbol: "♎", englishName: "Libra", element: .air, dateRange: "23 Sep - 22 Oct"),
        ZodiacSignInfo(symbol: "♒", englishName: "Aquarius", element: .air, dateRange: "20 Jan - 18 Feb"),
        // Water
        ZodiacSignInfo(symbol: "♋", englishName: "Cancer", element: .water, dateRange: "21 Jun - 22 Jul"),
        ZodiacSignInfo(symbol: "♏", englishName: "Scorpio", element: .water, dateRange: "23 Oct - 21 Nov"),
        ZodiacSignInfo(symbol: "♓", englishName: "Pisces", element: .water, dateRange: "19 Feb - 20 Mar")
    ]
}

