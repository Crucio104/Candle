import SwiftUI
import UIKit

public struct GiftTrackerSectionView: View {
    @ObservedObject var store: BirthdayStore
    let person: BirthdayPerson?
    @Binding var externalGifts: [GiftItem]
    let isEditingMode: Bool
    let asCard: Bool
    
    @State private var isAddingGift: Bool = false
    @State private var newGiftTitle: String = ""
    @State private var newGiftStatus: GiftStatus = .idea
    @State private var newGiftPrice: String = ""
    @State private var newGiftUrl: String = ""
    @State private var newGiftMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var newGiftYear: Int = Calendar.current.component(.year, from: Date())
    @State private var newGiftIsPrivate: Bool = false
    @State private var selectedFilter: GiftFilter = .all
    @State private var isPrivateGiftsUnlocked: Bool = false
    @State private var editingGiftItem: GiftItem? = nil
    
    private enum GiftFilter: String, CaseIterable, Identifiable {
        case all = "all"
        case idea = "idea"
        case purchased = "purchased"
        case given = "given"
        
        var id: String { rawValue }
    }
    
    // Initializer for the detail view (BirthdayDetailView)
    public init(store: BirthdayStore, person: BirthdayPerson, asCard: Bool = true) {
        self.store = store
        self.person = person
        self._externalGifts = .constant([])
        self.isEditingMode = false
        self.asCard = asCard
    }
    
    // Initializer for the creation and editing view (AddEditBirthdayView)
    public init(store: BirthdayStore, gifts: Binding<[GiftItem]>, asCard: Bool = false) {
        self.store = store
        self.person = nil
        self._externalGifts = gifts
        self.isEditingMode = true
        self.asCard = asCard
    }
    
    private var currentGifts: [GiftItem] {
        if isEditingMode {
            return externalGifts
        } else {
            return person?.gifts ?? []
        }
    }
    
    private var totalSpent: Double {
        currentGifts
            .filter { $0.status == .purchased || $0.status == .given }
            .compactMap { $0.price }
            .reduce(0, +)
    }
    
    private var filteredGifts: [GiftItem] {
        switch selectedFilter {
        case .all:
            return currentGifts
        case .idea:
            return currentGifts.filter { $0.status == .idea }
        case .purchased:
            return currentGifts.filter { $0.status == .purchased }
        case .given:
            return currentGifts.filter { $0.status == .given }
        }
    }
    
    public var body: some View {
        let content = VStack(alignment: .leading, spacing: 14) {
            // Header with Title, Total Spent, and Add Button
            HStack(spacing: 8) {
                Label(store.tr(.giftsTrackerTitle), systemImage: "gift.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(store.accentPrimary)
                
                if totalSpent > 0 {
                    Text(String(format: "%.2f €", totalSpent))
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(.green)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.green.opacity(0.12))
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        isAddingGift.toggle()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: isAddingGift ? "xmark" : "plus")
                            .font(.system(size: 12, weight: .bold))
                        Text(isAddingGift ? store.tr(.cancel) : store.tr(.addGiftBtn))
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(store.accentGradient)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            
            // New gift input box with smooth spring animation
            if isAddingGift {
                VStack(spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundColor(store.accentPrimary)
                        TextField(store.tr(.giftTitlePlaceholder), text: $newGiftTitle)
                            .font(.system(size: 14))
                            .submitLabel(.done)
                            .onSubmit {
                                saveNewGift()
                            }
                    }
                    .padding(10)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "tag.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            TextField(store.tr(.giftPricePlaceholder), text: $newGiftPrice)
                                .font(.system(size: 13))
                                .keyboardType(.decimalPad)
                        }
                        .padding(9)
                        .background(Color(uiColor: .tertiarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        
                        HStack(spacing: 4) {
                            Image(systemName: "link")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            TextField(store.tr(.giftUrlPlaceholder), text: $newGiftUrl)
                                .font(.system(size: 13))
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .keyboardType(.URL)
                        }
                        .padding(9)
                        .background(Color(uiColor: .tertiarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    
                    // Date selector (mese.anno)
                    HStack(spacing: 8) {
                        Label(store.tr(.dateLabel), systemImage: "calendar")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Picker(store.tr(.month), selection: $newGiftMonth) {
                                ForEach(1...12, id: \.self) { m in
                                    Text(String(format: "%02d", m)).tag(m)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(uiColor: .tertiarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            
                            Text(".")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.secondary)
                            
                            Picker(store.tr(.calendarYearMode), selection: $newGiftYear) {
                                let curYear = Calendar.current.component(.year, from: Date())
                                ForEach((curYear - 10)...(curYear + 10), id: \.self) { y in
                                    Text("\(y)").tag(y)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(uiColor: .tertiarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                    }
                    .padding(.horizontal, 4)
                    
                    // Secret / Private toggle
                    HStack {
                        Toggle(isOn: $newGiftIsPrivate) {
                            HStack(spacing: 6) {
                                Image(systemName: newGiftIsPrivate ? "lock.fill" : "lock.open")
                                    .font(.system(size: 12))
                                Text(store.tr(.privateGiftLabel))
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(newGiftIsPrivate ? store.accentPrimary : .secondary)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: store.accentPrimary))
                    }
                    .padding(.horizontal, 4)
                    
                    HStack {
                        // Initial status selector
                        Picker(store.tr(.statusLabel), selection: $newGiftStatus) {
                            ForEach(GiftStatus.allCases) { st in
                                Label(st.localizedName(for: store.currentLanguage), systemImage: st.icon).tag(st)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        Button {
                            saveNewGift()
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(newGiftTitle.trimmingCharacters(in: .whitespaces).isEmpty ? .secondary : store.accentPrimary)
                        }
                        .buttonStyle(.plain)
                        .disabled(newGiftTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                .padding(12)
                .background(CandleTheme.subCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
            
            // Filter pills when gifts exist
            if !currentGifts.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        filterPill(filter: .all, title: "\(store.tr(.filterAll)) (\(currentGifts.count))")
                        filterPill(filter: .idea, title: "💡 (\(currentGifts.filter { $0.status == .idea }.count))")
                        filterPill(filter: .purchased, title: "🛍️ (\(currentGifts.filter { $0.status == .purchased }.count))")
                        filterPill(filter: .given, title: "🎁 (\(currentGifts.filter { $0.status == .given }.count))")
                    }
                }
            }
            
            // Tracked gifts list
            if currentGifts.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "gift")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text(store.tr(.noGiftsRecorded))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            } else if filteredGifts.isEmpty {
                Text(store.tr(.noGiftsMatchingFilter))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 10)
            } else {
                VStack(spacing: 8) {
                    ForEach(filteredGifts) { gift in
                        giftRow(gift: gift)
                    }
                }
            }
        }
        
        Group {
            if asCard {
                content
                    .padding(16)
                    .candleCardStyle()
            } else {
                content
                    .padding(.vertical, 6)
            }
        }
        .sheet(item: $editingGiftItem) { giftToEdit in
            EditGiftSheetView(
                store: store,
                gift: giftToEdit,
                onSave: { updatedGift in
                    saveEditedGift(updatedGift)
                }
            )
        }
        .onDisappear {
            isPrivateGiftsUnlocked = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            isPrivateGiftsUnlocked = false
        }
    }
    
    // MARK: - Row & Helper Views
    
    private func filterPill(filter: GiftFilter, title: String) -> some View {
        let isSelected = selectedFilter == filter
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedFilter = filter
            }
        } label: {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(isSelected ? store.accentPrimary : CandleTheme.subCardBackground)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func giftRow(gift: GiftItem) -> some View {
        let isMasked = gift.isPrivate && (!store.isPrivacyUnlocked && !store.arePrivateGiftsUnlocked && !isPrivateGiftsUnlocked)
        
        if isMasked {
            // Entire masked card is tappable to trigger biometric authentication
            Button {
                CandleTheme.hapticSelection()
                store.authenticateBiometrics { success in
                    if success {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            isPrivateGiftsUnlocked = true
                        }
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(store.accentPrimary.opacity(0.15))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "lock.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(store.accentPrimary)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(store.tr(.privateGiftTitle))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Text(store.tr(.unlockPrivateGiftsBtn))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(store.accentPrimary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "faceid")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(store.accentPrimary.opacity(0.8))
                }
                .padding(10)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(CandleTheme.subCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        } else {
            HStack(spacing: 12) {
                // Quick status cycle button
                Button {
                    cycleGiftStatus(gift: gift)
                } label: {
                    ZStack {
                        Circle()
                            .fill(statusColor(gift.status).opacity(0.18))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: gift.status.icon)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(statusColor(gift.status))
                    }
                }
                .buttonStyle(.plain)
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(gift.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(gift.status == .given ? .secondary : .primary)
                            .strikethrough(gift.status == .given, color: .secondary.opacity(0.6))
                            .lineLimit(1)
                    }
                    
                    HStack(spacing: 6) {
                        Text(gift.status.localizedName(for: store.currentLanguage))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(statusColor(gift.status))
                        
                        Text("•")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        
                        Text(gift.formattedDate)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        
                        if let price = gift.price {
                            Text("•")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                            Text(String(format: "%.2f €", price))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // External link if available
                if let urlStr = gift.url, let url = URL(string: urlStr.hasPrefix("http") ? urlStr : "https://\(urlStr)") {
                    Link(destination: url) {
                        Image(systemName: "safari.fill")
                            .font(.system(size: 14))
                            .foregroundColor(store.accentPrimary)
                            .padding(6)
                            .background(store.accentPrimary.opacity(0.12))
                            .clipShape(Circle())
                    }
                }
                
                if isEditingMode {
                    // In edit form, allow toggling privacy for a gift
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            toggleGiftPrivacy(gift: gift)
                        }
                    } label: {
                        Image(systemName: gift.isPrivate ? "lock.fill" : "lock.open")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(gift.isPrivate ? store.accentPrimary : .secondary)
                            .padding(6)
                            .background((gift.isPrivate ? store.accentPrimary : Color.primary).opacity(0.08))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
                
                // Edit gift button
                Button {
                    editingGiftItem = gift
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 12))
                        .foregroundColor(store.accentPrimary)
                        .padding(6)
                        .background(store.accentPrimary.opacity(0.12))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                
                // Delete gift button (only visible when unlocked)
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        deleteGift(gift: gift)
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary.opacity(0.5))
                        .padding(6)
                }
                .buttonStyle(.plain)
            }
            .padding(10)
            .background(CandleTheme.subCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
    
    private func statusColor(_ status: GiftStatus) -> Color {
        switch status {
        case .idea: return store.accentPrimary
        case .purchased: return .blue
        case .given: return .green
        }
    }
    
    private func cycleGiftStatus(gift: GiftItem) {
        let nextStatus: GiftStatus = switch gift.status {
        case .idea: .purchased
        case .purchased: .given
        case .given: .idea
        }
        var updated = gift
        updated.status = nextStatus
        CandleTheme.hapticSelection()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if isEditingMode {
                if let idx = externalGifts.firstIndex(where: { $0.id == gift.id }) {
                    externalGifts[idx] = updated
                }
            } else if let person = person {
                store.updateGift(for: person.id, gift: updated)
            }
        }
    }
    
    private func toggleGiftPrivacy(gift: GiftItem) {
        var updated = gift
        updated.isPrivate.toggle()
        CandleTheme.hapticSelection()
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            if isEditingMode {
                if let idx = externalGifts.firstIndex(where: { $0.id == gift.id }) {
                    externalGifts[idx] = updated
                }
            } else if let person = person {
                store.updateGift(for: person.id, gift: updated)
            }
        }
    }
    
    private func deleteGift(gift: GiftItem) {
        CandleTheme.hapticSelection()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
            if isEditingMode {
                externalGifts.removeAll(where: { $0.id == gift.id })
            } else if let person = person {
                store.deleteGift(from: person.id, giftId: gift.id)
            }
        }
    }
    
    private func saveEditedGift(_ updated: GiftItem) {
        CandleTheme.hapticNotification(type: .success)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            if isEditingMode {
                if let idx = externalGifts.firstIndex(where: { $0.id == updated.id }) {
                    externalGifts[idx] = updated
                }
            } else if let person = person {
                store.updateGift(for: person.id, gift: updated)
            }
        }
    }
    
    private func saveNewGift() {
        let trimmed = newGiftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let cleanedPrice = Double(newGiftPrice.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces))
        let trimmedUrl = newGiftUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalUrl = trimmedUrl.isEmpty ? nil : trimmedUrl
        
        let gift = GiftItem(
            title: trimmed,
            status: newGiftStatus,
            year: newGiftYear,
            month: newGiftMonth,
            price: cleanedPrice,
            url: finalUrl,
            isPrivate: newGiftIsPrivate
        )
        CandleTheme.hapticNotification(type: .success)
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            if isEditingMode {
                externalGifts.append(gift)
            } else if let person = person {
                store.addGift(to: person.id, gift: gift)
            }
            
            newGiftTitle = ""
            newGiftPrice = ""
            newGiftUrl = ""
            newGiftStatus = .idea
            newGiftMonth = Calendar.current.component(.month, from: Date())
            newGiftYear = Calendar.current.component(.year, from: Date())
            newGiftIsPrivate = false
            isAddingGift = false
        }
    }
}

// MARK: - Edit Gift Sheet

private struct EditGiftSheetView: View {
    @ObservedObject var store: BirthdayStore
    let gift: GiftItem
    let onSave: (GiftItem) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var status: GiftStatus
    @State private var price: String
    @State private var url: String
    @State private var notes: String
    @State private var month: Int
    @State private var year: Int
    @State private var isPrivate: Bool
    
    init(store: BirthdayStore, gift: GiftItem, onSave: @escaping (GiftItem) -> Void) {
        self.store = store
        self.gift = gift
        self.onSave = onSave
        _title = State(initialValue: gift.title)
        _status = State(initialValue: gift.status)
        _price = State(initialValue: gift.price.map { String(format: "%.2f", $0) } ?? "")
        _url = State(initialValue: gift.url ?? "")
        _notes = State(initialValue: gift.notes)
        _month = State(initialValue: gift.month)
        _year = State(initialValue: gift.year)
        _isPrivate = State(initialValue: gift.isPrivate)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(store.tr(.giftsTrackerTitle))) {
                    TextField(store.tr(.giftTitlePlaceholder), text: $title)
                        .font(.system(size: 15))
                    
                    HStack {
                        Text("€")
                            .foregroundColor(.secondary)
                        TextField(store.tr(.giftPricePlaceholder), text: $price)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Image(systemName: "link")
                            .foregroundColor(.secondary)
                        TextField(store.tr(.giftUrlPlaceholder), text: $url)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                    }
                }
                
                Section(header: Text(store.tr(.dateLabel))) {
                    HStack {
                        Text(store.tr(.dateLabel))
                            .foregroundColor(.primary)
                        Spacer()
                        HStack(spacing: 4) {
                            Picker(store.tr(.month), selection: $month) {
                                ForEach(1...12, id: \.self) { m in
                                    Text(String(format: "%02d", m)).tag(m)
                                }
                            }
                            .pickerStyle(.menu)
                            
                            Text(".")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.secondary)
                            
                            Picker(store.tr(.calendarYearMode), selection: $year) {
                                let curYear = Calendar.current.component(.year, from: Date())
                                ForEach((curYear - 10)...(curYear + 10), id: \.self) { y in
                                    Text("\(y)").tag(y)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                }
                
                Section(header: Text(store.tr(.statusLabel))) {
                    Picker(store.tr(.statusLabel), selection: $status) {
                        ForEach(GiftStatus.allCases) { st in
                            Label(st.localizedName(for: store.currentLanguage), systemImage: st.icon).tag(st)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Toggle(isOn: $isPrivate) {
                        HStack(spacing: 6) {
                            Image(systemName: isPrivate ? "lock.fill" : "lock.open")
                            Text(store.tr(.privateGiftLabel))
                        }
                        .foregroundColor(isPrivate ? store.accentPrimary : .primary)
                    }
                    .tint(store.accentPrimary)
                }
                
                Section(header: Text(store.tr(.notesLabel))) {
                    TextField(store.tr(.optionalNotesPlaceholder), text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(store.tr(.editGiftTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(store.tr(.cancel)) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(store.tr(.save)) {
                        saveChanges()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func saveChanges() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        let cleanedPrice = Double(price.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces))
        let trimmedUrl = url.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalUrl = trimmedUrl.isEmpty ? nil : trimmedUrl
        
        var updated = gift
        updated.title = trimmedTitle
        updated.price = cleanedPrice
        updated.url = finalUrl
        updated.month = month
        updated.year = year
        updated.status = status
        updated.isPrivate = isPrivate
        updated.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        
        onSave(updated)
        dismiss()
    }
}
