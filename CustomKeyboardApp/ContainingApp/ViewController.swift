import UIKit

class ViewController: UIViewController {

    private let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5.0
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.title = "Custom Keyboard Test"

        self.view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            textView.heightAnchor.constraint(equalToConstant: 200)
        ])

        let instructionsLabel = UILabel()
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionsLabel.text = "Tap in the text view to use the custom keyboard.\n\nYou need to enable the keyboard in Settings > General > Keyboard > Keyboards > Add New Keyboard..."
        instructionsLabel.numberOfLines = 0
        instructionsLabel.textAlignment = .center
        instructionsLabel.textColor = .gray

        self.view.addSubview(instructionsLabel)

        NSLayoutConstraint.activate([
            instructionsLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 20),
            instructionsLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            instructionsLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
        ])
    }
}
