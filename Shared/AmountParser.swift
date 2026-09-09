import Foundation

enum AmountParser {
    /// Accepte par exemple « 8,73 € », « 8.73€ » et « 1 234,50 EUR ».
    /// Un symbole devise est volontairement exigé afin de réduire les faux positifs.
    private static let expression = try! NSRegularExpression(
        pattern: #"(?<![0-9.,])([0-9]{1,3}(?:[ .][0-9]{3})*|[0-9]+)[,.]([0-9]{2})\s*(?:€|EUR)(?![A-Za-z])"#,
        options: [.caseInsensitive]
    )

    static func amounts(in text: String) -> [Amount] {
        let range = NSRange(text.startIndex..., in: text)
        return expression.matches(in: text, range: range).compactMap { match in
            guard
                let unitsRange = Range(match.range(at: 1), in: text),
                let centsRange = Range(match.range(at: 2), in: text)
            else { return nil }

            let units = text[unitsRange].replacingOccurrences(of: " ", with: "")
            guard let whole = Int(units), let fractional = Int(text[centsRange]) else { return nil }
            return Amount(cents: whole * 100 + fractional)
        }
    }
}
