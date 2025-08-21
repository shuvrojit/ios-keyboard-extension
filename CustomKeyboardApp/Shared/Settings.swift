import Foundation

/// A utility for managing settings shared between the main app and the keyboard extension.
struct Settings {

    // MARK: - App Group & UserDefaults

    /// The identifier for the shared App Group.
    /// **IMPORTANT**: This must match the App Group entitlement in the Xcode project.
    private static let appGroupIdentifier = "group.com.yourapp.shared"

    /// The `UserDefaults` suite used for storing settings.
    /// This is `internal` so it can be replaced during unit tests.
    /// By default, it uses the shared App Group suite.
    internal static var userDefaults: UserDefaults? = UserDefaults(suiteName: appGroupIdentifier)

    // MARK: - Settings Keys

    private enum Keys {
        static let hapticsEnabled = "HapticsEnabled"
    }

    // MARK: - Haptic Feedback Setting

    /// A boolean indicating whether haptic feedback is enabled.
    /// Defaults to `true` if the setting is not yet saved.
    static var hapticsEnabled: Bool {
        get {
            // Use `object(forKey:)` to check for the key's existence.
            // If it doesn't exist, it's the first launch or the setting hasn't been changed,
            // so we default to true.
            if userDefaults?.object(forKey: Keys.hapticsEnabled) == nil {
                return true
            }
            return userDefaults?.bool(forKey: Keys.hapticsEnabled) ?? true
        }
        set {
            userDefaults?.set(newValue, forKey: Keys.hapticsEnabled)
        }
    }
}
