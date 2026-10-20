import SwiftUI

public struct ContentView: View {
    @StateObject private var store = BirthdayStore.shared
    
    public init() {}
    
    public var body: some View {
        MainDashboardView(store: store)
            .preferredColorScheme(store.settings.appearance.colorScheme)
    }
}
