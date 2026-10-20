import SwiftUI

public struct BirthdayRowView: View {
    public let person: BirthdayPerson
    @ObservedObject private var store = BirthdayStore.shared
    
    public init(person: BirthdayPerson) {
        self.person = person
    }
    
    public var body: some View {
        let isMasked = person.isPrivate && !store.isPrivacyUnlocked
        
        return HStack(alignment: .center, spacing: 14) {
            // Avatar with photo or palette gradient
            if isMasked {
                ZStack {
                    Circle()
                        .fill(CandleTheme.avatarGradient(for: person.colorIndex))
                        .frame(width: 48, height: 48)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 19))
                        .foregroundColor(.white)
                }
            } else {
                AvatarCircleView(person: person, size: 48)
            }
            
            // Content: Name + Countdown badge in top row, Date + Milestone in bottom row
            VStack(alignment: .leading, spacing: 6) {
                // ROW 1: Name on the left, Countdown badge aligned right on the same line
                HStack(alignment: .center, spacing: 8) {
                    Text(isMasked ? store.tr(.privateEventMaskedTitle) : person.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Countdown badge pinned to trailing edge on the name line
                    countdownBadge
                }
                
                // ROW 2: Date, age/milestone, and active notification indicator
                HStack(alignment: .center, spacing: 5) {
                    if isMasked {
                        Text(store.tr(.unlockPrivacyBtn))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    } else {
                        Text(person.formattedDayAndMonth(for: store.currentLanguage))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        
                        if person.eventType == .birthday, let age = person.upcomingAge() {
                            Text("•")
                                .font(.caption2)
                                .foregroundColor(.secondary.opacity(0.6))
                            
                            Text(store.tr(.turnsAge(age)))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(person.isToday ? store.accentPrimary : .secondary)
                                .lineLimit(1)
                        } else if person.eventType == .anniversary {
                            Text("•")
                                .font(.caption2)
                                .foregroundColor(.secondary.opacity(0.6))
                            
                            let title = person.localizedMilestoneTitle(for: store.currentLanguage) ?? person.eventType.localizedName(for: store.currentLanguage)
                            Text(title)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(person.isToday ? store.accentPrimary : .secondary)
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                        } else if person.eventType == .special || person.eventType == .nameday {
                            Text("•")
                                .font(.caption2)
                                .foregroundColor(.secondary.opacity(0.6))
                            
                            Text(person.eventType.localizedName(for: store.currentLanguage))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(person.isToday ? store.accentPrimary : .secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    // Notification active indicator
                    if person.notifyOnSameDay || person.notifyInAdvance {
                        HStack(spacing: 3) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 9))
                            if person.notifyInAdvance {
                                Text("-\(person.advanceDays)d")
                                    .font(.system(size: 9, weight: .medium))
                            }
                        }
                        .foregroundColor(.secondary.opacity(0.7))
                    }
                }
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            }
        }
        .padding(.vertical, 6)
    }
    
    // MARK: - Countdown Badge
    
    @ViewBuilder
    private var countdownBadge: some View {
        if person.isToday {
            Text(store.tr(.todayBadge))
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(store.accentGradient)
                .clipShape(Capsule())
                .shadow(color: store.accentPrimary.opacity(0.35), radius: 5, x: 0, y: 2)
                .fixedSize(horizontal: true, vertical: true)
        } else if person.isTomorrow {
            Text(store.tr(.tomorrowBadge))
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(store.accentPrimary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(store.accentPrimary.opacity(0.12))
                .clipShape(Capsule())
                .fixedSize(horizontal: true, vertical: true)
        } else {
            let days = person.daysRemaining()
            Text(store.tr(.daysShort(days)))
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(days <= 7 ? store.accentPrimary : .secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(days <= 7 ? store.accentPrimary.opacity(0.12) : Color.primary.opacity(0.05))
                .clipShape(Capsule())
                .fixedSize(horizontal: true, vertical: true)
        }
    }
}
