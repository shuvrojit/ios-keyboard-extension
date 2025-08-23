# iOS Custom Keyboard Extension

This project is a demonstration of a custom keyboard extension for iOS, built programmatically in Swift. It includes a containing app for settings and testing, and a feature-rich keyboard extension.

## Features

The custom keyboard includes the following features:

- **Multiple Layouts:**
  - Standard QWERTY alphabetic layout.
  - Numeric layout for numbers and common symbols.
  - Symbolic layout for additional symbols.
- **Layout Switching:** Easily switch between layouts using dedicated `123`, `ABC`, and `#+=` keys.
- **Shift & Caps Lock:** A functional shift key to toggle between lowercase and uppercase letters.
- **Dynamic Sizing:** The keyboard automatically adjusts its height for portrait/landscape orientations and respects the safe area on devices with a home indicator.
- **Key Previews:** A popup preview appears above each key as it's pressed, improving typing accuracy.
- **Long Press for Accents:** Long-press on vowel keys (and others like 'c', 'n', 's') to reveal a popup with accented character options.
- **Continuous Backspace:** Long-press the backspace key to delete text continuously.
- **Haptic Feedback:** The keyboard provides tactile feedback on key presses. This can be toggled on or off in the settings.
- **Shared Settings:** A settings screen in the containing app allows users to configure keyboard preferences.

## Project Structure

The project is organized into three main directories:

- `/ContainingApp`: Contains the source code for the main application, which acts as a host for the keyboard and provides a settings screen.
- `/CustomKeyboard`: Contains the source code for the keyboard extension itself.
- `/Shared`: Contains code shared between the app and the extension, such as the `Settings` manager.

## Setup Instructions

To run this project, you will need to create an Xcode project and manually add the provided source files.

1.  **Create a New Xcode Project:**
    -   Open Xcode and choose "Create a new Xcode project".
    -   Select the "App" template under the "iOS" tab.
    -   Name your project (e.g., "CustomKeyboardApp") and choose "Swift" for the language and "Storyboard" or "SwiftUI" for the interface (it doesn't matter as we will set up the UI programmatically).

2.  **Add the Containing App Files:**
    -   Delete the default `ViewController.swift`, `AppDelegate.swift`, and `SceneDelegate.swift` files created by Xcode.
    -   Drag all the files from the `/ContainingApp` and `/Shared` directories into your Xcode project navigator.

3.  **Add the Keyboard Extension Target:**
    -   In Xcode, go to `File` → `New` → `Target...`.
    -   Select the "Custom Keyboard Extension" template under "iOS".
    -   Name your extension (e.g., "CustomKeyboard").
    -   Click "Finish". If Xcode asks if you want to activate the new scheme, choose "Activate".

4.  **Add the Keyboard Extension Files:**
    -   A new folder for your extension will appear in the project navigator. Delete the default `KeyboardViewController.swift` file it contains.
    -   Drag all the files from the `/CustomKeyboard` directory into this new extension group in Xcode.

5.  **Configure App Groups (Crucial Step):**
    -   The settings feature requires an App Group to share `UserDefaults` between the main app and the keyboard extension.
    -   Select your project in the Project Navigator, then select the **main app target**.
    -   Go to the "Signing & Capabilities" tab.
    -   Click "+ Capability" and select "App Groups".
    -   In the App Groups section, click the "+" button and add a new container. The identifier **must be** `group.com.yourapp.shared`. You may need to use an identifier associated with your own developer account. If so, you must also change the `appGroupIdentifier` string in `Shared/Settings.swift`.
    -   Now, select the **keyboard extension target** and repeat the exact same process, adding the same App Group capability with the exact same identifier.

## How to Use

1.  **Run the Main App:** Build and run the `CustomKeyboardApp` scheme on a simulator or a device. You can use the settings screen in the app to toggle haptic feedback.
2.  **Enable the Keyboard:**
    -   Go to the Settings app on your device/simulator.
    -   Navigate to `General` → `Keyboard` → `Keyboards`.
    -   Tap "Add New Keyboard...".
    -   Under "Third-Party Keyboards", you should see the name of your keyboard (e.g., "CustomKeyboardApp"). Tap it to add it.
3.  **Use the Keyboard:**
    -   Open any app with a text field (you can use the containing app for this).
    -   Tap the text field to bring up the keyboard.
    -   Tap and hold the "Globe" key (🌐) in the bottom-left to switch between keyboards.
    -   Select your custom keyboard from the list.
