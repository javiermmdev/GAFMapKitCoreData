import UIKit

/// Controller for handling the login view and user authentication.
class LoginController: UIViewController {
    
    // References to the email and password text fields.
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // Instance of the Login use case.
    private let loginUseCase = LoginUseCase()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBorderColor() // Configure the appearance of the text fields.
        configurePasswordField() // Configure the password field with the toggle button.
    }
    
    // MARK: - Login Button Action
    /// Action triggered when the login button is tapped.
    /// - Validates that the email and password fields are not empty.
    /// - If valid, attempts to log in using the Login use case.
    @IBAction func loginTappedButton(_ sender: Any) {
        // Retrieve values from text fields.
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            // Show an error if either field is empty.
            showAlert(message: "Por favor, introduce tu email y contraseña.")
            return
        }

        // Call the login use case.
        loginUseCase.login(username: email, password: password) { [weak self] result in
            switch result {
            case .success:
                // Navigate to the heroes screen if login succeeds.
                DispatchQueue.main.async {
                    self?.goToHeroes()
                }
            case .failure(let error):
                // Show an error message if authentication fails.
                DispatchQueue.main.async {
                    self?.showAlert(message: error.description)
                }
            }
        }
    }

    // MARK: - Configure Password Field with Toggle Button
    /// Configures the password text field to include a toggle button to show/hide the password.
    private func configurePasswordField() {
        passwordTextField.isSecureTextEntry = true // Set as secure by default
        
        // Create the toggle button for showing/hiding password
        let toggleButton = UIButton(type: .custom)
        toggleButton.setImage(UIImage(systemName: "eye"), for: .normal)
        toggleButton.setImage(UIImage(systemName: "eye.slash"), for: .selected)
        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        // Set the button size and add padding
        toggleButton.frame = CGRect(x: 0, y: 0, width: 30, height: 20)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 20)) // Adjust padding width as needed
        paddingView.addSubview(toggleButton)
        
        // Center the button in the padding view
        toggleButton.center = paddingView.center

        // Set the padding view as the right view of the text field
        passwordTextField.rightView = paddingView
        passwordTextField.rightViewMode = .always
    }

    // MARK: - Toggle Password Visibility
    /// Toggles the visibility of the password in the text field.
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle() // Toggle secure entry
        sender.isSelected.toggle() // Toggle button image
    }

    // MARK: - Navigate to Heroes Screen
    /// Navigates to the Heroes screen upon successful login.
    private func goToHeroes() {
        let heroesVC = HeroesController()
        navigationController?.pushViewController(heroesVC, animated: true)
    }
    
    // MARK: - Show Alert
    /// Displays an alert with a specified message.
    /// - Parameter message: The message to display in the alert.
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Configure Text Field Border Color
    /// Sets the border color and style for the email and password text fields.
    private func configureBorderColor() {
        emailTextField.layer.borderWidth = 1.0
        emailTextField.layer.cornerRadius = 5.0
        emailTextField.layer.borderColor = UIColor.darkGray.cgColor
        
        passwordTextField.layer.borderWidth = 1.0
        passwordTextField.layer.cornerRadius = 5.0
        passwordTextField.layer.borderColor = UIColor.darkGray.cgColor
    }
}
