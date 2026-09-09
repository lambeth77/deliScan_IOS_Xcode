import Foundation

/// N’émet qu’une fois un même montant vu dans deux analyses successives.
struct StableAmountDetector {
    private var candidate: Amount?
    private var observations = 0
    private var hasEmittedCandidate = false

    mutating func observe(_ amounts: [Amount]) -> Amount? {
        guard let first = amounts.first else {
            candidate = nil
            observations = 0
            hasEmittedCandidate = false
            return nil
        }

        if first == candidate {
            observations += 1
        } else {
            candidate = first
            observations = 1
            hasEmittedCandidate = false
        }

        guard observations >= 2, !hasEmittedCandidate else { return nil }
        hasEmittedCandidate = true
        return first
    }
}
