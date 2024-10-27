import UIKit

/// Controller for displaying the splash screen.
class SplashController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Adds a 1.5-second delay before navigating to the next screen.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // If a token exists, navigate directly to the heroes list; otherwise, show the login screen.
            if SecureDataStore.shared.getToken() != nil {
                let heroesVC = HeroesController()
                heroesVC.navigationItem.hidesBackButton = true // Hide the "Back" button.
                self.navigationController?.pushViewController(heroesVC, animated: true)
            } else {
                let loginVC = LoginController()
                loginVC.navigationItem.hidesBackButton = true // Hide the "Back" button.
                self.navigationController?.pushViewController(loginVC, animated: true)
            }
        }
    }
}
