import CoreMedia
import ReplayKit

final class SampleHandler: RPBroadcastSampleHandler {
    private let minimumInterval: TimeInterval = 1.0
    private var lastAnalysisDate = Date.distantPast
    private var isProcessing = false
    private var stableDetector = StableAmountDetector()

    override func broadcastStarted(withSetupInfo setupInfo: [String: NSObject]?) {
        stableDetector = StableAmountDetector()
        lastAnalysisDate = .distantPast
        SessionStore.shared.record(status: "Diffusion démarrée — analyse locale active")
    }

    override func broadcastFinished() {
        SessionStore.shared.record(status: "Diffusion terminée")
    }

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        guard sampleBufferType == .video else { return }
        let now = Date()
        guard now.timeIntervalSince(lastAnalysisDate) >= minimumInterval, !isProcessing else { return }
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // ReplayKit appelle ce handler en série. Vision est exécuté avant le retour,
        // ce qui empêche toute requête OCR concurrente et évite de retenir une frame.
        isProcessing = true
        lastAnalysisDate = now
        defer { isProcessing = false }

        let amounts = OCRService.shared.amounts(in: imageBuffer)
        guard let amount = stableDetector.observe(amounts) else { return }

        let proposal = DetectedProposal(amount: amount, detectedAt: now)
        SessionStore.shared.save(proposal)
        NotificationService.notifyProposal(proposal)
    }
}
