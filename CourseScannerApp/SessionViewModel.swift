import Foundation

@MainActor
final class SessionViewModel: ObservableObject {
    @Published private(set) var notificationAllowed = false
    @Published private(set) var status = SessionStore.shared.currentStatus()
    @Published private(set) var proposal = SessionStore.shared.latestProposal()
    @Published var shouldShowBroadcastPicker = false

    func startSession() async {
        notificationAllowed = await NotificationService.requestAuthorization()
        SessionStore.shared.record(status: "Prêt : démarrez la diffusion dans le bouton ci-dessous")
        refresh()
        shouldShowBroadcastPicker = true
    }

    func refresh() {
        status = SessionStore.shared.currentStatus()
        proposal = SessionStore.shared.latestProposal()
    }
}
