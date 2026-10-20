import SwiftUI

public struct CandleInsightsView: View {
    @ObservedObject var store: BirthdayStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPerson: BirthdayPerson? = nil
    @State private var showPendingIdeas: Bool = false
    @State private var showPurchasedGifts: Bool = false
    @State private var selectedSeason: Season? = nil
    @State private var selectedMonth: Int? = nil
    @State private var showZodiacExplorer: Bool = false
    
    public init(store: BirthdayStore) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                CandleTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Introductory header
                        headerCard
                        
                        // Annual progress recap (Feature 4)
                        annualProgressCard
                        
                        // 2x2 Metrics Grid (Feature 3: tap zodiac for Explorer)
                        metricsGrid
                        
                        // 12 Months Distribution Bar Chart (Feature 1)
                        monthlyDistributionCard
                        
                        // Budget & Gifts Statistics
                        giftsBudgetCard
                        
                        // Circles & Categories distribution
                        categoriesDistributionCard
                        
                        // Season Horizon overview
                        seasonHorizonCard
                        
                        // Upcoming milestone birthdays
                        milestonesCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle(store.tr(.insightsTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(store.tr(.close)) {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedPerson) { person in
                BirthdayDetailView(store: store, personId: person.id)
            }
            .sheet(isPresented: $showZodiacExplorer) {
                ZodiacExplorerSheetView(store: store, onSelectPerson: { person in
                    handlePersonSelection(person)
                })
            }
            .onDisappear {
                // Re-lock private gifts and ensure privacy is locked
                store.arePrivateGiftsUnlocked = false
                store.lockPrivacy()
            }
        }
    }
    
    // MARK: - Header
    
    private var headerCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(store.accentPrimary.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(store.accentPrimary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(store.tr(.insightsTitle))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(store.tr(.insightsSubtitle))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .candleCardStyle()
    }
    
    // MARK: - Annual Progress (Feature 4)
    
    private var annualProgressCard: some View {
        let total = store.totalCelebrationsCount
        let past = store.pastCelebrationsThisYearCount
        let ratio = total > 0 ? Double(past) / Double(total) : 0.0
        let pct = Int(ratio * 100)
        let remaining = max(0, total - past)
        let currentYear = Calendar.current.component(.year, from: Date())
        
        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(store.tr(.annualProgressTitle), systemImage: "flag.checkered.circle.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(currentYear)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(store.accentPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(store.accentPrimary.opacity(0.12))
                    .clipShape(Capsule())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text("\(pct)%")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundColor(store.accentPrimary)
                    
                    Spacer()
                    
                    Text(store.tr(.annualProgressText(past, total, pct)))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(CandleTheme.subCardBackground)
                            .frame(height: 10)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [store.accentPrimary.opacity(0.7), store.accentPrimary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(0, geo.size.width * CGFloat(ratio)), height: 10)
                    }
                }
                .frame(height: 10)
                
                HStack {
                    Text(store.tr(.remainingCelebrationsText(remaining)))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if let next = store.sortedUpcomingPeople.first {
                        let isMasked = next.isPrivate && !store.isPrivacyUnlocked
                        HStack(spacing: 4) {
                            Text("⏳")
                            Text(isMasked ? store.tr(.privateEventMaskedTitle) : next.name)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding(16)
        .candleCardStyle()
    }
    
    // MARK: - Metrics Grid
    
    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
            // Busiest month
            statBox(
                icon: "calendar.badge.clock",
                title: store.tr(.busiestMonthLabel),
                value: store.busiestMonth?.monthName ?? "—",
                subtext: store.busiestMonth.map { "\($0.count)" } ?? "0"
            )
            
            // Most common zodiac sign - interactive button opening Zodiac Explorer (Feature 3)
            Button {
                CandleTheme.hapticSelection()
                showZodiacExplorer = true
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(store.accentPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                    
                    Text(store.mostCommonZodiac.map { "\($0.symbol) \($0.name)" } ?? "—")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    Text(store.tr(.mostCommonZodiacLabel))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .candleCardStyle()
            }
            .buttonStyle(.plain)
            
            // Average age
            statBox(
                icon: "hourglass",
                title: store.tr(.averageAgeLabel),
                value: store.averageAge.map { String(format: "%.1f", $0) } ?? "—",
                subtext: store.averageAge != nil ? store.tr(.yearsOld(Int(store.averageAge ?? 0))) : "—"
            )
            
            // Total saved people
            statBox(
                icon: "person.2.fill",
                title: store.tr(.savedBirthdaysCount),
                value: "\(store.people.count)",
                subtext: "Candle"
            )
        }
    }
    
    private func statBox(icon: String, title: String, value: String, subtext: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(store.accentPrimary)
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .candleCardStyle()
    }
    
    // MARK: - Monthly Distribution Bar Chart (Feature 1)
    
    private var monthlyDistributionCard: some View {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let monthCounts = (1...12).map { (month: $0, count: store.people(inMonth: $0).count) }
        let maxCount = max(1, monthCounts.map(\.count).max() ?? 1)
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: store.currentLanguage.resolvedCode)
        let shortMonthSymbols = formatter.shortMonthSymbols ?? ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
        
        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(store.tr(.monthlyDistributionTitle), systemImage: "chart.bar.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let busyMonth = store.busiestMonth {
                    HStack(spacing: 4) {
                        Text("🔥")
                        Text(busyMonth.monthName)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(store.accentPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(store.accentPrimary.opacity(0.12))
                    .clipShape(Capsule())
                }
            }
            
            Text(store.tr(.monthlyDistributionSubtitle))
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            
            // 12 Interactive Vertical Bars
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(1...12, id: \.self) { m in
                    let count = monthCounts[m - 1].count
                    let isCurrent = m == currentMonth
                    let isSelected = selectedMonth == m
                    let barHeight: CGFloat = count == 0 ? 6 : max(14, CGFloat(count) / CGFloat(maxCount) * 72)
                    let shortName = shortMonthSymbols[min(11, max(0, m - 1))].prefix(3).capitalized
                    
                    Button {
                        CandleTheme.hapticSelection()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            if selectedMonth == m {
                                selectedMonth = nil
                            } else {
                                selectedMonth = m
                            }
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Text(count > 0 ? "\(count)" : "")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(isSelected ? store.accentPrimary : .secondary)
                                .frame(height: 12)
                            
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(
                                    isSelected
                                        ? store.accentPrimary
                                        : (count > 0
                                           ? store.accentPrimary.opacity(isCurrent ? 0.8 : 0.45)
                                           : CandleTheme.subCardBackground)
                                )
                                .frame(height: barHeight)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .stroke(isCurrent ? store.accentPrimary : Color.clear, lineWidth: 1.5)
                                )
                            
                            Text(shortName)
                                .font(.system(size: 10, weight: isSelected || isCurrent ? .bold : .medium))
                                .foregroundColor(isSelected ? store.accentPrimary : (isCurrent ? .primary : .secondary))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(height: 125, alignment: .bottom)
            .padding(.vertical, 4)
            
            // Expandable celebrations for selected month
            if let m = selectedMonth {
                let monthPeople = store.people(inMonth: m)
                let monthName = formatter.monthSymbols[min(11, max(0, m - 1))].capitalized
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("\(monthName) (\(monthPeople.count))")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(store.accentPrimary)
                        Spacer()
                    }
                    .padding(.top, 4)
                    
                    if monthPeople.isEmpty {
                        Text(store.tr(.noEventsInMonth))
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                    } else {
                        ForEach(monthPeople) { person in
                            let isMasked = person.isPrivate && !store.isPrivacyUnlocked
                            Button {
                                CandleTheme.hapticSelection()
                                handlePersonSelection(person)
                            } label: {
                                HStack(spacing: 10) {
                                    if isMasked {
                                        ZStack {
                                            Circle()
                                                .fill(CandleTheme.avatarGradient(for: person.colorIndex))
                                                .frame(width: 30, height: 30)
                                            Image(systemName: "lock.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(.white)
                                        }
                                    } else {
                                        AvatarCircleView(person: person, size: 30)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(isMasked ? store.tr(.privateEventMaskedTitle) : person.name)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                        Text(isMasked ? store.tr(.unlockPrivacyBtn) : person.formattedBirthday(for: store.currentLanguage))
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                    if !isMasked {
                                        Text(person.eventType.emoji)
                                            .font(.system(size: 13))
                                    }
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.secondary.opacity(0.5))
                                }
                                .padding(8)
                                .background(CandleTheme.subCardBackground.opacity(0.6))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.98, anchor: .top)), removal: .opacity))
            }
        }
        .padding(16)
        .candleCardStyle()
    }
    
    // MARK: - Gifts & Budget
    
    private var giftsBudgetCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(store.tr(.giftsBudgetLabel), systemImage: "gift.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack(spacing: 14) {
                // Total expenditure - interactive button (opens list of purchased gifts)
                Button {
                    CandleTheme.hapticSelection()
                    togglePurchasedGifts()
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(store.tr(.totalSpentLabel))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Text(String(format: "€ %.2f", store.totalGiftsSpent))
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundColor(store.accentPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            Spacer()
                            Image(systemName: showPurchasedGifts ? "chevron.up" : "chevron.down")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary.opacity(0.8))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(showPurchasedGifts ? store.accentPrimary.opacity(0.14) : CandleTheme.subCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(showPurchasedGifts ? store.accentPrimary : Color.clear, lineWidth: 1.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                
                // Pending ideas count - interactive button (opens list directly without biometrics popup)
                Button {
                    CandleTheme.hapticSelection()
                    togglePendingIdeas()
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(store.tr(.pendingIdeasLabel))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Text("\(store.pendingIdeasCount)")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(.orange)
                            Text("💡")
                            Spacer()
                            Image(systemName: showPendingIdeas ? "chevron.up" : "chevron.down")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary.opacity(0.8))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(showPendingIdeas ? Color.orange.opacity(0.14) : CandleTheme.subCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(showPendingIdeas ? Color.orange : Color.clear, lineWidth: 1.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            
            // Expanded Purchased Gifts menu
            if showPurchasedGifts {
                VStack(alignment: .leading, spacing: 8) {
                    let purchasedGifts = store.allPurchasedGifts
                    if purchasedGifts.isEmpty {
                        Text(store.tr(.noPurchasedGiftsMsg))
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                    } else {
                        ForEach(purchasedGifts) { item in
                            let isMasked = (item.gift.isPrivate || item.person.isPrivate) && !store.arePrivateGiftsUnlocked
                            Button {
                                CandleTheme.hapticSelection()
                                if isMasked {
                                    // Biometric authentication triggers when clicking on the private purchased gift.
                                    // It unlocks the gift view without unlocking private events on the main dashboard.
                                    store.authenticateBiometrics { success in
                                        if success {
                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                                store.arePrivateGiftsUnlocked = true
                                            }
                                            selectedPerson = item.person
                                        }
                                    }
                                } else {
                                    handlePersonSelection(item.person)
                                }
                            } label: {
                                HStack(spacing: 10) {
                                    if isMasked {
                                        ZStack {
                                            Circle()
                                                .fill(CandleTheme.avatarGradient(for: item.person.colorIndex))
                                                .frame(width: 32, height: 32)
                                            Image(systemName: "lock.fill")
                                                .font(.system(size: 13))
                                                .foregroundColor(.white)
                                        }
                                    } else {
                                        AvatarCircleView(person: item.person, size: 32)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack(spacing: 6) {
                                            Text(isMasked ? store.tr(.privateEventMaskedTitle) : item.gift.title)
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundColor(.primary)
                                                .lineLimit(1)
                                            
                                            if item.gift.isPrivate {
                                                Image(systemName: "lock.fill")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(store.accentPrimary)
                                            }
                                        }
                                        
                                        Text(isMasked ? store.tr(.unlockPrivacyBtn) : "\(store.tr(.forPersonLabel(item.person.name))) • \(item.gift.formattedDate)")
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                    
                                    Spacer()
                                    
                                    if !isMasked, let price = item.gift.price {
                                        Text(String(format: "€ %.2f", price))
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                            .foregroundColor(store.accentPrimary)
                                    }
                                    
                                    Image(systemName: isMasked ? "lock.fill" : "chevron.right")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.secondary.opacity(0.6))
                                }
                                .padding(10)
                                .background(CandleTheme.subCardBackground.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.top, 4)
                .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.98, anchor: .top)), removal: .opacity))
            }
            
            // Expanded Pending Ideas menu
            if showPendingIdeas {
                VStack(alignment: .leading, spacing: 8) {
                    let ideas = store.allPendingGiftIdeas
                    if ideas.isEmpty {
                        Text(store.tr(.noPendingIdeasMsg))
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                    } else {
                        ForEach(ideas) { item in
                            let isMasked = (item.gift.isPrivate || item.person.isPrivate) && !store.arePrivateGiftsUnlocked
                            Button {
                                CandleTheme.hapticSelection()
                                if isMasked {
                                    // Biometric authentication triggers when clicking on the private idea.
                                    // It unlocks the gift view without unlocking private events on the main dashboard.
                                    store.authenticateBiometrics { success in
                                        if success {
                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                                store.arePrivateGiftsUnlocked = true
                                            }
                                            selectedPerson = item.person
                                        }
                                    }
                                } else {
                                    handlePersonSelection(item.person)
                                }
                            } label: {
                                HStack(spacing: 10) {
                                    if isMasked {
                                        ZStack {
                                            Circle()
                                                .fill(CandleTheme.avatarGradient(for: item.person.colorIndex))
                                                .frame(width: 32, height: 32)
                                            Image(systemName: "lock.fill")
                                                .font(.system(size: 13))
                                                .foregroundColor(.white)
                                        }
                                    } else {
                                        AvatarCircleView(person: item.person, size: 32)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack(spacing: 6) {
                                            Text(isMasked ? store.tr(.privateEventMaskedTitle) : item.gift.title)
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundColor(.primary)
                                                .lineLimit(1)
                                            
                                            if item.gift.isPrivate {
                                                Image(systemName: "lock.fill")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(store.accentPrimary)
                                            }
                                        }
                                        
                                        Text(isMasked ? store.tr(.unlockPrivacyBtn) : "\(store.tr(.forPersonLabel(item.person.name))) • \(item.gift.formattedDate)")
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                    
                                    Spacer()
                                    
                                    if !isMasked, let price = item.gift.price {
                                        Text(String(format: "€ %.2f", price))
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                            .foregroundColor(store.accentPrimary)
                                    }
                                    
                                    Image(systemName: isMasked ? "lock.fill" : "chevron.right")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.secondary.opacity(0.6))
                                }
                                .padding(10)
                                .background(CandleTheme.subCardBackground.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.top, 4)
                .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.98, anchor: .top)), removal: .opacity))
            }
        }
        .padding(16)
        .candleCardStyle()
    }
    
    private func togglePurchasedGifts() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            if showPurchasedGifts {
                showPurchasedGifts = false
            } else {
                showPurchasedGifts = true
                showPendingIdeas = false
            }
        }
    }
    
    private func togglePendingIdeas() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            if showPendingIdeas {
                showPendingIdeas = false
            } else {
                showPendingIdeas = true
                showPurchasedGifts = false
            }
        }
    }
    
    // MARK: - Category Distribution
    
    private var categoriesDistributionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(store.tr(.categorySection), systemImage: "circle.grid.2x2.fill")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(spacing: 10) {
                ForEach(PersonCategory.allCases) { cat in
                    let count = store.people.filter { $0.category == cat }.count
                    let ratio = store.people.isEmpty ? 0.0 : Double(count) / Double(store.people.count)
                    
                    VStack(spacing: 4) {
                        HStack {
                            Text(cat.emoji)
                            Text(cat.localizedName(for: store.currentLanguage))
                                .font(.system(size: 13, weight: .medium))
                            Spacer()
                            Text("\(count)")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(CandleTheme.subCardBackground)
                                    .frame(height: 6)
                                
                                Capsule()
                                    .fill(store.accentPrimary)
                                    .frame(width: max(0, geo.size.width * CGFloat(ratio)), height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                }
            }
        }
        .padding(16)
        .candleCardStyle()
    }
    
    // MARK: - Season Horizon Overview
    
    private var seasonHorizonCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(store.tr(.seasonHorizonTitle), systemImage: "sun.snow.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let busiest = store.busiestSeason {
                    HStack(spacing: 4) {
                        Text(busiest.season.emoji)
                        Text(busiest.season.localizedName(for: store.currentLanguage))
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(busiest.season.accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(busiest.season.accentColor.opacity(0.12))
                    .clipShape(Capsule())
                }
            }
            
            if let busiest = store.busiestSeason {
                Text(store.tr(.busiestSeasonText(busiest.season.localizedName(for: store.currentLanguage), busiest.count)))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            // 2x2 Grid of the 4 Seasons
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(Season.allCases) { season in
                    let seasonPeople = store.people(in: season)
                    let count = seasonPeople.count
                    let isSelected = selectedSeason == season
                    
                    Button {
                        CandleTheme.hapticSelection()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            if selectedSeason == season {
                                selectedSeason = nil
                            } else {
                                selectedSeason = season
                            }
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(season.emoji)
                                    .font(.system(size: 20))
                                
                                Text(season.localizedName(for: store.currentLanguage))
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("\(count)")
                                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                                    .foregroundColor(season.accentColor)
                            }
                            
                            // Avatar preview for this season
                            if !seasonPeople.isEmpty {
                                HStack(spacing: -6) {
                                    ForEach(Array(seasonPeople.prefix(3))) { person in
                                        if person.isPrivate && !store.isPrivacyUnlocked {
                                            ZStack {
                                                Circle()
                                                    .fill(CandleTheme.avatarGradient(for: person.colorIndex))
                                                    .frame(width: 22, height: 22)
                                                Image(systemName: "lock.fill")
                                                    .font(.system(size: 9))
                                                    .foregroundColor(.white)
                                            }
                                            .overlay(Circle().stroke(CandleTheme.cardBackground, lineWidth: 1.5))
                                        } else {
                                            AvatarCircleView(person: person, size: 22)
                                                .overlay(Circle().stroke(CandleTheme.cardBackground, lineWidth: 1.5))
                                        }
                                    }
                                    if count > 3 {
                                        Text("+\(count - 3)")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.secondary)
                                            .padding(.leading, 10)
                                    }
                                }
                            } else {
                                Text("—")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(12)
                        .background(isSelected ? season.accentColor.opacity(0.14) : CandleTheme.subCardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(isSelected ? season.accentColor : Color.clear, lineWidth: 1.5)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Person details if a season is selected
            if let season = selectedSeason {
                let seasonPeople = store.people(in: season)
                if !seasonPeople.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(season.emoji) \(season.localizedName(for: store.currentLanguage)) (\(seasonPeople.count))")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(season.accentColor)
                            .padding(.top, 4)
                        
                        ForEach(seasonPeople) { person in
                            let isMasked = person.isPrivate && !store.isPrivacyUnlocked
                            Button {
                                CandleTheme.hapticSelection()
                                handlePersonSelection(person)
                            } label: {
                                HStack(spacing: 10) {
                                    if isMasked {
                                        ZStack {
                                            Circle()
                                                .fill(CandleTheme.avatarGradient(for: person.colorIndex))
                                                .frame(width: 30, height: 30)
                                            Image(systemName: "lock.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(.white)
                                        }
                                    } else {
                                        AvatarCircleView(person: person, size: 30)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(isMasked ? store.tr(.privateEventMaskedTitle) : person.name)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                        Text(isMasked ? store.tr(.unlockPrivacyBtn) : person.formattedBirthday(for: store.currentLanguage))
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                    if !isMasked {
                                        Text(person.eventType.emoji)
                                            .font(.system(size: 13))
                                    }
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.secondary.opacity(0.5))
                                }
                                .padding(8)
                                .background(CandleTheme.subCardBackground.opacity(0.6))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.98, anchor: .top)), removal: .opacity))
                }
            }
        }
        .padding(16)
        .candleCardStyle()
    }
    
    // MARK: - Milestones
    
    private var milestonesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(store.tr(.milestonesLabel), systemImage: "sparkles")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.primary)
            
            if store.milestoneBirthdays.isEmpty {
                Text(store.tr(.noMilestonesMsg))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 10) {
                    ForEach(store.milestoneBirthdays, id: \.person.id) { item in
                        let isMasked = item.person.isPrivate && !store.isPrivacyUnlocked
                        Button {
                            CandleTheme.hapticSelection()
                            handlePersonSelection(item.person)
                        } label: {
                            HStack(spacing: 12) {
                                if isMasked {
                                    ZStack {
                                        Circle()
                                            .fill(CandleTheme.avatarGradient(for: item.person.colorIndex))
                                            .frame(width: 38, height: 38)
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 15))
                                            .foregroundColor(.white)
                                    }
                                } else {
                                    AvatarCircleView(person: item.person, size: 38)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(isMasked ? store.tr(.privateEventMaskedTitle) : item.person.name)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                    Text(isMasked ? store.tr(.unlockPrivacyBtn) : item.person.formattedBirthday(for: store.currentLanguage))
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Text(isMasked ? "🔒" : "\(item.age) 🎉")
                                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                                    .foregroundColor(store.accentPrimary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(store.accentPrimary.opacity(0.12))
                                    .clipShape(Capsule())
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.secondary.opacity(0.5))
                            }
                            .padding(10)
                            .background(CandleTheme.subCardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(16)
        .candleCardStyle()
    }
    
    // MARK: - Navigation / Privacy Handlers
    
    private func handlePersonSelection(_ person: BirthdayPerson) {
        if person.isPrivate && !store.isPrivacyUnlocked {
            store.authenticateBiometrics { success in
                if success {
                    selectedPerson = person
                }
            }
        } else {
            selectedPerson = person
        }
    }
}

// MARK: - Zodiac Explorer Sheet (Feature 3)

public struct ZodiacExplorerSheetView: View {
    @ObservedObject var store: BirthdayStore
    let onSelectPerson: (BirthdayPerson) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSignSymbol: String? = nil
    
    public init(store: BirthdayStore, onSelectPerson: @escaping (BirthdayPerson) -> Void) {
        self.store = store
        self.onSelectPerson = onSelectPerson
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                CandleTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header info card
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(store.accentPrimary.opacity(0.15))
                                    .frame(width: 48, height: 48)
                                Image(systemName: "sparkles")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(store.accentPrimary)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(store.tr(.zodiacExplorerTitle))
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.primary)
                                Text(store.tr(.zodiacExplorerSubtitle))
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(16)
                        .candleCardStyle()
                        
                        // 4 Elements
                        ForEach(AstrologicalElement.allCases) { element in
                            elementSection(element)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle(store.tr(.zodiacExplorerTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(store.tr(.close)) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func elementSection(_ element: AstrologicalElement) -> some View {
        let signs = ZodiacSignInfo.allSigns.filter { $0.element == element }
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Text(element.emoji)
                Text(element.localizedName(for: store.currentLanguage))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(element.accentColor)
                Spacer()
            }
            
            VStack(spacing: 8) {
                ForEach(signs) { sign in
                    let peopleInSign = store.people(inZodiacSymbol: sign.symbol)
                    let isExpanded = selectedSignSymbol == sign.symbol
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            CandleTheme.hapticSelection()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                if selectedSignSymbol == sign.symbol {
                                    selectedSignSymbol = nil
                                } else {
                                    selectedSignSymbol = sign.symbol
                                }
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Text(sign.symbol)
                                    .font(.system(size: 24))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(sign.localizedName(for: store.currentLanguage))
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.primary)
                                    Text(sign.dateRange)
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if !peopleInSign.isEmpty {
                                    HStack(spacing: -6) {
                                        ForEach(Array(peopleInSign.prefix(3))) { person in
                                            if person.isPrivate && !store.isPrivacyUnlocked {
                                                ZStack {
                                                    Circle()
                                                        .fill(CandleTheme.avatarGradient(for: person.colorIndex))
                                                        .frame(width: 22, height: 22)
                                                    Image(systemName: "lock.fill")
                                                        .font(.system(size: 9))
                                                        .foregroundColor(.white)
                                                }
                                                .overlay(Circle().stroke(CandleTheme.cardBackground, lineWidth: 1.5))
                                            } else {
                                                AvatarCircleView(person: person, size: 22)
                                                    .overlay(Circle().stroke(CandleTheme.cardBackground, lineWidth: 1.5))
                                            }
                                        }
                                    }
                                    .padding(.trailing, 4)
                                }
                                
                                Text("\(peopleInSign.count)")
                                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                                    .foregroundColor(element.accentColor)
                                
                                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.secondary.opacity(0.6))
                            }
                            .padding(12)
                            .background(isExpanded ? element.accentColor.opacity(0.12) : CandleTheme.subCardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        
                        if isExpanded && !peopleInSign.isEmpty {
                            VStack(spacing: 6) {
                                ForEach(peopleInSign) { person in
                                    let isMasked = person.isPrivate && !store.isPrivacyUnlocked
                                    Button {
                                        dismiss()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                            onSelectPerson(person)
                                        }
                                    } label: {
                                        HStack(spacing: 10) {
                                            if isMasked {
                                                ZStack {
                                                    Circle()
                                                        .fill(CandleTheme.avatarGradient(for: person.colorIndex))
                                                        .frame(width: 28, height: 28)
                                                    Image(systemName: "lock.fill")
                                                        .font(.system(size: 11))
                                                        .foregroundColor(.white)
                                                }
                                            } else {
                                                AvatarCircleView(person: person, size: 28)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(isMasked ? store.tr(.privateEventMaskedTitle) : person.name)
                                                    .font(.system(size: 13, weight: .semibold))
                                                    .foregroundColor(.primary)
                                                Text(isMasked ? store.tr(.unlockPrivacyBtn) : person.formattedBirthday(for: store.currentLanguage))
                                                    .font(.system(size: 11))
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 11, weight: .semibold))
                                                .foregroundColor(.secondary.opacity(0.5))
                                        }
                                        .padding(8)
                                        .background(CandleTheme.subCardBackground.opacity(0.5))
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.leading, 8)
                            .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.98, anchor: .top)), removal: .opacity))
                        }
                    }
                }
            }
        }
        .padding(16)
        .candleCardStyle()
    }
}
