import UIKit

struct KeyboardLayout {

    struct Key {
        let title: String
        let type: KeyButton.KeyType
    }

    static func create(target: Any?, action: Selector, shiftState: KeyboardViewController.ShiftState) -> UIView {
        let keyboardView = UIView()
        keyboardView.translatesAutoresizingMaskIntoConstraints = false

        let mainStackView = UIStackView()
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.spacing = 8
        mainStackView.distribution = .fillEqually

        let characterRows = [
            ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
            ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
            ["Z", "X", "C", "V", "B", "N", "M"]
        ]

        let characterKeys: [[Key]] = characterRows.map { row in
            row.map { char in
                let title = (shiftState == .off) ? char.lowercased() : char.uppercased()
                return Key(title: title, type: .character)
            }
        }

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

        for rowOfKeys in rows {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.spacing = 4
            rowStackView.distribution = .fillProportionally

            for key in rowOfKeys {
                let button = KeyButton(type: key.type, title: key.title)
                button.addTarget(target, action: action, for: .touchUpInside)

                if key.type == .space {
                    // A simple way to make the space bar wider
                    button.setTitle("                           ", for: .normal)
                } else if key.type == .shift {
                    button.isSelected = (shiftState != .off)
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
}
