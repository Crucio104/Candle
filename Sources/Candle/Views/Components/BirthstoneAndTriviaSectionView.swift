import SwiftUI

/// View displaying Birthstone, historical trivia, and shared birthdays
public struct BirthstoneAndTriviaSectionView: View {
    @ObservedObject var store: BirthdayStore
    let person: BirthdayPerson
    
    public init(store: BirthdayStore, person: BirthdayPerson) {
        self.store = store
        self.person = person
    }
    
    public var body: some View {
        let birthstone = person.birthstone(for: store.currentLanguage)
        let trivia = person.dayTrivia(for: store.currentLanguage)
        
        VStack(spacing: 12) {
            // MARK: - Birthstone Card
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "rhombus.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(birthstone.color)
                    Text(store.tr(.birthstoneLabel))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(birthstone.gemEmoji)
                        .font(.system(size: 18))
                }
                
                HStack(alignment: .center, spacing: 14) {
                    // Gemstone gradient badge
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [birthstone.color.opacity(0.85), birthstone.color],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                            .shadow(color: birthstone.color.opacity(0.4), radius: 6, x: 0, y: 3)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(birthstone.name)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(birthstone.meaning)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                }
                .padding(12)
                .background(CandleTheme.subCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(16)
            .candleCardStyle()
            
            // MARK: - Historical Trivia & Shared Birthdays
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "book.pages.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(store.accentPrimary)
                    Text(store.tr(.historicalTriviaTitle))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                // Chinese Zodiac (if birth year is known)
                if let cz = person.chineseZodiac(for: store.currentLanguage) {
                    HStack(spacing: 10) {
                        Text(cz.emoji)
                            .font(.system(size: 20))
                            .frame(width: 32, height: 32)
                            .background(Color.primary.opacity(0.04))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text(chineseZodiacTitle)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                            Text(cz.name)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                    }
                    .padding(10)
                    .background(CandleTheme.subCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                
                // Historical fun fact for the date or season
                HStack(alignment: .top, spacing: 10) {
                    Text("💡")
                        .font(.system(size: 16))
                    Text(trivia.funFact)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(CandleTheme.subCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                
                // Famous people born on this date
                if !trivia.famousPeople.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.secondary)
                            Text(store.tr(.sharedBirthdaysTitle))
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 4)
                        
                        ForEach(trivia.famousPeople) { celeb in
                            HStack(spacing: 10) {
                                Text(celeb.emoji)
                                    .font(.system(size: 18))
                                    .frame(width: 28, height: 28)
                                    .background(Color.primary.opacity(0.04))
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 6) {
                                        Text(celeb.name)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.primary)
                                        if let year = celeb.birthYear {
                                            Text("(\(year > 0 ? "\(year)" : "\(abs(year)) a.C."))")
                                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Text(celeb.role)
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                            }
                            .padding(10)
                            .background(CandleTheme.subCardBackground.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                    }
                }
            }
            .padding(16)
            .candleCardStyle()
        }
    }
    
    private var chineseZodiacTitle: String {
        switch store.currentLanguage {
        case .italian: return "Zodiaco Cinese:"
        case .spanish: return "Zodíaco Chino:"
        case .french: return "Zodiaque Chinois :"
        case .german: return "Chinesisches Sternzeichen:"
        case .portuguese: return "Zodíaco Chinês:"
        case .english: return "Chinese Zodiac:"
        }
    }
}
