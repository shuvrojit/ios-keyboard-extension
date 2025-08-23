import UIKit

class KeyButton: UIButton {

    enum KeyType {
        case character
        case backspace
        case space
        case returnKey
        case nextKeyboard
        case shift
        case switchToNumeric
        case switchToAlphabetic
        case switchToSymbolic
    }

    var keyType: KeyType = .character

    // Store colors to be used
    private var normalBackgroundColor: UIColor = .white
    private var highlightedBackgroundColor: UIColor = .lightGray

    convenience init(type: KeyType, title: String) {
        self.init(frame: .zero)
        self.keyType = type
        self.setTitle(title, for: .normal)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupAppearance() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 5
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowRadius = 1

        // Add highlighting effect
        self.addTarget(self, action: #selector(touchDown), for: .touchDown)
        self.addTarget(self, action: #selector(touchUp), for: .touchUpInside)
        self.addTarget(self, action: #selector(touchUp), for: .touchUpOutside)
        self.addTarget(self, action: #selector(touchUp), for: .touchDragExit)

        updateAppearance(for: self.traitCollection.userInterfaceStyle)
    }

    func updateAppearance(for style: UIUserInterfaceStyle) {
        if style == .dark {
            normalBackgroundColor = UIColor(white: 0.4, alpha: 1.0)
            highlightedBackgroundColor = UIColor(white: 0.6, alpha: 1.0)
            setTitleColor(.white, for: .normal)
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.5
        } else {
            normalBackgroundColor = .white
            highlightedBackgroundColor = UIColor(red: 0.82, green: 0.84, blue: 0.86, alpha: 1.0) // A light gray color
            setTitleColor(.black, for: .normal)
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.2
        }

        // Respect the selected state
        if isSelected && keyType == .shift {
             self.backgroundColor = .systemBlue
        } else {
             self.backgroundColor = normalBackgroundColor
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            updateAppearance(for: self.traitCollection.userInterfaceStyle)
        }
    }

    override var isSelected: Bool {
        didSet {
            updateAppearance(for: self.traitCollection.userInterfaceStyle)
        }
    }

    @objc private func touchDown() {
        self.backgroundColor = highlightedBackgroundColor
    }

    @objc private func touchUp() {
        // After touch up, revert to the correct appearance based on selection and style
        updateAppearance(for: self.traitCollection.userInterfaceStyle)
    }
}
