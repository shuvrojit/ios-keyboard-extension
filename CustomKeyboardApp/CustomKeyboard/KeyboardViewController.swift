import UIKit

class KeyboardViewController: UIInputViewController {

    // ... (Properties and most methods are the same)

    // MARK: - Actions & Gestures

    @objc private func keyPressed(_ sender: UIButton) {
        triggerHapticFeedback()
        guard let keyButton = sender as? KeyButton else { return }
        stopBackspaceTimer()

        switch keyButton.keyType {
        case .character:
            if let title = keyButton.title(for: .normal) { textDocumentProxy.insertText(title) }
            // Only turn off shift if it's in the single-use 'on' state, not caps lock
            if shiftState == .on {
                shiftState = .off
            }
        case .backspace:
            textDocumentProxy.deleteBackward()
        case .space:
            textDocumentProxy.insertText(" ")
        case .returnKey:
            textDocumentProxy.insertText("\n")
        case .nextKeyboard:
            advanceToNextInputMode()
        case .shift:
            // A single tap on the shift key cycles through states.
            switch shiftState {
            case .off:
                shiftState = .on
            case .on:
                shiftState = .off
            case .capsLock:
                shiftState = .off
            }
        case .switchToNumeric:
            keyboardLayoutType = .numeric
        case .switchToAlphabetic:
            keyboardLayoutType = .alphabetic
        case .switchToSymbolic:
            keyboardLayoutType = .symbolic
        }
    }

    @objc private func handlePreviewGesture(_ gesture: UILongPressGestureRecognizer) {
        // ... (This method remains the same)
    }

    private func handleBackspaceGesture(_ gesture: UILongPressGestureRecognizer) {
        // ... (This method remains the same)
    }

    @objc private func handleBackspaceTimer() {
        // ... (This method remains the same)
    }

    /// Handles the double-tap gesture on the shift key to toggle Caps Lock.
    @objc private func handleShiftDoubleTap(_ gesture: UITapGestureRecognizer) {
        // On a successful double-tap, always engage caps lock.
        shiftState = .capsLock
    }

    private func stopBackspaceTimer() {
        // ... (This method remains the same)
    }

    // ... (The rest of the file is the same)
}
