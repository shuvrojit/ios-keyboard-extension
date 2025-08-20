import UIKit

/// A view that displays a popup with accent character options when a key is long-pressed.
class AccentPopupView: UIView {

    // MARK: - Properties

    /// A closure that is called when an accent character button is tapped.
    /// The closure receives the selected character as a `String`.
    var onAccentCharacterTapped: ((String) -> Void)?

    /// The background color for the buttons in their normal state, dependent on the theme.
    var buttonBackgroundColor: UIColor {
        return self.traitCollection.userInterfaceStyle == .dark ? UIColor(white: 0.4, alpha: 1.0) : .white
    }

    /// The background color for the buttons when they are highlighted.
    var buttonHighlightedColor: UIColor {
        return self.traitCollection.userInterfaceStyle == .dark ? UIColor(white: 0.6, alpha: 1.0) : .lightGray
    }

    /// The stack view that holds the accent character buttons.
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Setup

    /// Sets up the view's appearance and subviews.
    private func setupView() {
        // Configure the view's appearance to look like a popup
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4

        // Add the stack view which will contain the buttons
        self.addSubview(stackView)

        // Add constraints to the stack view to pin it to the edges of this view with some padding
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8)
        ])

        // Initial update for the theme
        updateTheme()
    }

    /// Updates the colors of the view and its subviews based on the current trait collection (light/dark mode).
    private func updateTheme() {
        if self.traitCollection.userInterfaceStyle == .dark {
            self.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
            stackView.arrangedSubviews.forEach { button in
                button.setTitleColor(.white, for: .normal)
                (button as? UIButton)?.backgroundColor = buttonBackgroundColor
            }
        } else {
            self.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            stackView.arrangedSubviews.forEach { button in
                button.setTitleColor(.black, for: .normal)
                (button as? UIButton)?.backgroundColor = buttonBackgroundColor
            }
        }
    }

    // MARK: - Public Methods

    /// Configures the popup view with a list of accent characters.
    func configure(with characters: [String]) {
        // ... (same as before)
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for character in characters {
            let button = UIButton(type: .system)
            button.setTitle(character, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
            button.layer.cornerRadius = 5
            button.addTarget(self, action: #selector(accentButtonTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        updateTheme()
    }

    /// Finds the accent button at a given point within this view's coordinate space.
    /// This is used to detect which accent key the user is hovering over.
    /// - Parameter point: The point to check, in the coordinate space of this view.
    /// - Returns: The `UIButton` at the given point, or `nil` if no button is found.
    func button(at point: CGPoint) -> UIButton? {
        for case let button as UIButton in stackView.arrangedSubviews {
            let buttonFrameInThisView = button.convert(button.bounds, to: self)
            if buttonFrameInThisView.contains(point) {
                return button
            }
        }
        return nil
    }

    // MARK: - Actions

    /// Called when an accent character button is tapped.
    @objc private func accentButtonTapped(_ sender: UIButton) {
        guard let character = sender.title(for: .normal) else { return }
        onAccentCharacterTapped?(character)
    }

    /// This method is called when the view's trait collection changes.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            updateTheme()
        }
    }
}
