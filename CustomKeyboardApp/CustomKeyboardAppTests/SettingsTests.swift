import XCTest
@testable import CustomKeyboardApp

class SettingsTests: XCTestCase {

    var testSuiteName: String!

    override func setUp() {
        super.setUp()
        // Create a unique suite name for each test run to ensure test isolation.
        testSuiteName = "Test-\(UUID().uuidString)"

        // Replace the default UserDefaults suite in the Settings struct
        // with our temporary test suite. This is a form of dependency injection.
        Settings.userDefaults = UserDefaults(suiteName: testSuiteName)
    }

    override func tearDown() {
        // Remove the temporary suite from the system's UserDefaults database.
        // This prevents test data from polluting the system or affecting other tests.
        UserDefaults.standard.removePersistentDomain(forName: testSuiteName)

        // Reset the Settings struct to use its default suite, in case other
        // test classes in the project rely on the default behavior.
        Settings.userDefaults = UserDefaults(suiteName: "group.com.yourapp.shared")

        testSuiteName = nil
        super.tearDown()
    }

    /// Tests that the default value for `hapticsEnabled` is `true` when no value has been explicitly set.
    func testHapticsEnabled_DefaultValue_IsTrue() {
        // Arrange: The `setUp` method provides a clean slate with no value set.

        // Act: Retrieve the value.
        let isEnabled = Settings.hapticsEnabled

        // Assert: The value should be true by default.
        XCTAssertTrue(isEnabled, "Haptics should be enabled by default")
    }

    /// Tests that `hapticsEnabled` can be correctly set to `false`.
    func testHapticsEnabled_CanBeSetToFalse() {
        // Arrange: The default value is true.
        XCTAssertTrue(Settings.hapticsEnabled, "Precondition failed: Haptics should be enabled by default")

        // Act: Set the value to false.
        Settings.hapticsEnabled = false

        // Assert: The retrieved value should now be false.
        XCTAssertFalse(Settings.hapticsEnabled, "Haptics should be disabled after being set to false")
    }

    /// Tests that `hapticsEnabled` can be set to `false` and then back to `true`.
    func testHapticsEnabled_CanBeSetToTrue() {
        // Arrange: Set the value to false first to ensure we are testing a change.
        Settings.hapticsEnabled = false
        XCTAssertFalse(Settings.hapticsEnabled, "Precondition failed: Haptics could not be set to false")

        // Act: Set the value back to true.
        Settings.hapticsEnabled = true

        // Assert: The retrieved value should now be true.
        XCTAssertTrue(Settings.hapticsEnabled, "Haptics should be enabled after being set back to true")
    }
}
