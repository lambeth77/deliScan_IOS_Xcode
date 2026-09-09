import Foundation

/// Une seule valeur à modifier dans Xcode (APP_GROUP_IDENTIFIER) pour les deux cibles.
enum AppGroup {
    static let identifier = Bundle.main.object(forInfoDictionaryKey: "AppGroupIdentifier") as? String
        ?? "group.com.example.CourseScanner"

    static var defaults: UserDefaults? {
        UserDefaults(suiteName: identifier)
    }
}

enum AppConfiguration {
    static let broadcastUploadExtensionIdentifier =
        Bundle.main.object(forInfoDictionaryKey: "BroadcastUploadExtensionIdentifier") as? String
        ?? "com.example.CourseScanner.BroadcastUpload"
}
