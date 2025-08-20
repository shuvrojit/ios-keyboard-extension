import UIKit

class KeyboardViewController: UIInputViewController {

    // MARK: - Properties

    enum ShiftState {
        case off, on, capsLock
    }

    private var shiftState: ShiftState = .off {
        didSet { setupKeyboard() }
    }

    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    private lazy var previewView: KeyPreviewView = {
        let view = KeyPreviewView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private lazy var accentPopupView: AccentPopupView = {
        let view = AccentPopupView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.onAccentCharacterTapped = { [weak self] character in
            self?.textDocumentProxy.insertText(character)
            self?.hideAccentPopup()
        }
        return view
    }()

    private var highlightedAccentButton: UIButton?
    private var backspaceTimer: Timer?
    private var heightConstraint: NSLayoutConstraint?

    private let accentCharacters: [String: [String]] = [
        "e": ["é", "ê", "ë", "è", "ē", "ė", "ę"], "y": ["ý", "ÿ"], "u": ["ú", "û", "ü", "ù", "ū"],
        "i": ["í", "î", "ï", "ì", "ī"], "o": ["ó", "ô", "ö", "ò", "ō", "õ"], "a": ["á", "â", "ä", "à", "æ", "ã", "å", "ā"],
        "s": ["ś", "š", "ß"], "l": ["ł"], "z": ["ź", "ż", "ž"], "c": ["ç", "ć", "č"], "n": ["ñ", "ń"]
    ]

    // MARK: - Lifecycle & Layout

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let inputView = self.inputView else { return }
        let heightConstraint = inputView.heightAnchor.constraint(equalToConstant: 271)
        heightConstraint.priority = .required - 1
        heightConstraint.isActive = true
        self.heightConstraint = heightConstraint

        setupKeyboard()
        updateKeyboardAppearance()
        impactFeedbackGenerator.prepare()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateKeyboardHeight()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            updateKeyboardAppearance()
        }
    }

    // MARK: - Setup & Appearance

    private func setupKeyboard() {
        guard let inputView = self.inputView else { return }
        inputView.subviews.forEach { $0.removeFromSuperview() }

        let keyboardView = KeyboardLayout.create(target: self, action: #selector(keyPressed), previewAction: #selector(handlePreviewGesture), shiftState: shiftState)

        inputView.addSubview(keyboardView)
        inputView.addSubview(previewView)
        inputView.addSubview(accentPopupView)

        NSLayoutConstraint.activate([
            keyboardView.topAnchor.constraint(equalTo: inputView.topAnchor),
            keyboardView.bottomAnchor.constraint(equalTo: inputView.bottomAnchor),
            keyboardView.leadingAnchor.constraint(equalTo: inputView.leadingAnchor),
            keyboardView.trailingAnchor.constraint(equalTo: inputView.trailingAnchor)
        ])
    }

    private func updateKeyboardAppearance() {
        if traitCollection.userInterfaceStyle == .dark {
            inputView?.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        } else {
            inputView?.backgroundColor = UIColor(red: 0.82, green: 0.84, blue: 0.86, alpha: 1.0)
        }
    }

    private func updateKeyboardHeight() {
        guard let heightConstraint = self.heightConstraint else { return }
        let isLandscape = view.frame.width > view.frame.height
        let portraitHeight: CGFloat = 271
        let landscapeHeight: CGFloat = 206
        let bottomSafeArea = view.safeAreaInsets.bottom
        let newHeight = (isLandscape ? landscapeHeight : portraitHeight) + bottomSafeArea
        if heightConstraint.constant != newHeight {
            heightConstraint.constant = newHeight
        }
    }

    // MARK: - Actions & Gestures

    @objc private func keyPressed(_ sender: UIButton) {
        impactFeedbackGenerator.impactOccurred()
        guard let keyButton = sender as? KeyButton else { return }
        stopBackspaceTimer()

        switch keyButton.keyType {
        case .character:
            if let title = keyButton.title(for: .normal) { textDocumentProxy.insertText(title) }
            if shiftState == .on { shiftState = .off }
        case .backspace:
            textDocumentProxy.deleteBackward()
        case .space:
            textDocumentProxy.insertText(" ")
        case .returnKey:
            textDocumentProxy.insertText("\n")
        case .nextKeyboard:
            advanceToNextInputMode()
        case .shift:
            switch shiftState {
            case .off: shiftState = .on
            case .on: shiftState = .off
            case .capsLock: shiftState = .off
            }
        }
    }

    @objc private func handlePreviewGesture(_ gesture: UILongPressGestureRecognizer) {
        guard let button = gesture.view as? KeyButton, let inputView = self.inputView else { return }
        if button.keyType == .backspace {
            handleBackspaceGesture(gesture)
            return
        }
        let touchLocation = gesture.location(in: inputView)
        switch gesture.state {
        case .began:
            showPreview(for: button, in: inputView)
        case .changed:
            if !accentPopupView.isHidden { updateHighlightedAccentButton(at: touchLocation, in: inputView) }
        case .ended:
            if !accentPopupView.isHidden {
                if let finalButton = highlightedAccentButton, let character = finalButton.title(for: .normal) {
                    textDocumentProxy.insertText(character)
                } else {
                    if let baseCharacter = button.title(for: .normal) { textDocumentProxy.insertText(baseCharacter) }
                }
            }
            hideAccentPopup()
            previewView.isHidden = true
        case .cancelled, .failed:
            hideAccentPopup()
            previewView.isHidden = true
        default: break
        }
    }

    private func handleBackspaceGesture(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            textDocumentProxy.deleteBackward()
            backspaceTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleBackspaceTimer), userInfo: nil, repeats: true)
        case .ended, .cancelled, .failed:
            stopBackspaceTimer()
        default: break
        }
    }

    @objc private func handleBackspaceTimer() {
        textDocumentProxy.deleteBackward()
    }

    private func stopBackspaceTimer() {
        backspaceTimer?.invalidate()
        backspaceTimer = nil
    }

    private func showPreview(for button: KeyButton, in inputView: UIView) {
        if button.keyType == .backspace { return }
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

    private func updateHighlightedAccentButton(at location: CGPoint, in inputView: UIView) {
        let locationInPopup = inputView.convert(location, to: accentPopupView)
        let newHighlightedButton = accentPopupView.button(at: locationInPopup)
        if newHighlightedButton != highlightedAccentButton {
            highlightedAccentButton?.backgroundColor = accentPopupView.buttonBackgroundColor
            newHighlightedButton?.backgroundColor = accentPopupView.buttonHighlightedColor
            highlightedAccentButton = newHighlightedButton
        }
    }

    private func hideAccentPopup() {
        accentPopupView.isHidden = true
        highlightedAccentButton?.backgroundColor = accentPopupView.buttonBackgroundColor
        highlightedAccentButton = nil
    }
}
