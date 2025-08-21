import UIKit

class ViewController: UIViewController {

    // MARK: - UI Properties

    private let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5.0
        return textView
    }()

    private let instructionsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tap in the text view to use the custom keyboard.\n\nYou need to enable the keyboard in Settings > General > Keyboard > Keyboards > Add New Keyboard..."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .gray
        return label
    }()

    private let hapticsSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.title = "Custom Keyboard Settings"

        setupLayout()
        configureSettings()
    }

    // MARK: - UI Setup

    private func setupLayout() {
        // Add subviews
        view.addSubview(textView)
        view.addSubview(instructionsLabel)

        // Create settings UI
        let hapticsLabel = UILabel()
        hapticsLabel.translatesAutoresizingMaskIntoConstraints = false
        hapticsLabel.text = "Enable Haptic Feedback"

        let settingsStackView = UIStackView(arrangedSubviews: [hapticsLabel, hapticsSwitch])
        settingsStackView.translatesAutoresizingMaskIntoConstraints = false
        settingsStackView.axis = .horizontal
        settingsStackView.spacing = 8
        view.addSubview(settingsStackView)

        // Set up constraints
        NSLayoutConstraint.activate([
            // Text View
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.heightAnchor.constraint(equalToConstant: 150), // Adjusted height

            // Instructions Label
            instructionsLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 20),
            instructionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Settings Stack View
            settingsStackView.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 20),
            settingsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // MARK: - Settings Configuration

    private func configureSettings() {
        // Set the initial state of the switch from the shared settings
        hapticsSwitch.isOn = Settings.hapticsEnabled

        // Add a target to handle value changes
        hapticsSwitch.addTarget(self, action: #selector(hapticsSwitchChanged), for: .valueChanged)
    }

    /// Called when the haptics switch is toggled.
    @objc private func hapticsSwitchChanged(_ sender: UISwitch) {
        // Save the new value to the shared UserDefaults via the Settings manager
        Settings.hapticsEnabled = sender.isOn
    }
}
