import UIKit

class KeyboardViewController: UIInputViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupKeyboard()
        self.updateKeyboardAppearance()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            self.updateKeyboardAppearance()
        }
    }

    // MARK: - Private Methods

    private func setupKeyboard() {
        // Remove any existing views from the input view
        for subview in self.inputView?.subviews ?? [] {
            subview.removeFromSuperview()
        }

        // Create the keyboard layout
        let keyboardView = KeyboardLayout.create(target: self, action: #selector(keyPressed(_:)))

        // Add the keyboard view to the input view
        self.inputView?.addSubview(keyboardView)

        // Add constraints to make the keyboard view fill the input view
        if let inputView = self.inputView {
            NSLayoutConstraint.activate([
                keyboardView.topAnchor.constraint(equalTo: inputView.topAnchor),
                keyboardView.bottomAnchor.constraint(equalTo: inputView.bottomAnchor),
                keyboardView.leadingAnchor.constraint(equalTo: inputView.leadingAnchor),
                keyboardView.trailingAnchor.constraint(equalTo: inputView.trailingAnchor)
            ])
        }
    }

    private func updateKeyboardAppearance() {
        if self.traitCollection.userInterfaceStyle == .dark {
            self.inputView?.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        } else {
            self.inputView?.backgroundColor = UIColor(red: 0.82, green: 0.84, blue: 0.86, alpha: 1.0)
        }
    }

    @objc private func keyPressed(_ sender: UIButton) {
        guard let keyButton = sender as? KeyButton else {
            return
        }

        switch keyButton.keyType {
        case .character:
            if let title = keyButton.title(for: .normal) {
                self.textDocumentProxy.insertText(title)
            }
        case .backspace:
            self.textDocumentProxy.deleteBackward()
        case .space:
            self.textDocumentProxy.insertText(" ")
        case .returnKey:
            self.textDocumentProxy.insertText("\n")
        case .nextKeyboard:
            self.advanceToNextInputMode()
        }
    }
}
