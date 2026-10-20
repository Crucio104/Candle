import SwiftUI

public struct HeroBirthdayCard: View {
    public let person: BirthdayPerson
    public let onSelect: () -> Void
    public var onCelebrate: (() -> Void)?
    
    @ObservedObject private var store = BirthdayStore.shared
    @State private var isBlownOut: Bool = false
    
    public init(person: BirthdayPerson, onSelect: @escaping () -> Void, onCelebrate: (() -> Void)? = nil) {
        self.person = person
        self.onSelect = onSelect
        self.onCelebrate = onCelebrate
    }
    
    public var body: some View {
        let personGradient = CandleTheme.avatarGradient(for: person.colorIndex)
        let personPrimary = CandleTheme.avatarPrimaryColor(for: person.colorIndex)
        let personSecondary = CandleTheme.avatarSecondaryColor(for: person.colorIndex)
        
        ZStack(alignment: .bottomLeading) {
            // Background box styled with the person's accent colors
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            personPrimary.opacity(0.18),
                            personSecondary.opacity(0.08),
                            Color(uiColor: .secondarySystemGroupedBackground)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    personPrimary.opacity(0.55),
                                    personSecondary.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
            
            VStack(alignment: .leading, spacing: 14) {
                // Card header badge
                HStack(alignment: .center) {
                    HStack(spacing: 6) {
                        Image(systemName: heroBadgeIcon)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(personPrimary)
                        
                        Text(heroBadgeTitle)
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(personPrimary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(personPrimary.opacity(0.12))
                    .clipShape(Capsule())
                    
                    Spacer()
                    
                    // Countdown badge
                    if person.isToday {
                        Text(store.tr(.todayBadge))
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(store.accentGradient)
                            .clipShape(Capsule())
                            .shadow(color: store.accentPrimary.opacity(0.35), radius: 5, x: 0, y: 2)
                    } else if person.isTomorrow {
                        Text(store.tr(.tomorrowBadge))
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(store.accentPrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(store.accentPrimary.opacity(0.12))
                            .clipShape(Capsule())
                    } else {
                        let days = person.daysRemaining()
                        Text(store.tr(.daysShort(days)))
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(days <= 7 ? store.accentPrimary : .secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(days <= 7 ? store.accentPrimary.opacity(0.12) : Color.primary.opacity(0.05))
                            .clipShape(Capsule())
                    }
                }
                
                // Card body: Avatar and Details
                let isMasked = person.isPrivate && !store.isPrivacyUnlocked
                
                HStack(spacing: 16) {
                    // Avatar with photo or matching gradient
                    if isMasked {
                        ZStack {
                            Circle()
                                .fill(personGradient)
                                .frame(width: 58, height: 58)
                            Image(systemName: "lock.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                        .shadow(color: personPrimary.opacity(0.35), radius: 8, x: 0, y: 3)
                    } else {
                        AvatarCircleView(person: person, size: 58)
                            .shadow(color: personPrimary.opacity(0.35), radius: 8, x: 0, y: 3)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(isMasked ? store.tr(.privateEventMaskedTitle) : person.name)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        if isMasked {
                            Text(store.tr(.unlockPrivacyBtn))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        } else {
                            HStack(spacing: 6) {
                                Text(person.formattedDayAndMonth(for: store.currentLanguage))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.secondary)
                                
                                if person.eventType == .birthday, let age = person.upcomingAge() {
                                    Text("•")
                                        .foregroundColor(.secondary.opacity(0.6))
                                    Text(store.tr(.turnsAge(age)))
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(personPrimary)
                                }
                            }
                            
                            HStack(spacing: 8) {
                                if person.eventType == .birthday {
                                    let zodiac = person.zodiacSign(for: store.currentLanguage)
                                    Text("\(zodiac.symbol) \(zodiac.name)")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                } else {
                                    HStack(spacing: 4) {
                                        Text(person.eventType.emoji)
                                        Text(person.displayEventTypeName(for: store.currentLanguage))
                                    }
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary.opacity(0.4))
                }
                
                // Interactive candle blowing section inside the card for today's birthday
                if person.isToday {
                    Divider()
                        .background(personPrimary.opacity(0.25))
                        .padding(.top, 2)
                    
                    HStack(spacing: 12) {
                        ZStack {
                            if isBlownOut {
                                Image(systemName: "smoke.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.gray.opacity(0.65))
                                    .transition(.scale.combined(with: .opacity))
                            } else {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(personPrimary)
                                    .shadow(color: personPrimary.opacity(0.7), radius: 8, x: 0, y: 0)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .frame(width: 36, height: 36)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(isBlownOut ? store.tr(.wishMadeTitle) : store.tr(.blowCandleTitle))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text(isBlownOut ? store.tr(.wishMadeSubtitle) : store.tr(.blowCandleSubtitle(person.name)))
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button {
                            blowOut()
                        } label: {
                            Text(isBlownOut ? "✨ 🎉" : store.tr(.blowButton))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(isBlownOut ? LinearGradient(colors: [.green], startPoint: .top, endPoint: .bottom) : personGradient)
                                .clipShape(Capsule())
                                .shadow(color: personPrimary.opacity(0.4), radius: 6, x: 0, y: 2)
                        }
                        .disabled(isBlownOut)
                        .highPriorityGesture(
                            TapGesture().onEnded {
                                guard !isBlownOut else { return }
                                blowOut()
                            }
                        )
                    }
                    .padding(.top, 2)
                }
            }
            .padding(18)
        }
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .onTapGesture {
            onSelect()
        }
        .shadow(color: personPrimary.opacity(0.08), radius: 12, x: 0, y: 6)
    }
    
    private var heroBadgeIcon: String {
        switch person.eventType {
        case .birthday: return "flame.fill"
        case .anniversary: return "heart.fill"
        case .nameday: return "sparkles"
        case .special: return "star.fill"
        }
    }
    
    private var heroBadgeTitle: String {
        switch person.eventType {
        case .birthday:
            return store.tr(.nextBirthday)
        case .anniversary:
            return person.recurrence == .monthly ? store.tr(.nextMesiversary) : store.tr(.nextAnniversary)
        case .nameday:
            return store.tr(.nextNameDay)
        case .special:
            return store.tr(.nextSpecialEvent)
        }
    }
    
    private func blowOut() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isBlownOut = true
        }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        onCelebrate?()
        
        // Automatic reignition after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            withAnimation(.easeInOut(duration: 0.6)) {
                isBlownOut = false
            }
        }
    }
}
