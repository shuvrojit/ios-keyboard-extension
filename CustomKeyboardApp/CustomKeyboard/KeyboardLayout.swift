import UIKit

struct KeyboardLayout {

    // A struct to represent a single key, with its title and type.
    struct Key {
        let title: String
        let type: KeyButton.KeyType
    }

    /// Creates the keyboard layout view based on the specified layout type and shift state.
    static func create(
        target: Any?,
        action: Selector,
        previewAction: Selector,
        doubleTapAction: Selector,
        shiftState: KeyboardViewController.ShiftState,
        layoutType: KeyboardViewController.KeyboardLayoutType
    ) -> UIView {

        let keyboardView = UIView()
        keyboardView.translatesAutoresizingMaskIntoConstraints = false

        let mainStackView = UIStackView()
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.spacing = 8
        mainStackView.distribution = .fillEqually

        let rows: [[Key]]
        switch layoutType {
        case .alphabetic:
            rows = createAlphabeticRows(shiftState: shiftState)
        case .numeric:
            rows = createNumericRows()
        case .symbolic:
            rows = createSymbolicRows()
        }

        for rowOfKeys in rows {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.spacing = 4
            rowStackView.distribution = .fillProportionally

            for key in rowOfKeys {
                let button = KeyButton(type: key.type, title: key.title)
                button.addTarget(target, action: action, for: .touchUpInside)

                let longPressGesture = UILongPressGestureRecognizer(target: target, action: previewAction)
                longPressGesture.minimumPressDuration = 0.0
                button.addGestureRecognizer(longPressGesture)

                if key.type == .space {
                    button.setTitle("                           ", for: .normal)
                } else if key.type == .shift {
                    button.isSelected = (shiftState != .off)

                    // Add a double-tap gesture recognizer for caps lock.
                    let doubleTapGesture = UITapGestureRecognizer(target: target, action: doubleTapAction)
                    doubleTapGesture.numberOfTapsRequired = 2
                    button.addGestureRecognizer(doubleTapGesture)

                    // Provide a visual indicator for the caps lock state.
                    if shiftState == .capsLock {
                        button.tintColor = .systemBlue // Make the icon blue
                        // You could also add an underline or other indicator here.
                    } else {
                        button.tintColor = nil // Use default color
                    }
                }

                rowStackView.addArrangedSubview(button)
            }
            mainStackView.addArrangedSubview(rowStackView)
        }

        keyboardView.addSubview(mainStackView)
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: keyboardView.topAnchor, constant: 8),
            mainStackView.bottomAnchor.constraint(equalTo: keyboardView.bottomAnchor, constant: -8),
            mainStackView.leadingAnchor.constraint(equalTo: keyboardView.leadingAnchor, constant: 4),
            mainStackView.trailingAnchor.constraint(equalTo: keyboardView.trailingAnchor, constant: -4)
        ])

        return keyboardView
    }

    // ... (The rest of the file is the same)
    private static func createAlphabeticRows(shiftState: KeyboardViewController.ShiftState) -> [[Key]] {
        let characterRows = [
            ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
            ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
            ["Z", "X", "C", "V", "B", "N", "M"]
        ]

        let characterKeys: [[Key]] = characterRows.map { row in
            row.map { char in
                // Letters should be uppercase if shift is on or if caps lock is engaged.
                let title = (shiftState == .on || shiftState == .capsLock) ? char.uppercased() : char.lowercased()
                return Key(title: title, type: .character)
            }
        }

        return [
            characterKeys[0],
            characterKeys[1],
            [Key(title: "↑", type: .shift)] + characterKeys[2] + [Key(title: "⌫", type: .backspace)],
            [
                Key(title: "123", type: .switchToNumeric),
                Key(title: "🌐", type: .nextKeyboard),
                Key(title: "space", type: .space),
                Key(title: "return", type: .returnKey)
            ]
        ]
    }

    private static func createNumericRows() -> [[Key]] {
        let numberRow = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"].map { Key(title: $0, type: .character) }
        let symbolRow = ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""].map { Key(title: $0, type: .character) }

        return [
            numberRow,
            symbolRow,
            [
                Key(title: "#+=", type: .switchToSymbolic),
                Key(title: ".", type: .character),
                Key(title: ",", type: .character),
                Key(title: "?", type: .character),
                Key(title: "!", type: .character),
                Key(title: "'", type: .character),
                Key(title: "⌫", type: .backspace)
            ],
            [
                Key(title: "ABC", type: .switchToAlphabetic),
                Key(title: "🌐", type: .nextKeyboard),
                Key(title: "space", type: .space),
                Key(title: "return", type: .returnKey)
            ]
        ]
    }

    private static func createSymbolicRows() -> [[Key]] {
        let row1 = ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="].map { Key(title: $0, type: .character) }
        let row2 = ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "•"].map { Key(title: $0, type: .character) }

        return [
            row1,
            row2,
            [
                Key(title: "123", type: .switchToNumeric),
                Key(title: ".", type: .character),
                Key(title: ",", type: .character),
                Key(title: "?", type: .character),
                Key(title: "!", type: .character),
                Key(title: "'", type: .character),
                Key(title: "⌫", type: .backspace)
            ],
            [
                Key(title: "ABC", type: .switchToAlphabetic),
                Key(title: "🌐", type: .nextKeyboard),
                Key(title: "space", type: .space),
                Key(title: "return", type: .returnKey)
            ]
        ]
    }
}
