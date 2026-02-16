import SwiftUI
import SwiftData

@main
struct OverSightApp: App {
    var body: some Scene {
        WindowGroup {
            TodayView()
        }
        .modelContainer(for: Entry.self)
    }
}
