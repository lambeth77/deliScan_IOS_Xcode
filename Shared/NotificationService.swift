import Foundation
import UserNotifications

enum NotificationService {
    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }

    /// L’extension programme l’alerte seulement après que l’app conteneur a demandé l’autorisation.
    static func notifyProposal(_ proposal: DetectedProposal) {
        let content = UNMutableNotificationContent()
        content.title = "Proposition détectée"
        content.body = proposal.amount.formatted
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "proposal-\\(proposal.amount.cents)-\\(proposal.detectedAt.timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
