import SwiftUI

@main
struct HakoApp: App {
    @StateObject private var store = HakoStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .onAppear {
                    store.richiediPermessoNotifiche()
                }
        }
    }
}
