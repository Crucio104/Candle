import SwiftUI

@main
struct CandleApp: App {
    init() {
        NotificationManager.shared.clearBadge()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    NotificationManager.shared.clearBadge()
                }
        }
    }
}
