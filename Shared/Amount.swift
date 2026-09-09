import Foundation

struct Amount: Codable, Equatable, Hashable, Sendable {
    let cents: Int

    var formatted: String {
        let value = Decimal(cents) / Decimal(100)
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSDecimalNumber(decimal: value)) ?? "\\(value) €"
    }
}
