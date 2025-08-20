import UIKit

class KeyboardViewController: UIInputViewController {

    // MARK: - Properties

    /// Enum to manage the shift state of the keyboard.
    enum ShiftState {
        case off
        case on
        case capsLock
    }

    /// The current shift state of the keyboard.
    /// When this property is set, the keyboard is redrawn to reflect the new state.
    private var shiftState: ShiftState = .off {
        didSet {
            setupKeyboard()
        }
    }

    /// Haptic feedback generator for key presses.
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    /// The view that shows a preview of the key being pressed.
    private lazy var previewView: KeyPreviewView = {
        let view = KeyPreviewView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true // Initially hidden
        return view
    }()

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupKeyboard()
        self.updateKeyboardAppearance()

        // Prepare the haptic feedback generator to reduce latency.
        self.impactFeedbackGenerator.prepare()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    /// Called when the trait collection changes, for example, when switching between light and dark mode.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            self.updateKeyboardAppearance()
        }
    }

    // MARK: - Keyboard Setup

    /// Sets up the keyboard layout and adds it to the input view.
    private func setupKeyboard() {
        // Remove any existing views from the input view to start fresh
        for subview in self.inputView?.subviews ?? [] {
            subview.removeFromSuperview()
        }

        // Create the keyboard layout view, passing the necessary targets and actions.
        let keyboardView = KeyboardLayout.create(
            target: self,
            action: #selector(keyPressed(_:)),
            previewAction: #selector(handlePreviewGesture(_:)),
            shiftState: self.shiftState
        )

        // Add the keyboard view to the main input view
        self.inputView?.addSubview(keyboardView)

        // Add the preview view to the input view
        self.inputView?.addSubview(previewView)

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

    /// Updates the appearance of the keyboard's background based on the current user interface style.
    private func updateKeyboardAppearance() {
        if self.traitCollection.userInterfaceStyle == .dark {
            self.inputView?.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        } else {
            self.inputView?.backgroundColor = UIColor(red: 0.82, green: 0.84, blue: 0.86, alpha: 1.0)
        }
    }

    // MARK: - Key Actions

    /// Handles the primary action when a key is tapped.
    /// - Parameter sender: The `KeyButton` that was tapped.
    @objc private func keyPressed(_ sender: UIButton) {
        // Trigger haptic feedback for the key press
        self.impactFeedbackGenerator.impactOccurred()

        guard let keyButton = sender as? KeyButton else {
            return
        }

        // Perform an action based on the type of key that was pressed
        switch keyButton.keyType {
        case .character:
            if let title = keyButton.title(for: .normal) {
                self.textDocumentProxy.insertText(title)
            }
            // If shift was on (but not caps lock), turn it off after one character
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
            // Toggle the shift state
            switch self.shiftState {
            case .off:
                self.shiftState = .on
            case .on:
                self.shiftState = .off // Later, this could be changed to caps lock on double tap
            case .capsLock:
                self.shiftState = .off
            }
        }
    }

    /// Handles the long press gesture for showing the key preview.
    /// - Parameter gesture: The `UILongPressGestureRecognizer` that triggered the action.
    @objc private func handlePreviewGesture(_ gesture: UILongPressGestureRecognizer) {
        guard let button = gesture.view as? KeyButton else { return }

        switch gesture.state {
        case .began:
            // --- Show the preview when the gesture begins ---

            // 1. Set the character on the preview view
            previewView.setCharacter(button.title(for: .normal) ?? "")

            // 2. Position the preview view above the button
            // Convert the button's frame to the input view's coordinate system
            if let inputView = self.inputView {
                let buttonFrameInInputView = button.convert(button.bounds, to: inputView)

                // Set the size and position of the preview view
                let previewWidth: CGFloat = buttonFrameInInputView.width * 1.5
                let previewHeight: CGFloat = 80
                let previewX = buttonFrameInInputView.midX - (previewWidth / 2)
                let previewY = buttonFrameInInputView.origin.y - previewHeight + 10 // Position above the button

                previewView.frame = CGRect(x: previewX, y: previewY, width: previewWidth, height: previewHeight)
            }

            // 3. Make the preview visible and bring it to the front
            previewView.isHidden = false
            self.inputView?.bringSubviewToFront(previewView)

        case .ended, .cancelled, .failed:
            // --- Hide the preview when the gesture ends ---
            previewView.isHidden = true

        default:
            // Other states like .changed are ignored for now
            break
        }
    }
}
