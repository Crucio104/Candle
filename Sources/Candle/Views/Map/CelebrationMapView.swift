import SwiftUI
import MapKit
import CoreLocation

// MARK: - Map Annotation Model

public final class CelebrationAnnotation: NSObject, MKAnnotation, @unchecked Sendable {
    public let person: BirthdayPerson
    public let venue: CelebrationVenue
    public let coordinate: CLLocationCoordinate2D
    public let title: String?
    public let subtitle: String?
    
    public init(person: BirthdayPerson, venue: CelebrationVenue, coordinate: CLLocationCoordinate2D) {
        self.person = person
        self.venue = venue
        self.coordinate = coordinate
        self.title = person.name
        
        var subParts: [String] = [venue.displayName]
        if let dt = venue.formattedDateTag {
            subParts.append("(\(dt))")
        }
        if let n = venue.notes, !n.isEmpty {
            subParts.append("• \(n)")
        }
        self.subtitle = subParts.joined(separator: " ")
        super.init()
    }
}

// MARK: - Filters

public enum CelebrationMapFilter: String, CaseIterable, Identifiable {
    case all
    case upcoming
    case birthdays
    case anniversaries
    case specials
    
    public var id: String { rawValue }
    
    @MainActor
    public func localizedTitle(store: BirthdayStore) -> String {
        switch self {
        case .all: return store.tr(.mapFilterAll)
        case .upcoming: return store.tr(.mapFilterUpcoming)
        case .birthdays: return store.tr(.mapFilterBirthdays)
        case .anniversaries: return store.tr(.mapFilterAnniversaries)
        case .specials: return store.tr(.mapFilterSpecials)
        }
    }
}

// MARK: - Native MKMapView Representable

public struct NativeCelebrationMapView: UIViewRepresentable {
    public let annotations: [CelebrationAnnotation]
    @Binding public var selectedAnnotation: CelebrationAnnotation?
    public let targetCoordinate: CLLocationCoordinate2D?
    public let tintColor: UIColor
    
    public init(
        annotations: [CelebrationAnnotation],
        selectedAnnotation: Binding<CelebrationAnnotation?>,
        targetCoordinate: CLLocationCoordinate2D? = nil,
        tintColor: UIColor = .systemOrange
    ) {
        self.annotations = annotations
        self._selectedAnnotation = selectedAnnotation
        self.targetCoordinate = targetCoordinate
        self.tintColor = tintColor
    }
    
    public func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.isPitchEnabled = true
        mapView.isRotateEnabled = true
        
        let defaultCenter = CLLocationCoordinate2D(latitude: 41.9028, longitude: 12.4964)
        mapView.setRegion(MKCoordinateRegion(center: defaultCenter, span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)), animated: false)
        return mapView
    }
    
    public func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.parent = self
        
        // Synchronize annotations
        let current = mapView.annotations.compactMap { $0 as? CelebrationAnnotation }
        let currentIds = Set(current.map { $0.venue.id })
        let newIds = Set(annotations.map { $0.venue.id })
        
        if currentIds != newIds {
            mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })
            mapView.addAnnotations(annotations)
            
            if targetCoordinate == nil, !annotations.isEmpty {
                mapView.showAnnotations(annotations, animated: true)
            }
        }
        
        // Pan/Zoom to target coordinate if requested
        if let target = targetCoordinate {
            let currentCenter = mapView.region.center
            let latDiff = abs(currentCenter.latitude - target.latitude)
            let lonDiff = abs(currentCenter.longitude - target.longitude)
            if latDiff > 0.0001 || lonDiff > 0.0001 {
                let region = MKCoordinateRegion(center: target, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
                mapView.setRegion(region, animated: true)
            }
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: NativeCelebrationMapView
        
        init(_ parent: NativeCelebrationMapView) {
            self.parent = parent
        }
        
        public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }
            
            guard let celebrationAnn = annotation as? CelebrationAnnotation else { return nil }
            
            let reuseId = "CelebrationMarkerView"
            let marker = (mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView)
                ?? MKMarkerAnnotationView(annotation: celebrationAnn, reuseIdentifier: reuseId)
            
            marker.annotation = celebrationAnn
            marker.canShowCallout = false
            marker.markerTintColor = parent.tintColor
            marker.glyphText = celebrationAnn.person.eventType.emoji
            marker.titleVisibility = .adaptive
            marker.animatesWhenAdded = true
            return marker
        }
        
        public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let ann = view.annotation as? CelebrationAnnotation else { return }
            CandleTheme.hapticSelection()
            parent.selectedAnnotation = ann
            let region = MKCoordinateRegion(center: ann.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015))
            mapView.setRegion(region, animated: true)
        }
    }
}

// MARK: - Celebration Map View

public struct CelebrationMapView: View {
    @ObservedObject var store: BirthdayStore
    public var initialFocusPersonId: UUID? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedFilter: CelebrationMapFilter = .all
    @State private var selectedAnnotation: CelebrationAnnotation? = nil
    @State private var showingPersonDetail: BirthdayPerson? = nil
    @State private var annotations: [CelebrationAnnotation] = []
    @State private var targetCoordinate: CLLocationCoordinate2D? = nil
    @State private var isGeocoding = false
    
    public init(store: BirthdayStore, initialFocusPersonId: UUID? = nil) {
        self.store = store
        self.initialFocusPersonId = initialFocusPersonId
    }
    
    private var filteredAnnotations: [CelebrationAnnotation] {
        switch selectedFilter {
        case .all:
            return annotations
        case .upcoming:
            return annotations.filter { $0.person.daysRemaining() <= 30 }
        case .birthdays:
            return annotations.filter { $0.person.eventType == .birthday }
        case .anniversaries:
            return annotations.filter { $0.person.eventType == .anniversary }
        case .specials:
            return annotations.filter { $0.person.eventType == .special || $0.person.eventType == .nameday }
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Map layer
                NativeCelebrationMapView(
                    annotations: filteredAnnotations,
                    selectedAnnotation: $selectedAnnotation,
                    targetCoordinate: targetCoordinate,
                    tintColor: UIColor(store.accentPrimary)
                )
                .ignoresSafeArea(edges: .bottom)
                
                // Top overlay: filter pills
                VStack(spacing: 12) {
                    filterChipsBar
                    
                    if filteredAnnotations.isEmpty && !isGeocoding {
                        emptyStateCard
                    }
                }
                .padding(.top, 8)
                
                // Bottom floating card for selected celebration venue or swipeable carousel
                VStack {
                    Spacer()
                    if let ann = selectedAnnotation {
                        selectedVenueCard(annotation: ann)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else if !filteredAnnotations.isEmpty {
                        bottomVenuesCarousel
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.bottom, 24)
            }
            .navigationTitle(store.tr(.celebrationMapTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 8) {
                        // Badge count of venues
                        Text("\(filteredAnnotations.count)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 3)
                            .background(store.accentPrimary)
                            .clipShape(Capsule())
                        
                        // Center on user location
                        Button {
                            centerOnCurrentLocation()
                        } label: {
                            Image(systemName: "location.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(store.accentPrimary)
                                .frame(width: 32, height: 32)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(Circle())
                        }
                    }
                }
            }
            .sheet(item: $showingPersonDetail) { person in
                BirthdayDetailView(store: store, personId: person.id)
            }
            .task {
                await loadAndGeocodePins()
            }
            .onChange(of: store.people) { _, _ in
                Task {
                    await loadAndGeocodePins()
                }
            }
        }
    }
    
    // MARK: - Filter Chips Bar
    
    private var filterChipsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(CelebrationMapFilter.allCases) { filter in
                    let isSelected = selectedFilter == filter
                    Button {
                        CandleTheme.hapticSelection()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            selectedFilter = filter
                            if let ann = selectedAnnotation, !filteredAnnotations.contains(where: { $0.venue.id == ann.venue.id }) {
                                selectedAnnotation = nil
                            }
                        }
                    } label: {
                        Text(filter.localizedTitle(store: store))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(isSelected ? .white : .primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Group {
                                    if isSelected {
                                        store.accentPrimary
                                    } else {
                                        Color(.systemBackground).opacity(0.85)
                                    }
                                }
                            )
                            .clipShape(Capsule())
                            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Selected Venue Card
    
    private func selectedVenueCard(annotation: CelebrationAnnotation) -> some View {
        let person = annotation.person
        let venue = annotation.venue
        
        return VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Avatar
                if let avatarData = person.avatarImageData, let uiImage = UIImage(data: avatarData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(store.accentPrimary.opacity(0.15))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Text(person.name.prefix(1).uppercased())
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(store.accentPrimary)
                        )
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(person.name)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Text(person.eventType.emoji)
                            .font(.system(size: 14))
                        
                        if let dt = venue.formattedDateTag {
                            Text(dt)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(store.accentPrimary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(store.accentPrimary.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 11))
                            .foregroundColor(store.accentPrimary)
                        Text(venue.displayName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                    }
                    
                    if let notes = venue.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Days countdown badge
                VStack(spacing: 2) {
                    if person.isToday {
                        Text(store.tr(.todayBadge))
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .clipShape(Capsule())
                    } else {
                        Text("\(person.daysRemaining())")
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .foregroundColor(store.accentPrimary)
                        Text(store.tr(.daysShort(person.daysRemaining())))
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Close button
                Button {
                    withAnimation {
                        selectedAnnotation = nil
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
            
            Divider()
            
            // Action buttons: "Indicazioni" & "Dettagli"
            HStack(spacing: 10) {
                // Directions button
                Button {
                    openDirections(for: venue, fallbackPerson: person)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                            .font(.system(size: 13, weight: .bold))
                        Text(store.tr(.mapGetDirections))
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(store.accentGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                
                // Details button
                Button {
                    showingPersonDetail = person
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 13, weight: .semibold))
                        Text(store.tr(.details))
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.18), radius: 16, x: 0, y: 6)
        )
        .padding(.horizontal, 16)
    }
    
    // MARK: - Bottom Carousel
    
    private var bottomVenuesCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(filteredAnnotations, id: \.venue.id) { ann in
                    Button {
                        CandleTheme.hapticSelection()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            selectedAnnotation = ann
                            targetCoordinate = ann.coordinate
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Text(ann.person.eventType.emoji)
                                .font(.system(size: 20))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(ann.person.name)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                
                                HStack(spacing: 4) {
                                    Text(ann.venue.displayName)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                    
                                    if let dt = ann.venue.formattedDateTag {
                                        Text("(\(dt))")
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundColor(store.accentPrimary)
                                    }
                                }
                            }
                            
                            Spacer(minLength: 4)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(store.accentPrimary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .frame(width: 220)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Empty State Card
    
    private var emptyStateCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "mappin.slash.circle.fill")
                .font(.system(size: 36))
                .foregroundColor(store.accentPrimary.opacity(0.8))
            
            Text(store.tr(.mapNoLocationsTitle))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
            
            Text(store.tr(.mapNoLocationsDesc))
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground).opacity(0.95))
                .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal, 24)
        .padding(.top, 40)
    }
    
    // MARK: - Helper Actions
    
    private func centerOnCurrentLocation() {
        CandleTheme.hapticSelection()
        LocationHelper.shared.requestCurrentLocation { result in
            switch result {
            case .success(let data):
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                    targetCoordinate = data.coordinate
                }
            case .failure:
                break
            }
        }
    }
    
    private func openDirections(for venue: CelebrationVenue, fallbackPerson: BirthdayPerson) {
        CandleTheme.hapticImpact(style: .medium)
        if let lat = venue.latitude, let lon = venue.longitude {
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let placemark = MKPlacemark(coordinate: coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = venue.displayName
            mapItem.openInMaps(launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ])
        } else if !venue.displayName.isEmpty {
            let escaped = venue.displayName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? venue.displayName
            if let url = URL(string: "maps://?daddr=\(escaped)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @MainActor
    private func loadAndGeocodePins() async {
        isGeocoding = true
        var resolved: [CelebrationAnnotation] = []
        
        for person in store.people where person.hasCelebrationLocation {
            var updatedVenues = person.celebrationVenues
            var personMutated = false
            
            for (idx, venue) in person.allVenues.enumerated() {
                if let lat = venue.latitude, let lon = venue.longitude {
                    resolved.append(CelebrationAnnotation(
                        person: person,
                        venue: venue,
                        coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    ))
                } else if !venue.displayName.isEmpty {
                    if let coord = await LocationHelper.shared.geocodeAddress(venue.displayName) {
                        resolved.append(CelebrationAnnotation(
                            person: person,
                            venue: venue,
                            coordinate: coord
                        ))
                        if idx < updatedVenues.count {
                            updatedVenues[idx].latitude = coord.latitude
                            updatedVenues[idx].longitude = coord.longitude
                            personMutated = true
                        }
                    }
                }
            }
            
            if personMutated {
                if var cur = store.people.first(where: { $0.id == person.id }) {
                    cur.celebrationVenues = updatedVenues
                    store.updatePerson(cur)
                }
            }
        }
        
        self.annotations = resolved
        self.isGeocoding = false
        
        if let focusId = initialFocusPersonId, let targetAnn = resolved.first(where: { $0.person.id == focusId }) {
            selectedAnnotation = targetAnn
            targetCoordinate = targetAnn.coordinate
        }
    }
}
