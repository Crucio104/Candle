import Foundation
import SwiftUI

public enum AppLanguage: String, Codable, CaseIterable, Identifiable, Sendable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case italian = "it"
    case portuguese = "pt"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .italian: return "Italiano"
        case .portuguese: return "Português"
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let val = (try? container.decode(String.self)) ?? "en"
        switch val {
        case "es": self = .spanish
        case "fr": self = .french
        case "de": self = .german
        case "it": self = .italian
        case "pt": self = .portuguese
        default: self = .english
        }
    }
    
    public var resolvedCode: String {
        rawValue
    }
}

public enum AppAccentColor: String, Codable, CaseIterable, Identifiable, Sendable {
    case candleAmber = "amber"       // Classic Candle Amber
    case sunsetCoral = "coral"       // Sunset Coral
    case crimsonRose = "rose"        // Crimson Ruby
    case royalPurple = "purple"      // Royal Purple
    case oceanBlue   = "blue"        // Ocean Blue
    case emeraldMint = "emerald"     // Emerald Mint
    case cyanAqua    = "cyan"        // Cyan Aqua
    case sakuraPink  = "pink"        // Sakura Pink
    case honeyGold   = "gold"        // Honey Gold
    case slateMinimal = "slate"      // Minimal Slate
    case berryPlum   = "plum"        // Berry Magenta
    case electricIndigo = "indigo"   // Electric Indigo
    case limeZest    = "lime"        // Zesty Lime
    case tangerineSun = "tangerine"  // Solar Tangerine
    case midnightNavy = "navy"       // Midnight Navy
    case lavenderMist = "lavender"   // Lavender Mist
    
    public var id: String { rawValue }
    
    public func localizedName(for lang: AppLanguage) -> String {
        switch lang {
        case .italian:
            switch self {
            case .candleAmber: return "Ambra Calda (Candle)"
            case .sunsetCoral: return "Corallo Tramonto"
            case .crimsonRose: return "Rosso Rubino"
            case .royalPurple: return "Viola Reale"
            case .oceanBlue: return "Blu Oceano"
            case .emeraldMint: return "Verde Smeraldo"
            case .cyanAqua: return "Ciano Turchese"
            case .sakuraPink: return "Rosa Sakura"
            case .honeyGold: return "Oro Miele"
            case .slateMinimal: return "Ardesia Minimale"
            case .berryPlum: return "Prugna Magenta"
            case .electricIndigo: return "Indaco Elettrico"
            case .limeZest: return "Lime Brillante"
            case .tangerineSun: return "Mandarino Solare"
            case .midnightNavy: return "Blu Notte"
            case .lavenderMist: return "Nebbia Lavanda"
            }
        case .spanish:
            switch self {
            case .candleAmber: return "Ámbar Cálido (Candle)"
            case .sunsetCoral: return "Coral Atardecer"
            case .crimsonRose: return "Rubí Carmesí"
            case .royalPurple: return "Púrpura Real"
            case .oceanBlue: return "Azul Océano"
            case .emeraldMint: return "Menta Esmeralda"
            case .cyanAqua: return "Cian Turquesa"
            case .sakuraPink: return "Rosa Sakura"
            case .honeyGold: return "Oro Miel"
            case .slateMinimal: return "Pizarra Minimal"
            case .berryPlum: return "Ciruela Magenta"
            case .electricIndigo: return "Índigo Eléctrico"
            case .limeZest: return "Lima Brillante"
            case .tangerineSun: return "Mandarina Solar"
            case .midnightNavy: return "Azul Noche"
            case .lavenderMist: return "Lavanda Suave"
            }
        case .french:
            switch self {
            case .candleAmber: return "Ambre Chaud (Candle)"
            case .sunsetCoral: return "Corail Couchant"
            case .crimsonRose: return "Rouge Rubis"
            case .royalPurple: return "Violet Royal"
            case .oceanBlue: return "Bleu Océan"
            case .emeraldMint: return "Menthe Émeraude"
            case .cyanAqua: return "Cyan Turquoise"
            case .sakuraPink: return "Rose Sakura"
            case .honeyGold: return "Or Miel"
            case .slateMinimal: return "Ardoise Minimal"
            case .berryPlum: return "Prune Magenta"
            case .electricIndigo: return "Indigo Électrique"
            case .limeZest: return "Citron Vert Éclatant"
            case .tangerineSun: return "Mandarine Solaire"
            case .midnightNavy: return "Bleu Nuit"
            case .lavenderMist: return "Brume Lavande"
            }
        case .german:
            switch self {
            case .candleAmber: return "Warmes Bernstein (Candle)"
            case .sunsetCoral: return "Sonnenuntergangskoralle"
            case .crimsonRose: return "Rubinrot"
            case .royalPurple: return "Königspurpur"
            case .oceanBlue: return "Ozeanblau"
            case .emeraldMint: return "Smaragdgrün"
            case .cyanAqua: return "Türkisblau"
            case .sakuraPink: return "Sakura-Rosa"
            case .honeyGold: return "Honiggold"
            case .slateMinimal: return "Minimalistisches Schiefer"
            case .berryPlum: return "Pflaume Magenta"
            case .electricIndigo: return "Elektro-Indigo"
            case .limeZest: return "Frisches Limettengrün"
            case .tangerineSun: return "Sonnige Mandarine"
            case .midnightNavy: return "Mitternachtsblau"
            case .lavenderMist: return "Lavendelnebel"
            }
        case .portuguese:
            switch self {
            case .candleAmber: return "Âmbar Quente (Candle)"
            case .sunsetCoral: return "Coral Pôr do Sol"
            case .crimsonRose: return "Vermelho Rubi"
            case .royalPurple: return "Roxo Real"
            case .oceanBlue: return "Azul Oceano"
            case .emeraldMint: return "Menta Esmeralda"
            case .cyanAqua: return "Ciano Turquesa"
            case .sakuraPink: return "Rosa Sakura"
            case .honeyGold: return "Ouro Mel"
            case .slateMinimal: return "Ardósia Minimal"
            case .berryPlum: return "Ameixa Magenta"
            case .electricIndigo: return "Índigo Elétrico"
            case .limeZest: return "Lima Vibrante"
            case .tangerineSun: return "Mandarina Solar"
            case .midnightNavy: return "Azul Meia-Noite"
            case .lavenderMist: return "Névoa Lavanda"
            }
        case .english:
            switch self {
            case .candleAmber: return "Warm Amber (Candle)"
            case .sunsetCoral: return "Sunset Coral"
            case .crimsonRose: return "Crimson Ruby"
            case .royalPurple: return "Royal Purple"
            case .oceanBlue: return "Ocean Blue"
            case .emeraldMint: return "Emerald Mint"
            case .cyanAqua: return "Cyan Turquoise"
            case .sakuraPink: return "Sakura Pink"
            case .honeyGold: return "Honey Gold"
            case .slateMinimal: return "Minimal Slate"
            case .berryPlum: return "Berry Magenta"
            case .electricIndigo: return "Electric Indigo"
            case .limeZest: return "Zesty Lime"
            case .tangerineSun: return "Solar Tangerine"
            case .midnightNavy: return "Midnight Navy"
            case .lavenderMist: return "Lavender Mist"
            }
        }
    }
    
    public var primary: Color {
        switch self {
        case .candleAmber: return Color(red: 0.98, green: 0.62, blue: 0.26)
        case .sunsetCoral: return Color(red: 0.98, green: 0.44, blue: 0.25)
        case .crimsonRose: return Color(red: 0.92, green: 0.24, blue: 0.36)
        case .royalPurple: return Color(red: 0.62, green: 0.36, blue: 0.94)
        case .oceanBlue:   return Color(red: 0.22, green: 0.52, blue: 0.96)
        case .emeraldMint: return Color(red: 0.16, green: 0.74, blue: 0.52)
        case .cyanAqua:    return Color(red: 0.12, green: 0.71, blue: 0.82)
        case .sakuraPink:  return Color(red: 0.94, green: 0.38, blue: 0.68)
        case .honeyGold:   return Color(red: 0.92, green: 0.73, blue: 0.22)
        case .slateMinimal: return Color(red: 0.45, green: 0.52, blue: 0.62)
        case .berryPlum:   return Color(red: 0.85, green: 0.18, blue: 0.52)
        case .electricIndigo: return Color(red: 0.38, green: 0.34, blue: 0.96)
        case .limeZest:    return Color(red: 0.48, green: 0.80, blue: 0.18)
        case .tangerineSun: return Color(red: 1.00, green: 0.50, blue: 0.12)
        case .midnightNavy: return Color(red: 0.16, green: 0.35, blue: 0.68)
        case .lavenderMist: return Color(red: 0.68, green: 0.52, blue: 0.94)
        }
    }
    
    public var secondary: Color {
        switch self {
        case .candleAmber: return Color(red: 0.99, green: 0.44, blue: 0.35)
        case .sunsetCoral: return Color(red: 0.99, green: 0.32, blue: 0.38)
        case .crimsonRose: return Color(red: 0.85, green: 0.18, blue: 0.48)
        case .royalPurple: return Color(red: 0.82, green: 0.42, blue: 0.92)
        case .oceanBlue:   return Color(red: 0.35, green: 0.38, blue: 0.92)
        case .emeraldMint: return Color(red: 0.18, green: 0.65, blue: 0.72)
        case .cyanAqua:    return Color(red: 0.22, green: 0.82, blue: 0.78)
        case .sakuraPink:  return Color(red: 0.96, green: 0.54, blue: 0.62)
        case .honeyGold:   return Color(red: 0.88, green: 0.55, blue: 0.20)
        case .slateMinimal: return Color(red: 0.32, green: 0.38, blue: 0.48)
        case .berryPlum:   return Color(red: 0.65, green: 0.12, blue: 0.68)
        case .electricIndigo: return Color(red: 0.58, green: 0.22, blue: 0.92)
        case .limeZest:    return Color(red: 0.24, green: 0.72, blue: 0.40)
        case .tangerineSun: return Color(red: 0.98, green: 0.28, blue: 0.20)
        case .midnightNavy: return Color(red: 0.28, green: 0.52, blue: 0.88)
        case .lavenderMist: return Color(red: 0.84, green: 0.60, blue: 0.96)
        }
    }
    
    public var gradient: LinearGradient {
        LinearGradient(
            colors: [primary, secondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
