import SwiftUI

public struct MainDashboardView: View {
    @ObservedObject var store: BirthdayStore
    @StateObject private var notifications = NotificationManager.shared
    @Environment(\.colorScheme) private var systemColorScheme
    
    @State private var showingAddSheet = false
    @State private var showingContactsSheet = false
    @State private var showingSettingsSheet = false
    @State private var showingInsightsSheet = false
    @State private var showingCalendarSheet = false
    @State private var showingMapSheet = false
    @State private var selectedPerson: BirthdayPerson? = nil
    @State private var showConfetti: Bool = false
    @State private var showingAddCategoryDialog: Bool = false
    @State private var newCategoryInput: String = ""
    @State private var showingCategoryOrderSheet: Bool = false
    @State private var isDraggingHorizontally: Bool = false
    @State private var lastSwipeDate: Date = .distantPast
    
    public init(store: BirthdayStore) {
        self.store = store
    }
    
    private var isCurrentlyDark: Bool {
        switch store.settings.appearance {
        case .dark:
            return true
        case .light:
            return false
        case .system:
            return systemColorScheme == .dark
        }
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Notification permissions banner if not yet authorized
                    if !notifications.isAuthorized {
                        notificationBanner
                    }
                    
                    // Upcoming birthday Hero Card
                    if store.searchText.isEmpty, let hero = store.heroUpcomingPerson {
                        HeroBirthdayCard(
                            person: hero,
                            onSelect: {
                                guard !isDraggingHorizontally, Date().timeIntervalSince(lastSwipeDate) > 0.45 else { return }
                                if hero.isPrivate && !store.isPrivacyUnlocked {
                                    store.unlockPrivacyWithBiometrics { success in
                                        if success { selectedPerson = hero }
                                    }
                                } else {
                                    selectedPerson = hero
                                }
                            },
                            onCelebrate: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    showConfetti = true
                                }
                            }
                        )
                    }
                    
                    // Filters bar (Timeline + Category)
                    filtersBar
                    
                    // Birthdays list
                    if store.filteredPeople.isEmpty {
                        emptyStateView
                    } else {
                        birthdaysList
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 25)
                    .onChanged { value in
                        let h = value.translation.width
                        let v = value.translation.height
                        if abs(h) > 18 && abs(h) > abs(v) * 1.2 {
                            isDraggingHorizontally = true
                            lastSwipeDate = Date()
                        }
                    }
                    .onEnded { value in
                        let h = value.translation.width
                        let v = value.translation.height
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            isDraggingHorizontally = false
                        }
                        
                        // Verify horizontal swipe
                        guard abs(h) > 55 && abs(h) > abs(v) * 1.3 else { return }
                        guard !showingSettingsSheet && !showingInsightsSheet else { return }
                        
                        lastSwipeDate = Date()
                        selectedPerson = nil
                        
                        if h > 0 {
                            // Swipe right -> Settings
                            CandleTheme.hapticSelection()
                            showingSettingsSheet = true
                        } else {
                            // Swipe left -> Statistics / Insights
                            CandleTheme.hapticSelection()
                            showingInsightsSheet = true
                        }
                    }
            )
            .background(CandleTheme.background.ignoresSafeArea())
            .overlay {
                // Full-screen celebratory confetti overlay
                ConfettiOverlayView(isActive: $showConfetti)
            }
            .navigationTitle(store.tr(.appTitle))
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $store.searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: store.tr(.searchPrompt))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 14) {
                        // Settings button
                        Button {
                            showingSettingsSheet = true
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        
                        // Appearance toggle button (Sun / Moon)
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                store.toggleAppearance(isCurrentlyDark: isCurrentlyDark)
                            }
                        } label: {
                            Image(systemName: isCurrentlyDark ? "moon.fill" : "sun.max.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.yellow)
                        }
                        
                        // Privacy Vault lock toggle (visible if any contact is marked as private)
                        if store.hasPrivateEvents {
                            Button {
                                store.togglePrivacyLock()
                            } label: {
                                Image(systemName: store.isPrivacyUnlocked ? "lock.open.fill" : "lock.fill")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(store.isPrivacyUnlocked ? .green : store.accentPrimary)
                            }
                            .accessibilityLabel(store.isPrivacyUnlocked ? store.tr(.lockPrivacyBtn) : store.tr(.unlockPrivacyBtn))
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 14) {
                        // Candle Insights statistics
                        Button {
                            showingInsightsSheet = true
                        } label: {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(store.accentPrimary)
                        }
                        
                        Button {
                            showingContactsSheet = true
                        } label: {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 17))
                                .foregroundColor(store.accentPrimary)
                        }
                        
                        Button {
                            showingAddSheet = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(store.accentGradient)
                                .clipShape(Circle())
                                .shadow(color: store.accentPrimary.opacity(0.35), radius: 6, x: 0, y: 3)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddEditBirthdayView(store: store)
            }
            .sheet(isPresented: $showingContactsSheet) {
                ContactsImportView(store: store)
            }
            .sheet(isPresented: $showingSettingsSheet, onDismiss: {
                selectedPerson = nil
            }) {
                SettingsView(store: store)
            }
            .sheet(isPresented: $showingInsightsSheet, onDismiss: {
                selectedPerson = nil
            }) {
                CandleInsightsView(store: store)
            }
            .sheet(isPresented: $showingCalendarSheet) {
                CalendarGridView(store: store)
            }
            .sheet(isPresented: $showingMapSheet) {
                CelebrationMapView(store: store)
            }
            .sheet(item: $selectedPerson) { person in
                BirthdayDetailView(store: store, personId: person.id)
            }
            .sheet(isPresented: $showingCategoryOrderSheet) {
                CategoryOrderView(store: store)
            }
            .alert(store.tr(.addCategoryBtn), isPresented: $showingAddCategoryDialog) {
                TextField(store.tr(.addCategoryPlaceholder), text: $newCategoryInput)
                Button(store.tr(.addTagBtn)) {
                    let trimmed = newCategoryInput.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        store.addCustomCategory(trimmed)
                        store.selectedCategoryFilter = trimmed
                        CandleTheme.hapticNotification(type: .success)
                    }
                }
                Button(store.tr(.cancel), role: .cancel) {}
            }
            .onChange(of: showingSettingsSheet) { _, isShowing in
                if isShowing { selectedPerson = nil }
            }
            .onChange(of: showingInsightsSheet) { _, isShowing in
                if isShowing { selectedPerson = nil }
            }
            .onAppear {
                notifications.checkStatus()
            }
        }
    }
    
    // MARK: - Components
    
    private var notificationBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "bell.badge")
                .foregroundColor(store.accentPrimary)
                .font(.system(size: 20))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(store.tr(.notificationBannerTitle))
                    .font(.system(size: 14, weight: .bold))
                Text(store.tr(.notificationBannerSubtitle))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(store.tr(.enable)) {
                Task {
                    _ = await notifications.requestAuthorization()
                }
            }
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(store.accentGradient)
            .clipShape(Capsule())
        }
        .padding(14)
        .candleCardStyle()
    }
    
    private var filtersBar: some View {
        VStack(spacing: 10) {
            // Timeline filters
            HStack(spacing: 8) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(BirthdayStore.BirthdayFilter.allCases) { filter in
                            Button {
                                CandleTheme.hapticSelection()
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    store.selectedFilter = filter
                                }
                            } label: {
                                Text(filter.title(for: store.currentLanguage))
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        store.selectedFilter == filter
                                            ? store.accentPrimary
                                            : Color.primary.opacity(0.05)
                                    )
                                    .foregroundColor(
                                        store.selectedFilter == filter
                                            ? .white
                                            : .secondary
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                
                HStack(spacing: 8) {
                    // Celebration Map button
                    Button {
                        CandleTheme.hapticSelection()
                        showingMapSheet = true
                    } label: {
                        Image(systemName: "map")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(store.accentPrimary)
                            .frame(width: 32, height: 32)
                            .background(store.accentPrimary.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel(store.tr(.celebrationMapButton))
                    .buttonStyle(.plain)
                    
                    // Calendar view button
                    Button {
                        CandleTheme.hapticSelection()
                        showingCalendarSheet = true
                    } label: {
                        Image(systemName: "calendar")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(store.accentPrimary)
                            .frame(width: 32, height: 32)
                            .background(store.accentPrimary.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel(store.tr(.calendarTitle))
                    .buttonStyle(.plain)
                }
            }
            
            // Unified Categories filter row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // "All" filter pill
                    Button {
                        CandleTheme.hapticSelection()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            store.selectedCategoryFilter = nil
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text("✨")
                            Text(store.tr(.filterAll))
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            store.selectedCategoryFilter == nil
                                ? store.accentSecondary.opacity(0.18)
                                : Color.primary.opacity(0.04)
                        )
                        .foregroundColor(
                            store.selectedCategoryFilter == nil
                                ? store.accentSecondary
                                : .secondary
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(store.selectedCategoryFilter == nil ? store.accentSecondary.opacity(0.4) : Color.clear, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    
                    // Unified standard and custom categories in user-defined order
                    ForEach(store.orderedCategories) { item in
                        let isSelected = (store.selectedCategoryFilter?.caseInsensitiveCompare(item.id) == .orderedSame)
                        Button {
                            CandleTheme.hapticSelection()
                            withAnimation(.easeInOut(duration: 0.2)) {
                                store.selectedCategoryFilter = isSelected ? nil : item.id
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(item.emoji)
                                Text(item.name)
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                isSelected
                                    ? store.accentPrimary.opacity(0.18)
                                    : Color.primary.opacity(0.04)
                            )
                            .foregroundColor(
                                isSelected
                                    ? store.accentPrimary
                                    : .secondary
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(isSelected ? store.accentPrimary.opacity(0.5) : Color.clear, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            if item.isCustom {
                                Button(role: .destructive) {
                                    store.deleteCustomCategory(item.id)
                                } label: {
                                    Label(store.tr(.delete), systemImage: "trash")
                                }
                            }
                            Button {
                                showingCategoryOrderSheet = true
                            } label: {
                                Label(store.tr(.reorderCategoriesTitle), systemImage: "arrow.up.arrow.down")
                            }
                        }
                    }
                    
                    // Add Category Button at the far right
                    Button {
                        CandleTheme.hapticSelection()
                        newCategoryInput = ""
                        showingAddCategoryDialog = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 11, weight: .bold))
                            Text(store.tr(.addCategoryBtn))
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(store.accentPrimary.opacity(0.1))
                        .foregroundColor(store.accentPrimary)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    
                    // Quick Reorder button
                    Button {
                        CandleTheme.hapticSelection()
                        showingCategoryOrderSheet = true
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                            .frame(width: 28, height: 28)
                            .background(Color.primary.opacity(0.05))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(store.tr(.reorderCategoriesTitle))
                }
            }
        }
    }
    
    private var birthdaysList: some View {
        VStack(spacing: 10) {
            ForEach(store.filteredPeople) { person in
                Button {
                    guard !isDraggingHorizontally, Date().timeIntervalSince(lastSwipeDate) > 0.45 else { return }
                    if person.isPrivate && !store.isPrivacyUnlocked {
                        store.unlockPrivacyWithBiometrics { success in
                            if success {
                                selectedPerson = person
                            }
                        }
                    } else {
                        selectedPerson = person
                    }
                } label: {
                    BirthdayRowView(person: person)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .candleCardStyle()
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button {
                        selectedPerson = person
                    } label: {
                        Label(store.tr(.details), systemImage: "eye")
                    }
                    
                    Button(role: .destructive) {
                        store.deletePerson(person)
                    } label: {
                        Label(store.tr(.delete), systemImage: "trash")
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 42))
                .foregroundColor(store.accentPrimary.opacity(0.8))
                .padding(.top, 24)
            
            if !store.searchText.isEmpty {
                Text(store.tr(.noResults))
                    .font(.system(size: 18, weight: .bold))
                Text(store.tr(.noResultsDesc(store.searchText)))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            } else if store.selectedFilter != .all {
                Text(store.tr(.noBirthdaysInPeriod))
                    .font(.system(size: 18, weight: .bold))
                Text(store.tr(.noBirthdaysInPeriodDesc))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            } else {
                Text(store.tr(.emptyTitle))
                    .font(.system(size: 18, weight: .bold))
                Text(store.tr(.emptySubtitle))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                HStack(spacing: 12) {
                    Button {
                        showingContactsSheet = true
                    } label: {
                        Label(store.tr(.importContactsBtn), systemImage: "person.crop.circle.badge.plus")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .buttonStyle(.bordered)
                    
                    Button {
                        showingAddSheet = true
                    } label: {
                        Label(store.tr(.addManualBtn), systemImage: "plus")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(store.accentPrimary)
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity)
    }
}
