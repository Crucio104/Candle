import SwiftUI

public struct CalendarGridView: View {
    @ObservedObject var store: BirthdayStore
    @Environment(\.dismiss) private var dismiss
    
    public enum CalendarMode: String, CaseIterable, Identifiable {
        case month
        case year
        
        public var id: String { rawValue }
    }
    
    @State private var mode: CalendarMode = .month
    @State private var displayedYear: Int
    @State private var displayedMonth: Int
    @State private var selectedDay: Int
    @State private var selectedPerson: BirthdayPerson? = nil
    @State private var showingAddSheet: Bool = false
    @State private var addInitialDate: Date? = nil
    
    private let calendar = Calendar.current
    
    public init(store: BirthdayStore, initialDate: Date = Date()) {
        self.store = store
        let cal = Calendar.current
        _displayedYear = State(initialValue: cal.component(.year, from: initialDate))
        _displayedMonth = State(initialValue: cal.component(.month, from: initialDate))
        _selectedDay = State(initialValue: cal.component(.day, from: initialDate))
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                CandleTheme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Segmented Control: Month / Year
                    Picker("", selection: $mode) {
                        Text(store.tr(.calendarMonthMode)).tag(CalendarMode.month)
                        Text(store.tr(.calendarYearMode)).tag(CalendarMode.year)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 14)
                    
                    if mode == .month {
                        monthDetailView
                    } else {
                        yearOverviewView
                    }
                }
            }
            .navigationTitle(store.tr(.calendarTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(store.tr(.close)) {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(store.accentPrimary)
                }
            }
            .sheet(item: $selectedPerson) { person in
                BirthdayDetailView(store: store, personId: person.id)
            }
            .sheet(isPresented: $showingAddSheet) {
                AddEditBirthdayView(store: store, preselectedDate: addInitialDate)
            }
        }
    }
    
    // MARK: - Interactive Month View
    
    private var monthDetailView: some View {
        ScrollView {
            VStack(spacing: 18) {
                // Month & Year navigation bar
                HStack {
                    Button {
                        previousMonth()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(store.accentPrimary)
                            .frame(width: 38, height: 38)
                            .background(CandleTheme.cardBackground)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("\(monthName(for: displayedMonth)) \(String(displayedYear))")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button {
                        nextMonth()
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(store.accentPrimary)
                            .frame(width: 38, height: 38)
                            .background(CandleTheme.cardBackground)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                
                // Month Grid (Weekday headers + Day cells)
                VStack(spacing: 10) {
                    // Weekday headers (Mon, Tue, Wed...)
                    HStack(spacing: 0) {
                        ForEach(weekdaySymbols(), id: \.self) { symbol in
                            Text(symbol)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.bottom, 4)
                    
                    // Days of the month
                    let days = daysInGrid(forMonth: displayedMonth, year: displayedYear)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 8) {
                        ForEach(0..<days.count, id: \.self) { index in
                            if let day = days[index] {
                                monthDayCell(day: day)
                            } else {
                                Color.clear
                                    .frame(height: 48)
                            }
                        }
                    }
                }
                .padding(16)
                .candleCardStyle()
                .padding(.horizontal, 20)
                
                // Selected Day Events Section
                selectedDayEventsSection
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
            }
            .padding(.top, 4)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 25)
                .onEnded { value in
                    let hDist = value.translation.width
                    let vDist = value.translation.height
                    if abs(hDist) > abs(vDist) * 1.1 && abs(hDist) > 35 {
                        if hDist < 0 {
                            nextMonth()
                        } else {
                            previousMonth()
                        }
                    }
                }
        )
    }
    
    @ViewBuilder
    private func monthDayCell(day: Int) -> some View {
        let isSelected = (selectedDay == day)
        let isToday = checkIsToday(day: day, month: displayedMonth, year: displayedYear)
        let peopleOnDay = eventsOn(day: day, month: displayedMonth)
        
        Button {
            CandleTheme.hapticSelection()
            withAnimation(.spring(response: 0.25)) {
                selectedDay = day
            }
        } label: {
            VStack(spacing: 3) {
                Text("\(day)")
                    .font(.system(size: 15, weight: isSelected || isToday ? .bold : .medium, design: .rounded))
                    .foregroundColor(
                        isSelected ? .white :
                        (isToday ? store.accentPrimary : .primary)
                    )
                
                // Event indicators (colored dots)
                HStack(spacing: 2) {
                    if !peopleOnDay.isEmpty {
                        ForEach(Array(peopleOnDay.prefix(3))) { person in
                            Circle()
                                .fill(isSelected ? Color.white : CandleTheme.avatarPrimaryColor(for: person.colorIndex))
                                .frame(width: 5, height: 5)
                        }
                        if peopleOnDay.count > 3 {
                            Circle()
                                .fill(isSelected ? Color.white : store.accentPrimary)
                                .frame(width: 4, height: 4)
                        }
                    } else {
                        Color.clear
                            .frame(height: 5)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                isSelected ? store.accentPrimary :
                (isToday ? store.accentPrimary.opacity(0.12) : Color.clear)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        isSelected ? Color.clear :
                        (isToday ? store.accentPrimary : Color.clear),
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // Celebrations list for selected day
    private var selectedDayEventsSection: some View {
        let peopleOnDay = eventsOn(day: selectedDay, month: displayedMonth)
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(selectedDay) \(monthName(for: displayedMonth))")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(store.tr(.calendarEventsCount(peopleOnDay.count)))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(peopleOnDay.isEmpty ? .secondary : store.accentPrimary)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(
                        peopleOnDay.isEmpty ? Color.primary.opacity(0.05) : store.accentPrimary.opacity(0.12)
                    )
                    .clipShape(Capsule())
            }
            
            if peopleOnDay.isEmpty {
                VStack(spacing: 12) {
                    Text(store.tr(.calendarNoEventsOnDay))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.top, 6)
                    
                    Button {
                        openAddForSelectedDay()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                            Text(store.tr(.calendarAddEventForDay))
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(store.accentPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(store.accentPrimary.opacity(0.1))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(CandleTheme.subCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                VStack(spacing: 8) {
                    ForEach(peopleOnDay) { person in
                        Button {
                            selectedPerson = person
                        } label: {
                            BirthdayRowView(person: person)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .candleCardStyle()
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    // MARK: - Year Overview (12 Months)
    
    private var yearOverviewView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Year navigation
                HStack {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { displayedYear -= 1 }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(store.accentPrimary)
                            .frame(width: 36, height: 36)
                            .background(CandleTheme.cardBackground)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("\(String(displayedYear))")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { displayedYear += 1 }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(store.accentPrimary)
                            .frame(width: 36, height: 36)
                            .background(CandleTheme.cardBackground)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                
                // 12 Months Grid
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 14) {
                    ForEach(1...12, id: \.self) { month in
                        miniMonthCard(month: month)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .padding(.top, 4)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 25)
                .onEnded { value in
                    let hDist = value.translation.width
                    let vDist = value.translation.height
                    if abs(hDist) > abs(vDist) * 1.1 && abs(hDist) > 35 {
                        if hDist < 0 {
                            withAnimation { displayedYear += 1 }
                        } else {
                            withAnimation { displayedYear -= 1 }
                        }
                    }
                }
        )
    }
    
    @ViewBuilder
    private func miniMonthCard(month: Int) -> some View {
        let events = store.people.filter { person in
            guard isEventActive(person: person, day: nil, month: month, year: displayedYear) else {
                return false
            }
            return person.birthMonth == month || person.recurrence == .monthly
        }
        
        Button {
            CandleTheme.hapticSelection()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                displayedMonth = month
                mode = .month
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(monthName(for: month))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if !events.isEmpty {
                        Text("\(events.count)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(store.accentPrimary)
                            .clipShape(Circle())
                    }
                }
                
                // Mini day dots grid
                let days = daysInGrid(forMonth: month, year: displayedYear)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 3) {
                    ForEach(0..<days.count, id: \.self) { idx in
                        if let d = days[idx] {
                            let hasEvent = events.contains { $0.birthDay == d }
                            Circle()
                                .fill(hasEvent ? store.accentPrimary : Color.primary.opacity(0.12))
                                .frame(width: 5, height: 5)
                        } else {
                            Color.clear
                                .frame(width: 5, height: 5)
                        }
                    }
                }
                .frame(height: 70)
            }
            .padding(12)
            .candleCardStyle()
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Date Helpers
    
    private func previousMonth() {
        CandleTheme.hapticSelection()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            if displayedMonth == 1 {
                displayedMonth = 12
                displayedYear -= 1
            } else {
                displayedMonth -= 1
            }
            clampSelectedDay()
        }
    }
    
    private func nextMonth() {
        CandleTheme.hapticSelection()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            if displayedMonth == 12 {
                displayedMonth = 1
                displayedYear += 1
            } else {
                displayedMonth += 1
            }
            clampSelectedDay()
        }
    }
    
    private func clampSelectedDay() {
        let maxDays = daysInMonth(displayedMonth, year: displayedYear)
        if selectedDay > maxDays {
            selectedDay = maxDays
        }
    }
    
    private func daysInMonth(_ month: Int, year: Int) -> Int {
        var comp = DateComponents()
        comp.year = year
        comp.month = month
        guard let date = calendar.date(from: comp),
              let range = calendar.range(of: .day, in: .month, for: date) else {
            return 30
        }
        return range.count
    }
    
    private func daysInGrid(forMonth month: Int, year: Int) -> [Int?] {
        var comp = DateComponents()
        comp.year = year
        comp.month = month
        comp.day = 1
        guard let firstDay = calendar.date(from: comp) else { return [] }
        
        // Calculate day of the week (1 = Sunday in US, converted to Monday = 0)
        let weekday = calendar.component(.weekday, from: firstDay)
        let firstWeekdayIndex = (weekday + 5) % 7 // Monday = 0, Sunday = 6
        
        let count = daysInMonth(month, year: year)
        var result: [Int?] = Array(repeating: nil, count: firstWeekdayIndex)
        for d in 1...count {
            result.append(d)
        }
        return result
    }
    
    private func weekdaySymbols() -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: store.currentLanguage.resolvedCode)
        let symbols = formatter.shortStandaloneWeekdaySymbols ?? ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        // Reorder starting from Monday
        if symbols.count == 7 {
            return Array(symbols[1...6]) + [symbols[0]]
        }
        return symbols
    }
    
    private func monthName(for month: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: store.currentLanguage.resolvedCode)
        return formatter.monthSymbols[max(0, min(11, month - 1))].capitalized
    }
    
    private func isEventActive(person: BirthdayPerson, day: Int?, month: Int, year: Int) -> Bool {
        if person.recurrence == .oneTime {
            if let eventYear = person.birthYear {
                if year != eventYear {
                    return false
                }
            }
        }
        if let startYear = person.birthYear {
            if year < startYear {
                return false
            }
            if year == startYear && month < person.birthMonth {
                return false
            }
            if let day = day, year == startYear && month == person.birthMonth && day < person.birthDay {
                return false
            }
        }
        return true
    }
    
    private func eventsOn(day: Int, month: Int) -> [BirthdayPerson] {
        store.people.filter { person in
            guard isEventActive(person: person, day: day, month: month, year: displayedYear) else {
                return false
            }
            if person.recurrence == .monthly {
                return person.birthDay == day
            } else {
                return person.birthMonth == month && person.birthDay == day
            }
        }
    }
    
    private func checkIsToday(day: Int, month: Int, year: Int) -> Bool {
        let now = Date()
        return calendar.component(.day, from: now) == day &&
               calendar.component(.month, from: now) == month &&
               calendar.component(.year, from: now) == year
    }
    
    private func openAddForSelectedDay() {
        var comp = DateComponents()
        comp.year = displayedYear
        comp.month = displayedMonth
        comp.day = selectedDay
        addInitialDate = calendar.date(from: comp) ?? Date()
        showingAddSheet = true
    }
}
