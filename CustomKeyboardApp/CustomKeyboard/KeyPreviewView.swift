import UIKit

/// A view that displays a preview of a key when it is pressed.
/// This view is typically shown above the key being pressed and displays the key's character
/// in a larger font. It has a distinctive shape with a "tail" pointing down towards the key.
class KeyPreviewView: UIView {

    // MARK: - Properties

    /// The label that displays the character of the key.
    private let characterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 40, weight: .light)
        label.textAlignment = .center
        return label
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        // Basic view setup
        self.backgroundColor = .clear
        self.clipsToBounds = false

        // Add the character label as a subview
        self.addSubview(characterLabel)

        // Setup constraints for the label to be centered
        NSLayoutConstraint.activate([
            characterLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            characterLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -10) // Adjust position slightly up
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    /// Sets the character to be displayed in the preview.
    /// - Parameter character: The character to display.
    func setCharacter(_ character: String) {
        self.characterLabel.text = character
    }

    // MARK: - Drawing

    /// Overridden to draw the custom shape of the preview view.
    /// The shape is a rounded rectangle with a trapezoidal "tail" at the bottom.
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        // Get the current graphics context
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // Define the properties of the shape
        let cornerRadius: CGFloat = 10.0
        let tailWidth: CGFloat = 20.0
        let tailHeight: CGFloat = 10.0

        // Create the path for the shape
        let path = UIBezierPath()

        // Move to the starting point (top-left corner)
        path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY))

        // Add the top line
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))

        // Add the top-right corner
        path.addArc(withCenter: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: -CGFloat.pi / 2,
                    endAngle: 0,
                    clockwise: true)

        // Add the right line
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius - tailHeight))

        // Add the bottom-right corner
        path.addArc(withCenter: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius - tailHeight),
                    radius: cornerRadius,
                    startAngle: 0,
                    endAngle: CGFloat.pi / 2,
                    clockwise: true)

        // Add the bottom line (right part)
        path.addLine(to: CGPoint(x: rect.midX + tailWidth / 2, y: rect.maxY - tailHeight))

        // Add the tail
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX - tailWidth / 2, y: rect.maxY - tailHeight))

        // Add the bottom line (left part)
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - tailHeight))

        // Add the bottom-left corner
        path.addArc(withCenter: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius - tailHeight),
                    radius: cornerRadius,
                    startAngle: CGFloat.pi / 2,
                    endAngle: CGFloat.pi,
                    clockwise: true)

        // Add the left line
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))

        // Add the top-left corner
        path.addArc(withCenter: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: CGFloat.pi,
                    endAngle: -CGFloat.pi / 2,
                    clockwise: true)

        path.close()

        // Set the fill color and fill the path
        // The color will be updated based on the theme
        let fillColor = (self.traitCollection.userInterfaceStyle == .dark) ? UIColor(white: 0.3, alpha: 1.0) : .white
        fillColor.setFill()
        path.fill()

        // Add a shadow
        context.setShadow(offset: CGSize(width: 0, height: 2), blur: 4, color: UIColor.black.withAlphaComponent(0.3).cgColor)
    }

    /// Update the view's display when the trait collection changes (e.g., light/dark mode).
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            // Redraw the view to update the color
            self.setNeedsDisplay()
            // Update label color
            self.characterLabel.textColor = (self.traitCollection.userInterfaceStyle == .dark) ? .white : .black
        }
    }
}
