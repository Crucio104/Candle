import SwiftUI
import UIKit

public struct BirthdayDetailView: View {
    @ObservedObject var store: BirthdayStore
    let personId: UUID
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showConfetti = false
    @State private var showingWishesSheet = false
    @State private var showingMemoryImagePicker = false
    @State private var pickedMemoryImage: UIImage? = nil
    @State private var editingPhotoId: UUID? = nil
    @State private var memoryCaptionInput = ""
    @State private var selectedFullScreenPhoto: MemoryPhoto? = nil
    @State private var showingPhotoSourceDialog = false
    @State private var showingCameraFullScreen = false
    @State private var showingCelebrationMap = false
    @State private var showingVenueSheet = false
    @State private var editingVenueId: UUID? = nil
    @State private var venueNameInput = ""
    @State private var venueYearInput = ""
    @State private var venueNotesInput = ""
    @State private var venueToDelete: CelebrationVenue? = nil
    @State private var showingDeleteVenueAlert = false
    @State private var isLocating = false
    @State private var locationErrorMessage: String? = nil
    @State private var showingFullScreenAvatar = false
    
    public init(store: BirthdayStore, personId: UUID) {
        self.store = store
        self.personId = personId
    }
    
    private var person: BirthdayPerson? {
        store.people.first(where: { $0.id == personId })
    }
    
    public var body: some View {
        NavigationStack {
            mainDetailZStack
                .navigationTitle(store.tr(.details))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
        }
        .sheet(isPresented: $showingEditSheet) {
            if let person = person {
                AddEditBirthdayView(store: store, personToEdit: person)
            }
        }
        .sheet(isPresented: $showingWishesSheet) {
            if let person = person {
                SmartWishesSheetView(store: store, person: person)
            }
        }
        .sheet(isPresented: $showingCelebrationMap) {
            CelebrationMapView(store: store, initialFocusPersonId: personId)
        }
        .sheet(isPresented: $showingVenueSheet) {
            if let person = person {
                venueSheetView(person: person)
            }
        }
        .sheet(isPresented: $showingMemoryImagePicker) {
            MultiPhotoPicker { images in
                handlePickedMemoryImages(images)
            }
        }
        .fullScreenCover(isPresented: $showingCameraFullScreen) {
            cameraFullScreenView
        }
        .fullScreenCover(item: $selectedFullScreenPhoto) { photo in
            fullScreenPhotoView(photo: photo)
        }
        .fullScreenCover(isPresented: $showingFullScreenAvatar) {
            if let person = person {
                fullScreenAvatarView(person: person)
            }
        }
        .confirmationDialog(store.tr(.choosePhotoSource), isPresented: $showingPhotoSourceDialog, titleVisibility: .visible) {
            photoSourceDialogButtons
        }
        .alert(store.tr(.deleteVenueConfirm), isPresented: $showingDeleteVenueAlert) {
            deleteVenueAlertButtons
        }
        .alert(
            store.tr(.celebrationLocation),
            isPresented: locationAlertBinding
        ) {
            Button(store.tr(.done), role: .cancel) {}
        } message: {
            Text(locationErrorMessage ?? "")
        }
        .alert(store.tr(.deleteConfirmTitle), isPresented: $showingDeleteAlert) {
            deleteAlertButtons
        } message: {
            Text(store.tr(.deleteConfirmMessage))
        }
        .onChange(of: pickedMemoryImage) { _, newImg in
            handlePickedMemoryImage(newImg)
        }
    }
    
    @ViewBuilder
    private var mainDetailZStack: some View {
        ZStack {
            CandleTheme.background.ignoresSafeArea()
            
            Group {
                if let person = person {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Avatar and Ring Countdown
                            avatarAndRingSection(person: person)
                            
                            // Blow the candle if birthday is today!
                            if person.isToday {
                                BlowCandleView(store: store, person: person) {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        showConfetti = true
                                    }
                                }
                            }
                            
                            // Key Details Card
                            keyDetailsSection(person: person)
                            
                            // Celebration Venues & Locations Card (Apple Maps)
                            celebrationVenuesSection(person: person)
                            
                            // Celebration Memory Photos
                            memorySection(person: person)
                            
                            // Birthstone & Historical Trivia
                            BirthstoneAndTriviaSectionView(store: store, person: person)
                            
                            // Reminders and Notifications Card
                            notificationsSection(person: person)
                            
                            // Gift Tracker & Wishlist
                            GiftTrackerSectionView(store: store, person: person)
                            
                            // Quick Action Wishes Button
                            wishesButton(person: person)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                } else {
                    ContentUnavailableView(store.tr(.noResults), systemImage: "person.slash")
                }
            }
            
            // Celebratory confetti overlay
            ConfettiOverlayView(isActive: $showConfetti)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(store.tr(.close)) {
                dismiss()
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                if let person = person {
                    Button {
                        togglePrivacy(for: person)
                    } label: {
                        Label(
                            person.isPrivate ? store.tr(.privacyModeUnlocked) : store.tr(.privateEventLabel),
                            systemImage: person.isPrivate ? "lock.open" : "lock"
                        )
                    }
                }
                
                Button {
                    showingEditSheet = true
                } label: {
                    Label(store.tr(.edit), systemImage: "pencil")
                }
                
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label(store.tr(.delete), systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 18))
                    .foregroundColor(store.accentPrimary)
            }
        }
    }
    
    @ViewBuilder
    private var cameraFullScreenView: some View {
        MultiShotCameraView(store: store) { images in
            handlePickedMemoryImages(images)
        }
    }
    
    @ViewBuilder
    private func fullScreenPhotoView(photo: MemoryPhoto) -> some View {
        if let img = UIImage(data: photo.imageData) {
            ZStack {
                Color.black.ignoresSafeArea()
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            selectedFullScreenPhoto = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white.opacity(0.85))
                                .padding(20)
                        }
                    }
                    Spacer()
                    if !photo.caption.isEmpty {
                        Text("“\(photo.caption)”")
                            .font(.system(size: 15, weight: .medium, design: .serif))
                            .italic()
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .padding(.bottom, 24)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func fullScreenAvatarView(person: BirthdayPerson) -> some View {
        FullScreenAvatarDetailView(
            person: person,
            store: store,
            onDismiss: {
                showingFullScreenAvatar = false
            }
        )
    }
    
    @ViewBuilder
    private var photoSourceDialogButtons: some View {
        Button {
            showingCameraFullScreen = true
        } label: {
            Label(store.tr(.takePhoto), systemImage: "camera.fill")
        }
        Button {
            showingMemoryImagePicker = true
        } label: {
            Label(store.tr(.chooseFromLibrary), systemImage: "photo.on.rectangle")
        }
        Button(store.tr(.cancel), role: .cancel) {}
    }
    
    @ViewBuilder
    private var deleteVenueAlertButtons: some View {
        Button(store.tr(.cancel), role: .cancel) {}
        Button(store.tr(.delete), role: .destructive) {
            if let person = person, let v = venueToDelete {
                deleteVenue(v, from: person)
            }
            venueToDelete = nil
        }
    }
    
    private var locationAlertBinding: Binding<Bool> {
        Binding(
            get: { locationErrorMessage != nil },
            set: { if !$0 { locationErrorMessage = nil } }
        )
    }
    
    @ViewBuilder
    private var deleteAlertButtons: some View {
        Button(store.tr(.cancel), role: .cancel) {}
        Button(store.tr(.delete), role: .destructive) {
            if let person = person {
                store.deletePerson(person)
                dismiss()
            }
        }
    }
    
    // MARK: - Sections
    
    private func avatarAndRingSection(person: BirthdayPerson) -> some View {
        let days = person.daysRemaining()
        let progress = max(0.0, min(1.0, Double(365 - days) / 365.0))
        let personGradient = CandleTheme.avatarGradient(for: person.colorIndex)
        let personPrimary = CandleTheme.avatarPrimaryColor(for: person.colorIndex)
        
        return VStack(spacing: 16) {
            ZStack {
                // Annual progress ring (matching avatar color)
                Circle()
                    .stroke(personPrimary.opacity(0.12), lineWidth: 8)
                    .frame(width: 140, height: 140)
                
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(
                        personGradient,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.8), value: progress)
                
                // Central avatar (photo or gradient) - Tap to enlarge
                Button {
                    CandleTheme.hapticSelection()
                    showingFullScreenAvatar = true
                } label: {
                    ZStack(alignment: .bottomTrailing) {
                        AvatarCircleView(person: person, size: 104)
                            .shadow(color: personPrimary.opacity(0.35), radius: 10, x: 0, y: 5)
                        
                        if person.avatarImageData != nil {
                            Image(systemName: "arrow.up.left.and.arrow.down.right")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(5)
                                .background(Color.black.opacity(0.55))
                                .clipShape(Circle())
                                .offset(x: -2, y: -2)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            
            VStack(spacing: 8) {
                Text(person.name)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.primary)
                
                // Category, event type, and privacy badges
                HStack(spacing: 8) {
                    Menu {
                        ForEach(store.orderedCategories) { item in
                            Button {
                                CandleTheme.hapticSelection()
                                var updated = person
                                if item.isCustom {
                                    updated.customCategory = item.id
                                } else if let stdCat = PersonCategory(rawValue: item.id) {
                                    updated.category = stdCat
                                    updated.customCategory = nil
                                }
                                store.updatePerson(updated)
                            } label: {
                                let isSelected = (person.categoryId.caseInsensitiveCompare(item.id) == .orderedSame)
                                if isSelected {
                                    Label("\(item.emoji) \(item.name)", systemImage: "checkmark")
                                } else {
                                    Text("\(item.emoji) \(item.name)")
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Text(person.categoryEmoji)
                                .font(.system(size: 12))
                            Text(person.categoryDisplayName(for: store.currentLanguage))
                                .font(.system(size: 13, weight: .semibold))
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.primary)
                        .padding(.horizontal, 10)
                        .frame(height: 28)
                        .background(CandleTheme.subCardBackground)
                        .clipShape(Capsule())
                    }
                    
                    if person.eventType != .birthday {
                        HStack(spacing: 5) {
                            Text(person.eventType.emoji)
                                .font(.system(size: 12))
                            if person.eventType == .anniversary && person.recurrence == .monthly {
                                if let milestone = person.localizedMilestoneTitle(for: store.currentLanguage) {
                                    Text(milestone)
                                } else {
                                    Text(store.tr(.mesiversarioLabel))
                                }
                            } else {
                                Text(person.eventType.localizedName(for: store.currentLanguage))
                                if person.recurrence == .monthly || person.recurrence == .oneTime {
                                    Text("• \(person.recurrence.localizedName(for: store.currentLanguage))")
                                }
                            }
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(personPrimary)
                        .padding(.horizontal, 10)
                        .frame(height: 28)
                        .background(personPrimary.opacity(0.12))
                        .clipShape(Capsule())
                    }
                    
                    if person.isPrivate {
                        HStack(spacing: 5) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 11, weight: .semibold))
                            Text(store.tr(.privateEventLabel))
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(store.accentPrimary)
                        .padding(.horizontal, 10)
                        .frame(height: 28)
                        .background(store.accentPrimary.opacity(0.12))
                        .clipShape(Capsule())
                    }
                }
                

                
                if person.isToday {
                    Text(store.tr(.todayBirthdayMsg))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(personPrimary)
                } else if person.isTomorrow {
                    Text(store.tr(.tomorrowBirthdayMsg))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(personPrimary)
                } else {
                    Text(store.tr(.daysRemaining(days)))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func keyDetailsSection(person: BirthdayPerson) -> some View {
        let weekday = person.upcomingWeekday(for: store.currentLanguage)
        
        return VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Event date
                infoTile(
                    icon: "calendar",
                    title: store.tr(.dateLabel),
                    value: person.formattedBirthday(for: store.currentLanguage)
                )
                
                // Zodiac sign ONLY for Birthdays, otherwise Day of the week
                if person.eventType == .birthday {
                    let zodiac = person.zodiacSign(for: store.currentLanguage)
                    infoTile(
                        icon: "sparkles",
                        title: store.tr(.zodiacLabel),
                        value: "\(zodiac.symbol) \(zodiac.name)"
                    )
                } else {
                    infoTile(
                        icon: "calendar.badge.clock",
                        title: store.tr(.upcomingWeekdayLabel),
                        value: weekday
                    )
                }
            }
            
            if person.eventType == .birthday {
                HStack(spacing: 12) {
                    // Day of the week on which the birthday falls
                    infoTile(
                        icon: "calendar.badge.clock",
                        title: store.tr(.upcomingWeekdayLabel),
                        value: weekday
                    )
                    
                    if let nextAge = person.upcomingAge() {
                        infoTile(
                            icon: "gift.fill",
                            title: store.tr(.upcomingAgeLabel),
                            value: store.tr(.yearsOld(nextAge)),
                            highlight: true
                        )
                    } else if let curAge = person.currentAge(), curAge >= 0 {
                        infoTile(
                            icon: "hourglass",
                            title: store.tr(.currentAgeLabel),
                            value: store.tr(.yearsOld(curAge))
                        )
                    }
                }
            } else if person.eventType == .anniversary {
                HStack(spacing: 12) {
                    // Anniversary milestone box
                    let annivValue = person.localizedAnniversaryNumber(for: store.currentLanguage) ?? person.eventType.localizedName(for: store.currentLanguage)
                    infoTile(
                        icon: "heart.circle.fill",
                        title: person.eventType.localizedName(for: store.currentLanguage),
                        value: annivValue,
                        highlight: true
                    )
                    
                    // Mensiversary box with months spent together
                    let mesiValue = person.localizedMonthsTogether(for: store.currentLanguage) ?? store.tr(.mesiversarioLabel)
                    infoTile(
                        icon: "heart.fill",
                        title: store.tr(.mesiversarioLabel),
                        value: mesiValue,
                        highlight: true
                    )
                }
            }
        }
    }
    
    private func infoTile(icon: String, title: String, value: String, highlight: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(highlight ? store.accentPrimary : .secondary)
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(highlight ? store.accentPrimary : .primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(CandleTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    // MARK: - Celebration Venues Section (Multiple Venues)
    
    @ViewBuilder
    private func celebrationVenuesSection(person: BirthdayPerson) -> some View {
        let venues = person.allVenues
        
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(store.tr(.celebrationVenues), systemImage: "mappin.and.ellipse")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.secondary)
                
                if !venues.isEmpty {
                    Text("\(venues.count)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(store.accentPrimary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(store.accentPrimary.opacity(0.12))
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                // Add venue button
                Button {
                    editingVenueId = nil
                    venueNameInput = ""
                    venueYearInput = CelebrationVenue.currentDateTag()
                    venueNotesInput = ""
                    showingVenueSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                        Text(store.tr(.addVenueBtn))
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(store.accentPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(store.accentPrimary.opacity(0.12))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            
            if venues.isEmpty {
                // Empty state card
                VStack(spacing: 12) {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(store.accentPrimary.opacity(0.12))
                                .frame(width: 44, height: 44)
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(store.accentPrimary)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(store.tr(.noVenuesSet))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text(store.tr(.noVenuesSetDesc))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    HStack(spacing: 10) {
                        Button {
                            editingVenueId = nil
                            venueNameInput = ""
                            venueYearInput = CelebrationVenue.currentDateTag()
                            venueNotesInput = ""
                            showingVenueSheet = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                    .font(.system(size: 13, weight: .bold))
                                Text(store.tr(.addVenueBtn))
                                    .font(.system(size: 13, weight: .bold))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                            }
                            .foregroundColor(store.accentPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(store.accentPrimary.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            fetchAndSaveCurrentLocationAsVenue(for: person)
                        } label: {
                            HStack(spacing: 6) {
                                if isLocating {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 13, weight: .bold))
                                }
                                Text(isLocating ? store.tr(.locating) : store.tr(.useCurrentLocationBtn))
                                    .font(.system(size: 13, weight: .bold))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(store.accentPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .disabled(isLocating)
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
                .candleCardStyle()
            } else {
                // Horizontal swipeable cards of celebration venues
                VStack(spacing: 12) {
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 12) {
                                ForEach(venues) { venue in
                                    venueCardView(venue: venue, person: person)
                                        .id(venue.id)
                                }
                                
                                // Add another venue card at trailing end
                                addMoreVenuesCard(person: person)
                            }
                            .padding(.horizontal, 2)
                            .padding(.vertical, 4)
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.viewAligned)
                        .defaultScrollAnchor(.trailing)
                        .onAppear {
                            if let lastId = venues.last?.id {
                                DispatchQueue.main.async {
                                    withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                                        proxy.scrollTo(lastId, anchor: .center)
                                    }
                                }
                            }
                        }
                        .onChange(of: venues.count) { _, _ in
                            if let lastId = venues.last?.id {
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                                    proxy.scrollTo(lastId, anchor: .center)
                                }
                            }
                        }
                    }
                    
                    // Recreated full-width Celebration Map Button
                    Button {
                        CandleTheme.hapticSelection()
                        showingCelebrationMap = true
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(store.accentPrimary.opacity(0.16))
                                    .frame(width: 38, height: 38)
                                Image(systemName: "map.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(store.accentPrimary)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(store.tr(.celebrationMapButton))
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text(store.tr(.venuesCount(venues.count)))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(store.accentPrimary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .candleCardStyle()
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
            }
        }
    }
    
    private func venueCardView(venue: CelebrationVenue, person: BirthdayPerson) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Top row: Pin icon, Year badge, and action buttons
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(store.accentPrimary.opacity(0.14))
                        .frame(width: 34, height: 34)
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(store.accentPrimary)
                }
                
                if let dateStr = venue.formattedDateTag {
                    HStack(spacing: 3) {
                        Image(systemName: "calendar")
                            .font(.system(size: 9, weight: .bold))
                        Text(dateStr)
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                    }
                    .foregroundColor(store.accentPrimary)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(store.accentPrimary.opacity(0.12))
                    .clipShape(Capsule())
                }
                
                Spacer()
                
                // Actions: Edit & Delete (larger touch targets and icons)
                HStack(spacing: 8) {
                    Button {
                        editingVenueId = venue.id
                        venueNameInput = venue.name
                        venueYearInput = venue.formattedDateTag ?? CelebrationVenue.currentDateTag()
                        venueNotesInput = venue.notes ?? ""
                        showingVenueSheet = true
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(store.accentPrimary)
                            .frame(width: 36, height: 36)
                            .background(store.accentPrimary.opacity(0.14))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        venueToDelete = venue
                        showingDeleteVenueAlert = true
                    } label: {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.red)
                            .frame(width: 36, height: 36)
                            .background(Color.red.opacity(0.14))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Name & Notes
            VStack(alignment: .leading, spacing: 3) {
                Text(venue.displayName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let notes = venue.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Spacer().frame(height: 14)
                }
            }
            
            Spacer(minLength: 2)
            
            // Open in Apple Maps quick action
            Button {
                openMaps(for: venue.displayName)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.system(size: 11, weight: .bold))
                    Text(store.tr(.openInMaps))
                        .font(.system(size: 12, weight: .bold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(store.accentPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .frame(width: 270, height: 175)
        .candleCardStyle()
    }
    
    private func addMoreVenuesCard(person: BirthdayPerson) -> some View {
        Button {
            CandleTheme.hapticSelection()
            editingVenueId = nil
            venueNameInput = ""
            venueYearInput = CelebrationVenue.currentDateTag()
            venueNotesInput = ""
            showingVenueSheet = true
        } label: {
            VStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(store.accentPrimary)
                Text(store.tr(.addVenueBtn))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(store.accentPrimary)
            }
            .frame(width: 130, height: 175)
            .background(CandleTheme.cardBackground.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(store.accentPrimary.opacity(0.35), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
            )
        }
        .buttonStyle(.plain)
    }
    
    private func venueSheetView(person: BirthdayPerson) -> some View {
        NavigationStack {
            Form {
                Section {
                    TextField(store.tr(.venueNamePlaceholder), text: $venueNameInput)
                    
                    Button {
                        isLocating = true
                        LocationHelper.shared.requestCurrentLocation { result in
                            isLocating = false
                            switch result {
                            case .success(let data):
                                venueNameInput = data.name
                                CandleTheme.hapticNotification(type: .success)
                            case .failure(let err):
                                locationErrorMessage = err.localizedMessage(for: store.currentLanguage)
                                CandleTheme.hapticNotification(type: .warning)
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            if isLocating {
                                ProgressView()
                            } else {
                                Image(systemName: "location.fill")
                                    .foregroundColor(store.accentPrimary)
                            }
                            Text(isLocating ? store.tr(.locating) : store.tr(.useCurrentLocationBtn))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(store.accentPrimary)
                        }
                    }
                    .disabled(isLocating)
                }
                
                Section {
                    TextField(store.tr(.venueYearPlaceholder), text: $venueYearInput)
                        .keyboardType(.numbersAndPunctuation)
                    
                    TextField(store.tr(.venueNotesPlaceholder), text: $venueNotesInput)
                }
            }
            .navigationTitle(editingVenueId == nil ? store.tr(.addVenueBtn) : store.tr(.editVenueBtn))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(store.tr(.cancel)) {
                        showingVenueSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(store.tr(.save)) {
                        saveVenueInput(for: person)
                        showingVenueSheet = false
                    }
                    .disabled(venueNameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func saveVenueInput(for person: BirthdayPerson) {
        CandleTheme.hapticSelection()
        var updated = person
        let trimmedName = venueNameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let trimmedDate = venueYearInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalDateTag = trimmedDate.isEmpty ? CelebrationVenue.currentDateTag() : trimmedDate
        let parsedYear = Int(trimmedDate)
        let trimmedNotes = venueNotesInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalNotes = trimmedNotes.isEmpty ? nil : trimmedNotes
        
        var parsedLat: Double? = nil
        var parsedLon: Double? = nil
        if let directCoords = LocationHelper.parseCoordinates(from: trimmedName) {
            parsedLat = directCoords.latitude
            parsedLon = directCoords.longitude
        }
        
        if let editId = editingVenueId, let idx = updated.celebrationVenues.firstIndex(where: { $0.id == editId }) {
            updated.celebrationVenues[idx].name = trimmedName
            updated.celebrationVenues[idx].year = parsedYear
            updated.celebrationVenues[idx].dateTag = finalDateTag
            updated.celebrationVenues[idx].notes = finalNotes
            if parsedLat != nil {
                updated.celebrationVenues[idx].latitude = parsedLat
                updated.celebrationVenues[idx].longitude = parsedLon
            }
        } else {
            let newVenue = CelebrationVenue(
                name: trimmedName,
                latitude: parsedLat,
                longitude: parsedLon,
                year: parsedYear,
                dateTag: finalDateTag,
                notes: finalNotes
            )
            updated.celebrationVenues.append(newVenue)
        }
        
        updated.celebrationLocation = updated.celebrationVenues.first?.displayName
        store.updatePerson(updated)
        
        // Asynchronous geocoding if coordinates not yet available
        if parsedLat == nil {
            Task {
                if let coord = await LocationHelper.shared.geocodeAddress(trimmedName) {
                    await MainActor.run {
                        if var cur = store.people.first(where: { $0.id == person.id }) {
                            if let editId = editingVenueId, let i = cur.celebrationVenues.firstIndex(where: { $0.id == editId }) {
                                cur.celebrationVenues[i].latitude = coord.latitude
                                cur.celebrationVenues[i].longitude = coord.longitude
                            } else if let lastIdx = cur.celebrationVenues.indices.last {
                                cur.celebrationVenues[lastIdx].latitude = coord.latitude
                                cur.celebrationVenues[lastIdx].longitude = coord.longitude
                            }
                            store.updatePerson(cur)
                        }
                    }
                }
            }
        }
    }
    
    private func fetchAndSaveCurrentLocationAsVenue(for person: BirthdayPerson) {
        CandleTheme.hapticSelection()
        isLocating = true
        LocationHelper.shared.requestCurrentLocation { result in
            isLocating = false
            switch result {
            case .success(let data):
                var updated = person
                let currentYear = Calendar.current.component(.year, from: Date())
                let newVenue = CelebrationVenue(
                    name: data.name,
                    latitude: data.latitude,
                    longitude: data.longitude,
                    year: currentYear,
                    dateTag: CelebrationVenue.currentDateTag()
                )
                updated.celebrationVenues.append(newVenue)
                updated.celebrationLocation = updated.celebrationVenues.first?.displayName
                store.updatePerson(updated)
                CandleTheme.hapticNotification(type: .success)
            case .failure(let err):
                locationErrorMessage = err.localizedMessage(for: store.currentLanguage)
                CandleTheme.hapticNotification(type: .warning)
            }
        }
    }
    
    private func deleteVenue(_ venue: CelebrationVenue, from person: BirthdayPerson) {
        CandleTheme.hapticSelection()
        var updated = person
        updated.celebrationVenues.removeAll(where: { $0.id == venue.id })
        updated.celebrationLocation = updated.celebrationVenues.first?.displayName
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            store.updatePerson(updated)
        }
    }
    
    private func openMaps(for location: String) {
        let trimmed = location.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        CandleTheme.hapticImpact(style: .medium)
        let escaped = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? trimmed
        if let url = URL(string: "maps://?q=\(escaped)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else if let webUrl = URL(string: "https://maps.apple.com/?q=\(escaped)") {
            UIApplication.shared.open(webUrl, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - Celebration Memory Photos
    @ViewBuilder
    private func memorySection(person: BirthdayPerson) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(store.tr(.memoryPhotoTitle), systemImage: "photo.stack.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.secondary)
                if !person.memoryPhotos.isEmpty {
                    Text(store.tr(.memoryPhotosCount(person.memoryPhotos.count)))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(store.accentPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(store.accentPrimary.opacity(0.12))
                        .clipShape(Capsule())
                }
                Spacer()
                Button {
                    CandleTheme.hapticSelection()
                    showingPhotoSourceDialog = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                        Text(store.tr(.addMorePhotosBtn))
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(store.accentPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(store.accentPrimary.opacity(0.12))
                    .clipShape(Capsule())
                }
            }
            if person.memoryPhotos.isEmpty {
                Button {
                    CandleTheme.hapticSelection()
                    showingPhotoSourceDialog = true
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(store.accentPrimary.opacity(0.12))
                                .frame(width: 46, height: 46)
                            Image(systemName: "camera.badge.ellipsis")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(store.accentPrimary)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(store.tr(.addMemoryPhotoBtn))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.primary)
                            Text(store.tr(.memoryPhotoSubtitle))
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(store.accentPrimary)
                    }
                    .padding(14)
                    .candleCardStyle()
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(store.accentPrimary.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    )
                }
                .buttonStyle(.plain)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(person.memoryPhotos) { photo in
                            memoryPhotoCard(photo: photo, person: person)
                        }
                        Button {
                            CandleTheme.hapticSelection()
                            showingPhotoSourceDialog = true
                        } label: {
                            VStack(spacing: 10) {
                                Image(systemName: "plus.viewfinder")
                                    .font(.system(size: 30, weight: .light))
                                    .foregroundColor(store.accentPrimary)
                                Text(store.tr(.addMorePhotosBtn))
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 140, height: 260)
                            .background(CandleTheme.cardBackground.opacity(0.6))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(store.accentPrimary.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    private func memoryPhotoCard(photo: MemoryPhoto, person: BirthdayPerson) -> some View {
        let isEditing = (editingPhotoId == photo.id)
        let uiImage = UIImage(data: photo.imageData)
        return VStack(spacing: 10) {
            Button {
                selectedFullScreenPhoto = photo
            } label: {
                if let uiImage = uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 220, height: 180)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                } else {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: 220, height: 180)
                }
            }
            .buttonStyle(.plain)
            VStack(alignment: .leading, spacing: 6) {
                if isEditing {
                    HStack(spacing: 8) {
                        TextField(store.tr(.memoryCaptionPlaceholder), text: $memoryCaptionInput)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 12))
                        Button {
                            CandleTheme.hapticSelection()
                            saveMemoryCaption(for: person, photoId: photo.id, caption: memoryCaptionInput)
                            editingPhotoId = nil
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(store.accentPrimary)
                                .font(.system(size: 24))
                                .frame(width: 34, height: 34)
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(minHeight: 34)
                } else {
                    HStack(alignment: .center, spacing: 8) {
                        if !photo.caption.isEmpty {
                            Text("“\(photo.caption)”")
                                .font(.system(size: 13, weight: .medium, design: .serif))
                                .italic()
                                .foregroundColor(.primary)
                                .lineLimit(2)
                        } else {
                            Text(store.tr(.memoryCaptionPlaceholder))
                                .font(.system(size: 12))
                                .foregroundColor(.secondary.opacity(0.7))
                        }
                        Spacer(minLength: 4)
                        HStack(spacing: 8) {
                            Button {
                                CandleTheme.hapticSelection()
                                memoryCaptionInput = photo.caption
                                editingPhotoId = photo.id
                            } label: {
                                Image(systemName: "pencil")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(store.accentPrimary)
                                    .frame(width: 34, height: 34)
                                    .background(store.accentPrimary.opacity(0.14))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            Button(role: .destructive) {
                                CandleTheme.hapticSelection()
                                removeMemoryPhoto(for: person, photoId: photo.id)
                            } label: {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.red)
                                    .frame(width: 34, height: 34)
                                    .background(Color.red.opacity(0.14))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(minHeight: 34)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        CandleTheme.hapticSelection()
                        memoryCaptionInput = photo.caption
                        editingPhotoId = photo.id
                    }
                }
                Text(dateFormatter.string(from: photo.date))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .frame(width: 220)
        }
        .padding(12)
        .candleCardStyle()
    }
    
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.locale = Locale(identifier: store.currentLanguage.resolvedCode)
        return df
    }
    
    private func removeMemoryPhoto(for person: BirthdayPerson, photoId: UUID) {
        CandleTheme.hapticSelection()
        var updated = person
        updated.memoryPhotos.removeAll(where: { $0.id == photoId })
        store.updatePerson(updated)
    }
    
    private func saveMemoryCaption(for person: BirthdayPerson, photoId: UUID, caption: String) {
        CandleTheme.hapticSelection()
        var updated = person
        if let idx = updated.memoryPhotos.firstIndex(where: { $0.id == photoId }) {
            let trimmed = caption.trimmingCharacters(in: .whitespacesAndNewlines)
            updated.memoryPhotos[idx].caption = trimmed
            store.updatePerson(updated)
        }
    }
    
    private func handlePickedMemoryImages(_ images: [UIImage]) {
        guard !images.isEmpty, var p = person else { return }
        for img in images {
            if let data = img.jpegData(compressionQuality: 0.8) {
                let newPhoto = MemoryPhoto(imageData: data, caption: "", date: Date())
                p.memoryPhotos.append(newPhoto)
            }
        }
        store.updatePerson(p)
        CandleTheme.hapticNotification(type: .success)
    }
    
    private func handlePickedMemoryImage(_ img: UIImage?) {
        guard let img = img else { return }
        handlePickedMemoryImages([img])
    }
    
    private func togglePrivacy(for person: BirthdayPerson) {
        CandleTheme.hapticSelection()
        var updated = person
        updated.isPrivate.toggle()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            store.updatePerson(updated)
        }
    }
    
    private func notificationsSection(person: BirthdayPerson) -> some View {
        let timeStr = String(format: "%02d:%02d", store.settings.notificationHour, store.settings.notificationMinute)
        
        return VStack(alignment: .leading, spacing: 12) {
            Label(store.tr(.activeReminders), systemImage: "bell.badge.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                // Same day notification
                HStack {
                    Image(systemName: person.notifyOnSameDay ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(person.notifyOnSameDay ? store.accentPrimary : .secondary.opacity(0.4))
                        .font(.system(size: 18))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.onEventDayLabel(for: person))
                            .font(.system(size: 15, weight: .semibold))
                        Text(store.tr(.atTime(timeStr)))
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(person.notifyOnSameDay ? store.tr(.active) : store.tr(.disabled))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(person.notifyOnSameDay ? store.accentPrimary : .secondary)
                }
                .padding(12)
                .background(CandleTheme.subCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                
                // Advance notification
                HStack {
                    Image(systemName: person.notifyInAdvance ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(person.notifyInAdvance ? store.accentSecondary : .secondary.opacity(0.4))
                        .font(.system(size: 18))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.tr(.advanceReminderGift))
                            .font(.system(size: 15, weight: .semibold))
                        Text(store.tr(.advanceDaysBefore(person.advanceDays, timeStr)))
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(person.notifyInAdvance ? "-\(person.advanceDays)d" : store.tr(.disabled))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(person.notifyInAdvance ? store.accentSecondary : .secondary)
                }
                .padding(12)
                .background(CandleTheme.subCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(16)
        .candleCardStyle()
    }
    
    private func wishesButton(person: BirthdayPerson) -> some View {
        Button {
            CandleTheme.hapticImpact(style: .medium)
            showingWishesSheet = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 15, weight: .bold))
                Text(store.tr(.sendWishesBtn))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(store.accentGradient)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: store.accentPrimary.opacity(0.35), radius: 8, x: 0, y: 4)
        }
        .padding(.top, 4)
    }
}

// MARK: - Smart Wishes Sheet
public struct SmartWishesSheetView: View {
    @ObservedObject var store: BirthdayStore
    let person: BirthdayPerson
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTone: WishesTone
    @State private var customMessageText: String
    @State private var showCopiedAlert = false
    @State private var showSavedAlert = false
    
    public init(store: BirthdayStore, person: BirthdayPerson) {
        self.store = store
        self.person = person
        let savedCustom = person.customWishMessage?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !savedCustom.isEmpty {
            _selectedTone = State(initialValue: .custom)
            _customMessageText = State(initialValue: savedCustom)
        } else {
            let initialTone = person.lastWishToneSent ?? .warm
            _selectedTone = State(initialValue: initialTone)
            _customMessageText = State(initialValue: "")
        }
    }
    
    private var currentMessage: String {
        if selectedTone == .custom {
            let trimmed = customMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                return trimmed
            }
        }
        return selectedTone.template(
            name: person.name,
            age: person.upcomingAge(),
            eventType: person.eventType,
            recurrence: person.recurrence,
            mesiversarioCount: person.upcomingMesiversarioNumber(),
            customMessage: customMessageText,
            lang: store.currentLanguage
        )
    }
    
    private func saveCustomWish() {
        var updated = person
        let trimmed = customMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.customWishMessage = trimmed.isEmpty ? nil : trimmed
        store.updatePerson(updated)
        CandleTheme.hapticNotification(type: .success)
        withAnimation {
            showSavedAlert = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                showSavedAlert = false
            }
        }
    }
    
    private func deleteCustomWish() {
        var updated = person
        updated.customWishMessage = nil
        customMessageText = ""
        let fallbackTone = person.lastWishToneSent ?? .warm
        store.updatePerson(updated)
        CandleTheme.hapticNotification(type: .warning)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            selectedTone = fallbackTone
        }
    }
    
    private func recordWishSent() {
        var updated = person
        if selectedTone == .custom {
            let trimmed = customMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                updated.customWishMessage = trimmed
            }
        } else {
            updated.lastWishToneSent = selectedTone
        }
        store.updatePerson(updated)
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                CandleTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Tone selector
                        VStack(alignment: .leading, spacing: 10) {
                            Text(store.tr(.wishesToneTitle))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 8) {
                                ForEach(WishesTone.allCases) { tone in
                                    let isSelected = (tone == selectedTone)
                                    Button {
                                        CandleTheme.hapticSelection()
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedTone = tone
                                        }
                                    } label: {
                                        HStack(spacing: 5) {
                                            Text(tone.emoji)
                                            Text(tone.localizedName(for: store.currentLanguage))
                                                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                                        }
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 10)
                                        .frame(maxWidth: .infinity)
                                        .background(isSelected ? store.accentPrimary.opacity(0.15) : CandleTheme.subCardBackground)
                                        .foregroundColor(isSelected ? store.accentPrimary : .primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(isSelected ? store.accentPrimary : Color.clear, lineWidth: 1.5)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        
                        // Custom Editor or Message Preview Box
                        if selectedTone == .custom {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "square.and.pencil")
                                        .foregroundColor(store.accentPrimary)
                                        .font(.system(size: 15, weight: .bold))
                                    Text(store.tr(.customWishTitle))
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    if showSavedAlert {
                                        Text(store.tr(.customWishSaved))
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.green)
                                            .transition(.opacity)
                                    }
                                }
                                
                                ZStack(alignment: .topLeading) {
                                    if customMessageText.isEmpty {
                                        Text(store.tr(.customWishPlaceholder))
                                            .font(.system(size: 15))
                                            .foregroundColor(.secondary.opacity(0.6))
                                            .padding(.top, 8)
                                            .padding(.leading, 4)
                                    }
                                    TextEditor(text: $customMessageText)
                                        .font(.system(size: 15, weight: .medium, design: .rounded))
                                        .frame(minHeight: 100)
                                        .scrollContentBackground(.hidden)
                                        .background(Color.clear)
                                }
                                
                                HStack {
                                    if person.customWishMessage != nil || !customMessageText.isEmpty {
                                        Button(role: .destructive) {
                                            deleteCustomWish()
                                        } label: {
                                            HStack(spacing: 4) {
                                                Image(systemName: "trash")
                                                Text(store.tr(.customWishDeleteBtn))
                                            }
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.red)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 7)
                                            .background(Color.red.opacity(0.12))
                                            .clipShape(Capsule())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        saveCustomWish()
                                    } label: {
                                        HStack(spacing: 5) {
                                            Image(systemName: showSavedAlert ? "checkmark.circle.fill" : "arrow.down.doc.fill")
                                            Text(showSavedAlert ? store.tr(.customWishSaved) : store.tr(.customWishSaveBtn))
                                        }
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(showSavedAlert ? .green : store.accentPrimary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 7)
                                        .background(store.accentPrimary.opacity(0.12))
                                        .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(customMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                }
                            }
                            .padding(16)
                            .candleCardStyle()
                        } else {
                            // Message Preview Box
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "quote.opening")
                                        .foregroundColor(store.accentPrimary)
                                        .font(.system(size: 16, weight: .bold))
                                    Text(person.name)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                
                                Text(currentMessage)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.primary)
                                    .lineSpacing(5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(20)
                            .candleCardStyle()
                        }
                        
                        // Actions: Share and Copy
                        VStack(spacing: 12) {
                            ShareLink(item: currentMessage) {
                                HStack(spacing: 8) {
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 15, weight: .bold))
                                    Text(store.tr(.sendWishesBtn))
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(store.accentGradient)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: store.accentPrimary.opacity(0.35), radius: 8, x: 0, y: 4)
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                recordWishSent()
                            })
                            
                            Button {
                                recordWishSent()
                                UIPasteboard.general.string = currentMessage
                                CandleTheme.hapticNotification(type: .success)
                                withAnimation {
                                    showCopiedAlert = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                    withAnimation {
                                        showCopiedAlert = false
                                    }
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: showCopiedAlert ? "checkmark.circle.fill" : "doc.on.doc")
                                        .foregroundColor(showCopiedAlert ? .green : store.accentPrimary)
                                        .font(.system(size: 15, weight: .bold))
                                    Text(showCopiedAlert ? store.tr(.copiedToast) : store.tr(.wishesCopyBtn))
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(showCopiedAlert ? .green : store.accentPrimary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(CandleTheme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(store.tr(.sendWishesBtn))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(store.tr(.close)) {
                        dismiss()
                    }
                }
            }
            .onDisappear {
                if selectedTone == .custom {
                    let trimmed = customMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmed != (person.customWishMessage ?? "") {
                        var updated = person
                        updated.customWishMessage = trimmed.isEmpty ? nil : trimmed
                        store.updatePerson(updated)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Full Screen Avatar with Pinch-to-Zoom & Swipe-Down-to-Dismiss
fileprivate struct FullScreenAvatarDetailView: View {
    let person: BirthdayPerson
    let store: BirthdayStore
    let onDismiss: () -> Void
    let loadedImage: UIImage?
    
    init(person: BirthdayPerson, store: BirthdayStore, onDismiss: @escaping () -> Void) {
        self.person = person
        self.store = store
        self.onDismiss = onDismiss
        if let data = person.avatarImageData {
            self.loadedImage = UIImage(data: data)
        } else {
            self.loadedImage = nil
        }
    }
    
    // Zoom state
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var panOffset: CGSize = .zero
    @State private var lastPanOffset: CGSize = .zero
    @State private var isPinching = false
    
    // Drag down to dismiss state
    @State private var dragDownOffset: CGFloat = 0.0
    @State private var isDraggingDown = false
    @State private var lastTapDate: Date = .distantPast
    
    private var isZoomed: Bool {
        scale > 1.05
    }
    
    private var backgroundOpacity: Double {
        let offset = max(0.0, Double(dragDownOffset))
        return max(0.0, 1.0 - (offset / 320.0))
    }
    
    private var topOverlayOpacity: Double {
        if isZoomed { return 0.0 }
        let offset = max(0.0, Double(dragDownOffset))
        return max(0.0, 1.0 - (offset / 320.0))
    }
    
    var body: some View {
        ZStack {
            // Dismissible dark background
            Color.black
                .opacity(backgroundOpacity)
                .ignoresSafeArea()
            
            // Image / Avatar with Pinch to zoom and fluid drag-down to dismiss
            avatarContent
                .scaleEffect(scale)
                .offset(
                    x: isZoomed ? panOffset.width : 0,
                    y: isZoomed ? panOffset.height : dragDownOffset
                )
                .contentShape(Rectangle())
                .simultaneousGesture(magnificationGesture)
                .simultaneousGesture(dragGesture)
            
            // Top and Bottom overlays
            VStack {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(person.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        HStack(spacing: 6) {
                            Text(person.categoryEmoji)
                            Text(person.categoryDisplayName(for: store.currentLanguage))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.leading, 20)
                    .padding(.top, 16)
                    
                    Spacer()
                    
                    Button {
                        CandleTheme.hapticSelection()
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.85))
                            .padding(20)
                    }
                }
                
                Spacer()
                
                if !isZoomed {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.compact.down")
                            .font(.system(size: 13, weight: .bold))
                        Text(store.tr(.swipeDownToClose))
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.55))
                    .padding(.bottom, 24)
                }
            }
            .opacity(topOverlayOpacity)
        }
        .animation(isDraggingDown ? nil : .spring(response: 0.32, dampingFraction: 1.0), value: dragDownOffset)
    }
    
    @ViewBuilder
    private var avatarContent: some View {
        if let img = loadedImage {
            Image(uiImage: img)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
        } else {
            VStack(spacing: 24) {
                AvatarCircleView(person: person, size: 220)
                    .shadow(color: CandleTheme.avatarPrimaryColor(for: person.colorIndex).opacity(0.5), radius: 25, x: 0, y: 10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    // MARK: - Gestures
    
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                isPinching = true
                let newScale = lastScale * value
                scale = min(max(newScale, 1.0), 5.0)
            }
            .onEnded { _ in
                lastScale = scale
                if scale <= 1.05 {
                    withAnimation(.spring(response: 0.32, dampingFraction: 1.0)) {
                        scale = 1.0
                        lastScale = 1.0
                        panOffset = .zero
                        lastPanOffset = .zero
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    isPinching = false
                }
            }
    }
    
    // Unified drag gesture: handles panning when zoomed, and smooth pull-down when unzoomed
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if isPinching { return }
                
                if isZoomed {
                    panOffset = CGSize(
                        width: lastPanOffset.width + value.translation.width,
                        height: lastPanOffset.height + value.translation.height
                    )
                } else {
                    isDraggingDown = true
                    if value.translation.height > 0 {
                        dragDownOffset = value.translation.height
                    } else {
                        dragDownOffset = value.translation.height * 0.15
                    }
                }
            }
            .onEnded { value in
                if isPinching { return }
                
                // Double tap in-place detection without conflicting gesture recognizer
                let distSq = value.translation.width * value.translation.width + value.translation.height * value.translation.height
                if distSq < 36 {
                    let now = Date()
                    if now.timeIntervalSince(lastTapDate) < 0.32 {
                        handleDoubleTap()
                        lastTapDate = .distantPast
                        isDraggingDown = false
                        dragDownOffset = 0
                        return
                    }
                    lastTapDate = now
                }
                
                if isZoomed {
                    let screenW = UIScreen.main.bounds.width
                    let screenH = UIScreen.main.bounds.height
                    let maxPanX = max(0, (screenW * (scale - 1.0)) / 2.0)
                    let maxPanY = max(0, (screenH * (scale - 1.0)) / 2.0)
                    let boundedX = min(max(panOffset.width, -maxPanX), maxPanX)
                    let boundedY = min(max(panOffset.height, -maxPanY), maxPanY)
                    withAnimation(.spring(response: 0.32, dampingFraction: 1.0)) {
                        panOffset = CGSize(width: boundedX, height: boundedY)
                        lastPanOffset = panOffset
                    }
                } else {
                    let dy = value.translation.height
                    let dx = abs(value.translation.width)
                    let vy = value.predictedEndTranslation.height
                    
                    if (dy > 120 && dy > dx) || vy > 260 {
                        isDraggingDown = false
                        CandleTheme.hapticSelection()
                        onDismiss()
                    } else {
                        isDraggingDown = false
                        dragDownOffset = 0
                    }
                }
            }
    }
    
    private func handleDoubleTap() {
        CandleTheme.hapticSelection()
        withAnimation(.spring(response: 0.32, dampingFraction: 1.0)) {
            if scale > 1.1 {
                scale = 1.0
                lastScale = 1.0
                panOffset = .zero
                lastPanOffset = .zero
            } else {
                scale = 2.5
                lastScale = 2.5
            }
        }
    }
}
