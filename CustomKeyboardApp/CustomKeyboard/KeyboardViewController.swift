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

    /// The view that shows a preview of a standard key being pressed.
    private lazy var previewView: KeyPreviewView = {
        let view = KeyPreviewView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true // Initially hidden
        return view
    }()

    /// The view that shows accent character options when a key is long-pressed.
    private lazy var accentPopupView: AccentPopupView = {
        let view = AccentPopupView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true // Initially hidden

        // This closure is called when a user taps an accent button in the popup.
        // Note: This handles the case where the user taps an accent, but the main logic
        // for long-press-and-drag selection is in `handlePreviewGesture`.
        view.onAccentCharacterTapped = { [weak self] character in
            self?.textDocumentProxy.insertText(character)
            self?.hideAccentPopup()
        }
        return view
    }()

    /// A property to keep track of the currently highlighted accent button as the user drags their finger.
    private var highlightedAccentButton: UIButton?

    /// A dictionary mapping base characters to their accented versions.
    private let accentCharacters: [String: [String]] = [
        "e": ["é", "ê", "ë", "è", "ē", "ė", "ę"],
        "y": ["ý", "ÿ"],
        "u": ["ú", "û", "ü", "ù", "ū"],
        "i": ["í", "î", "ï", "ì", "ī"],
        "o": ["ó", "ô", "ö", "ò", "ō", "õ"],
        "a": ["á", "â", "ä", "à", "æ", "ã", "å", "ā"],
        "s": ["ś", "š", "ß"],
        "l": ["ł"],
        "z": ["ź", "ż", "ž"],
        "c": ["ç", "ć", "č"],
        "n": ["ñ", "ń"]
    ]

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupKeyboard()
        self.updateKeyboardAppearance()

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

    // MARK: - Keyboard Setup

    /// Sets up the keyboard layout and adds all views to the input view.
    private func setupKeyboard() {
        for subview in self.inputView?.subviews ?? [] {
            subview.removeFromSuperview()
        }

        let keyboardView = KeyboardLayout.create(
            target: self,
            action: #selector(keyPressed(_:)),
            previewAction: #selector(handlePreviewGesture(_:)),
            shiftState: self.shiftState
        )

        self.inputView?.addSubview(keyboardView)
        self.inputView?.addSubview(previewView)
        self.inputView?.addSubview(accentPopupView)

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

    // MARK: - Key Actions

    @objc private func keyPressed(_ sender: UIButton) {
        self.impactFeedbackGenerator.impactOccurred()
        guard let keyButton = sender as? KeyButton else { return }

        switch keyButton.keyType {
        case .character:
            if let title = keyButton.title(for: .normal) {
                self.textDocumentProxy.insertText(title)
            }
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
            switch self.shiftState {
            case .off: self.shiftState = .on
            case .on: self.shiftState = .off
            case .capsLock: self.shiftState = .off
            }
        }
    }

    // MARK: - Gesture Handling

    /// Handles the long press gesture for showing key previews and accent popups.
    @objc private func handlePreviewGesture(_ gesture: UILongPressGestureRecognizer) {
        guard let button = gesture.view as? KeyButton, let inputView = self.inputView else { return }
        let touchLocation = gesture.location(in: inputView)

        switch gesture.state {
        case .began:
            showPreview(for: button, in: inputView)

        case .changed:
            if !accentPopupView.isHidden {
                updateHighlightedAccentButton(at: touchLocation, in: inputView)
            }

        case .ended:
            if !accentPopupView.isHidden {
                if let finalButton = highlightedAccentButton, let character = finalButton.title(for: .normal) {
                    self.textDocumentProxy.insertText(character)
                } else {
                    if let baseCharacter = button.title(for: .normal) {
                        self.textDocumentProxy.insertText(baseCharacter)
                    }
                }
            }
            hideAccentPopup()
            previewView.isHidden = true

        case .cancelled, .failed:
            hideAccentPopup()
            previewView.isHidden = true

        default:
            break
        }
    }

    // MARK: - Helper Methods for Popups

    /// Shows the correct popup (accent or standard preview) for a given key.
    private func showPreview(for button: KeyButton, in inputView: UIView) {
        let baseCharacter = button.title(for: .normal) ?? ""

        if let accents = accentCharacters[baseCharacter.lowercased()] {
            accentPopupView.configure(with: accents)
            let buttonFrame = button.convert(button.bounds, to: inputView)
            let popupWidth = CGFloat(accents.count) * 45
            let popupHeight: CGFloat = 50
            let popupX = buttonFrame.midX - (popupWidth / 2)
            let popupY = buttonFrame.origin.y - popupHeight - 5
            accentPopupView.frame = CGRect(x: popupX, y: popupY, width: popupWidth, height: popupHeight)
            accentPopupView.isHidden = false
            inputView.bringSubviewToFront(accentPopupView)
        } else {
            previewView.setCharacter(baseCharacter)
            let buttonFrame = button.convert(button.bounds, to: inputView)
            let previewWidth: CGFloat = buttonFrame.width * 1.5
            let previewHeight: CGFloat = 80
            let previewX = buttonFrame.midX - (previewWidth / 2)
            let previewY = buttonFrame.origin.y - previewHeight + 10
            previewView.frame = CGRect(x: previewX, y: previewY, width: previewWidth, height: previewHeight)
            previewView.isHidden = false
            inputView.bringSubviewToFront(previewView)
        }
    }

    /// Updates the highlighting of the accent buttons based on the user's touch location.
    private func updateHighlightedAccentButton(at location: CGPoint, in inputView: UIView) {
        let locationInPopup = inputView.convert(location, to: accentPopupView)
        let newHighlightedButton = accentPopupView.button(at: locationInPopup)

        if newHighlightedButton != highlightedAccentButton {
            highlightedAccentButton?.backgroundColor = accentPopupView.buttonBackgroundColor
            newHighlightedButton?.backgroundColor = accentPopupView.buttonHighlightedColor
            highlightedAccentButton = newHighlightedButton
        }
    }

    /// Hides the accent popup and resets any related state.
    private func hideAccentPopup() {
        accentPopupView.isHidden = true
        highlightedAccentButton?.backgroundColor = accentPopupView.buttonBackgroundColor
        highlightedAccentButton = nil
    }
}
