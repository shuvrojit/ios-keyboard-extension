import UIKit

struct KeyboardLayout {

    struct Key {
        let title: String
        let type: KeyButton.KeyType
    }

    /// Creates the keyboard layout view and configures it with the necessary targets and actions.
    /// - Parameters:
    ///   - target: The target for the key tap and preview actions (typically the KeyboardViewController).
    ///   - action: The selector for the key tap action (e.g., inserting a character).
    ///   - previewAction: The selector for the key preview gesture action.
    ///   - shiftState: The current shift state of the keyboard.
    /// - Returns: A configured UIView containing the keyboard layout.
    static func create(target: Any?, action: Selector, previewAction: Selector, shiftState: KeyboardViewController.ShiftState) -> UIView {
        let keyboardView = UIView()
        keyboardView.translatesAutoresizingMaskIntoConstraints = false

        let mainStackView = UIStackView()
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.spacing = 8
        mainStackView.distribution = .fillEqually

        // Define the character rows for a QWERTY layout
        let characterRows = [
            ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
            ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
            ["Z", "X", "C", "V", "B", "N", "M"]
        ]

        // Map the character strings to Key objects, adjusting for shift state
        let characterKeys: [[Key]] = characterRows.map { row in
            row.map { char in
                let title = (shiftState == .off) ? char.lowercased() : char.uppercased()
                return Key(title: title, type: .character)
            }
        }

        // Combine character keys with special keys to form the final layout
        let rows: [[Key]] = [
            characterKeys[0],
            characterKeys[1],
            [Key(title: "↑", type: .shift)] + characterKeys[2] + [Key(title: "⌫", type: .backspace)],
            [
                Key(title: "🌐", type: .nextKeyboard),
                Key(title: "space", type: .space),
                Key(title: "return", type: .returnKey)
            ]
        ]

        // Create the UI for each row of keys
        for rowOfKeys in rows {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.spacing = 4
            rowStackView.distribution = .fillProportionally

            for key in rowOfKeys {
                let button = KeyButton(type: key.type, title: key.title)

                // Add the standard tap action for when the key is released
                button.addTarget(target, action: action, for: .touchUpInside)

                // Add a long press gesture recognizer to handle the key preview
                let longPressGesture = UILongPressGestureRecognizer(target: target, action: previewAction)
                longPressGesture.minimumPressDuration = 0.0 // Trigger immediately
                button.addGestureRecognizer(longPressGesture)

                // Special handling for certain key types
                if key.type == .space {
                    // A simple way to make the space bar wider
                    button.setTitle("                           ", for: .normal)
                } else if key.type == .shift {
                    // Set the selected state for the shift key to provide visual feedback
                    button.isSelected = (shiftState != .off)
                }

                rowStackView.addArrangedSubview(button)
            }
            mainStackView.addArrangedSubview(rowStackView)
        }

        keyboardView.addSubview(mainStackView)

        // Set up constraints for the main stack view to fill the keyboard view
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: keyboardView.topAnchor, constant: 8),
            mainStackView.bottomAnchor.constraint(equalTo: keyboardView.bottomAnchor, constant: -8),
            mainStackView.leadingAnchor.constraint(equalTo: keyboardView.leadingAnchor, constant: 4),
            mainStackView.trailingAnchor.constraint(equalTo: keyboardView.trailingAnchor, constant: -4)
        ])

        return keyboardView
    }
}
