import SwiftUI
#if canImport(WidgetKit)
import WidgetKit
#endif

public struct WidgetPreviewView: View {
    @ObservedObject var store: BirthdayStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTab: Int = 0
    @State private var didReloadWidgets: Bool = false
    
    public init(store: BirthdayStore) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Descriptive header
                    VStack(spacing: 8) {
                        Image(systemName: "square.dashed.inset.filled")
                            .font(.system(size: 38))
                            .foregroundColor(store.accentPrimary)
                        
                        Text(store.tr(.widgetSection))
                            .font(.system(size: 22, weight: .bold))
                        
                        Text(store.tr(.widgetPreviewTitle))
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 8)
                    
                    // Preview selector
                    Picker(store.tr(.widgetPreviewSectionTitle), selection: $selectedTab) {
                        Text(store.tr(.widgetTabHomeScreen)).tag(0)
                        Text(store.tr(.widgetTabLockScreen)).tag(1)
                        Text(store.tr(.widgetTabStandBy)).tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    
                    // Selected widget preview
                    Group {
                        if selectedTab == 0 {
                            homeScreenWidgetsPreview
                        } else if selectedTab == 1 {
                            lockScreenWidgetsPreview
                        } else {
                            standByWidgetPreview
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Button to reload widgets
                    VStack(spacing: 8) {
                        Button {
                            #if canImport(WidgetKit)
                            WidgetCenter.shared.reloadAllTimelines()
                            #endif
                            withAnimation {
                                didReloadWidgets = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                withAnimation {
                                    didReloadWidgets = false
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: didReloadWidgets ? "checkmark.circle.fill" : "arrow.triangle.2.circlepath")
                                Text(didReloadWidgets ? store.tr(.widgetRefreshedToast) : store.tr(.widgetRefreshBtn))
                            }
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(didReloadWidgets ? LinearGradient(colors: [.green], startPoint: .top, endPoint: .bottom) : store.accentGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .shadow(color: store.accentPrimary.opacity(0.3), radius: 6, x: 0, y: 3)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        Text(store.tr(.widgetFooterDesc))
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    
                    Spacer(minLength: 24)
                }
                .padding(.vertical, 16)
            }
            .background(CandleTheme.background.ignoresSafeArea())
            .navigationTitle(store.tr(.widgetSection))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(store.tr(.done)) {
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(store.accentPrimary)
                }
            }
        }
    }
    
    // MARK: - Home Screen Previews
    
    private var homeScreenWidgetsPreview: some View {
        VStack(spacing: 20) {
            // Small Widget (System Small)
            VStack(alignment: .leading, spacing: 8) {
                Text(store.tr(.widgetSmallTitle))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                
                HStack {
                    Spacer()
                    smallWidgetView
                        .frame(width: 158, height: 158)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
                    Spacer()
                }
            }
            
            // Medium Widget (System Medium)
            VStack(alignment: .leading, spacing: 8) {
                Text(store.tr(.widgetMediumTitle))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                
                mediumWidgetView
                    .frame(maxWidth: .infinity)
                    .frame(height: 158)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
            }
        }
    }
    
    private var smallWidgetView: some View {
        ZStack {
            CandleTheme.cardBackground
            
            LinearGradient(
                colors: [store.accentPrimary.opacity(0.18), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            if let hero = store.heroUpcomingPerson {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 18))
                            .foregroundColor(store.accentPrimary)
                        Spacer()
                        Text("\(hero.daysRemaining())d")
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(store.accentGradient)
                            .clipShape(Capsule())
                    }
                    
                    Spacer()
                    
                    AvatarCircleView(person: hero, size: 38)
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text(hero.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Text(hero.formattedBirthday(for: store.currentLanguage))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(14)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "flame")
                        .font(.system(size: 26))
                        .foregroundColor(store.accentPrimary)
                    Text(store.tr(.widgetNoBirthdays))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var mediumWidgetView: some View {
        ZStack {
            CandleTheme.cardBackground
            
            LinearGradient(
                colors: [store.accentPrimary.opacity(0.12), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            let list = store.sortedUpcomingPeople.prefix(2)
            if !list.isEmpty {
                HStack(spacing: 14) {
                    ForEach(Array(list)) { person in
                        let personPrimary = CandleTheme.avatarPrimaryColor(for: person.colorIndex)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                AvatarCircleView(person: person, size: 40)
                                Spacer()
                                Text(person.isToday ? store.tr(.todayBadge) : store.tr(.daysShort(person.daysRemaining())))
                                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(CandleTheme.avatarGradient(for: person.colorIndex))
                                    .clipShape(Capsule())
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(person.name)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                
                                Text(person.formattedBirthday(for: store.currentLanguage))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(14)
                        .background(personPrimary.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
                .padding(12)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "flame")
                        .font(.system(size: 30))
                        .foregroundColor(store.accentPrimary)
                    Text(store.tr(.emptyTitle))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Lock Screen Previews
    
    private var lockScreenWidgetsPreview: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(store.tr(.widgetLockScreenTitle))
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
            
            // Simulates dark lock screen with clock and widgets
            ZStack {
                Color.black
                
                VStack(spacing: 16) {
                    // Lock Screen Clock
                    VStack(spacing: 2) {
                        Text("9:41")
                            .font(.system(size: 54, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    // Rectangular & Circular Widget Section
                    HStack(spacing: 16) {
                        // Circular
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 3)
                            
                            VStack(spacing: 2) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(store.accentPrimary)
                                if let hero = store.heroUpcomingPerson {
                                    Text("\(hero.daysRemaining())d")
                                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                                        .foregroundColor(.white)
                                } else {
                                    Text("--")
                                        .font(.system(size: 11))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .frame(width: 58, height: 58)
                        
                        // Rectangular
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white.opacity(0.12))
                            
                            if let hero = store.heroUpcomingPerson {
                                HStack(spacing: 10) {
                                    Image(systemName: "gift.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(store.accentPrimary)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(hero.name)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                        
                                        Text(hero.isToday ? store.tr(.todayBirthdayMsg) : "\(hero.formattedBirthday(for: store.currentLanguage)) (\(hero.daysRemaining())d)")
                                            .font(.system(size: 11))
                                            .foregroundColor(.white.opacity(0.75))
                                    }
                                }
                                .padding(.horizontal, 10)
                            } else {
                                Text(store.tr(.widgetNoUpcoming))
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.horizontal, 10)
                            }
                        }
                        .frame(height: 58)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 32)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 6)
        }
    }
    
    // MARK: - StandBy Mode Preview
    
    private var standByWidgetPreview: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(store.tr(.widgetStandByTitle))
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
            
            ZStack {
                Color.black
                
                HStack(spacing: 24) {
                    // Large StandBy Clock
                    VStack(alignment: .leading, spacing: 0) {
                        Text("21")
                            .font(.system(size: 56, weight: .black, design: .rounded))
                            .foregroundColor(.red.opacity(0.95))
                        Text("41")
                            .font(.system(size: 56, weight: .black, design: .rounded))
                            .foregroundColor(.red.opacity(0.95))
                    }
                    
                    Divider()
                        .background(Color.red.opacity(0.4))
                        .frame(height: 100)
                    
                    // Birthday widget in red/orange night mode
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.red)
                            Text("CANDLE")
                                .font(.system(size: 11, weight: .heavy, design: .rounded))
                                .foregroundColor(.red.opacity(0.8))
                        }
                        
                        if let hero = store.heroUpcomingPerson {
                            Text(hero.name)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.red)
                                .lineLimit(1)
                            
                            Text(hero.isToday ? store.tr(.todayBirthdayMsg).uppercased() : store.tr(.daysShort(hero.daysRemaining())).uppercased())
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.red.opacity(0.75))
                        } else {
                            Text(store.tr(.widgetNoBirthdays).uppercased())
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.red.opacity(0.6))
                        }
                    }
                }
                .padding(24)
            }
            .frame(height: 170)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color.red.opacity(0.2), radius: 12, x: 0, y: 4)
        }
    }
}
