import UIKit

class KeyboardViewController: UIInputViewController {

    enum ShiftState {
        case off
        case on
        case capsLock
    }

    private var shiftState: ShiftState = .off {
        didSet {
            // Redraw the keyboard when the shift state changes
            setupKeyboard()
        }
    }

    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupKeyboard()
        self.updateKeyboardAppearance()

        // Prepare the haptic feedback generator to reduce latency
        self.impactFeedbackGenerator.prepare()
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
        let keyboardView = KeyboardLayout.create(target: self, action: #selector(keyPressed(_:)), shiftState: self.shiftState)

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
        // Trigger haptic feedback
        self.impactFeedbackGenerator.impactOccurred()

        guard let keyButton = sender as? KeyButton else {
            return
        }

        switch keyButton.keyType {
        case .character:
            if let title = keyButton.title(for: .normal) {
                self.textDocumentProxy.insertText(title)
            }
            // If shift was on, turn it off
            if self.shiftState == .on {
                self.shiftState = .off
            }
        case .backspace:
            self.textDocumentProxy.deleteBackward()
        case .space:
            self.textDocumentProxy.insertText(" ")
        case .returnKey:
            self.textDocumentProxy.insertText("\n")
        case .nextKeyboard:
            self.advanceToNextInputMode()
        case .shift:
            // Toggle shift state
            switch self.shiftState {
            case .off:
                self.shiftState = .on
            case .on:
                self.shiftState = .off // For now, just toggles on and off. Caps lock later.
            case .capsLock:
                self.shiftState = .off
            }
        }
    }
}
