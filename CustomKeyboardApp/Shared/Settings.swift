import Foundation

/// A utility for managing settings shared between the main app and the keyboard extension.
/// This relies on an App Group being configured in the Xcode project with the specified identifier.
struct Settings {

    // MARK: - App Group

    /// The identifier for the shared App Group.
    /// **IMPORTANT**: This identifier MUST be enabled for both the containing app and the
    /// keyboard extension targets in the Xcode project's "Signing & Capabilities" tab.
    private static let appGroupIdentifier = "group.com.yourapp.shared"

    /// The shared UserDefaults suite for the App Group.
    /// Returns `nil` if the App Group identifier is invalid or not configured correctly.
    private static var sharedDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupIdentifier)
    }

    // MARK: - Settings Keys

    /// Keys used to store and retrieve values from UserDefaults.
    private enum Keys {
        static let hapticsEnabled = "HapticsEnabled"
    }

    // MARK: - Haptic Feedback Setting

    /// A boolean indicating whether haptic feedback is enabled.
    /// Defaults to `true` if the setting is not yet saved.
    static var hapticsEnabled: Bool {
        get {
            // Use `object(forKey:)` to check for the key's existence. If it doesn't exist,
            // it's the first launch or the setting hasn't been changed, so we default to true.
            if sharedDefaults?.object(forKey: Keys.hapticsEnabled) == nil {
                return true
            }
            return sharedDefaults?.bool(forKey: Keys.hapticsEnabled) ?? true
        }
        set {
            sharedDefaults?.set(newValue, forKey: Keys.hapticsEnabled)
        }
    }
}
