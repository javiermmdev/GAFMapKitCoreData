import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // Called when the scene is about to connect to a session
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        // Ensure the scene is a UIWindowScene; if not, exit early
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Initialize the main application window with the scene
        window = UIWindow(windowScene: windowScene)
        
        // Set the initial view controller to be the splash screen within a navigation controller
        let splashVC = SplashController()
        let navigation = UINavigationController(rootViewController: splashVC)
        window?.rootViewController = navigation
        
        // Display the window on the screen
        window?.makeKeyAndVisible()
    }
}
