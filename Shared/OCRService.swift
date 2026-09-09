import CoreVideo
import Foundation
import ImageIO
import Vision

/// Vision est exécuté synchroniquement par l’extension, au plus une fois par seconde.
/// Ainsi un unique `RPBroadcastSampleHandler` ne possède jamais deux requêtes OCR actives.
final class OCRService {
    static let shared = OCRService()

    private init() {}

    func amounts(in pixelBuffer: CVPixelBuffer) -> [Amount] {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .fast
        request.usesLanguageCorrection = false
        request.recognitionLanguages = ["fr-FR", "en-US"]
        request.minimumTextHeight = 0.025

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        do {
            try handler.perform([request])
        } catch {
            SessionStore.shared.record(status: "OCR indisponible : \\(error.localizedDescription)")
            return []
        }

        let text = (request.results ?? [])
            .compactMap { $0.topCandidates(1).first?.string }
            .joined(separator: "\\n")
        return AmountParser.amounts(in: text)
    }
}
