import Foundation

struct DetectedProposal: Codable, Equatable {
    let amount: Amount
    let detectedAt: Date
}

final class SessionStore {
    static let shared = SessionStore()

    private enum Key {
        static let proposal = "lastDetectedProposal"
        static let status = "sessionStatus"
        static let updatedAt = "sessionStatusUpdatedAt"
    }

    private init() {}

    func save(_ proposal: DetectedProposal) {
        guard let data = try? JSONEncoder().encode(proposal) else { return }
        AppGroup.defaults?.set(data, forKey: Key.proposal)
        record(status: "Proposition détectée : \\(proposal.amount.formatted)")
    }

    func latestProposal() -> DetectedProposal? {
        guard
            let data = AppGroup.defaults?.data(forKey: Key.proposal),
            let proposal = try? JSONDecoder().decode(DetectedProposal.self, from: data)
        else { return nil }
        return proposal
    }

    func record(status: String) {
        AppGroup.defaults?.set(status, forKey: Key.status)
        AppGroup.defaults?.set(Date(), forKey: Key.updatedAt)
    }

    func currentStatus() -> String {
        AppGroup.defaults?.string(forKey: Key.status) ?? "Aucune session en cours"
    }
}
