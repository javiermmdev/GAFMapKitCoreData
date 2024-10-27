import UIKit
import Kingfisher

/// View controller to display details of a specific transformation.
final class TransformationDetailModalController: UIViewController {
    
    // Image view displaying the transformation's image.
    @IBOutlet weak var transformationImageView: UIImageView!
    // Label displaying the transformation's name.
    @IBOutlet weak var transformationNameLabel: UILabel!
    // Label displaying additional transformation information.
    @IBOutlet weak var transformationInfoLabel: UILabel!
    
    // Holds the transformation object to be displayed.
    var transformation: Transformation?
       
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar() // Configure the navigation bar with close functionality.
        
        // Sets up the view with transformation details if available.
        if let transformation = transformation {
            transformationNameLabel.text = transformation.name
            transformationInfoLabel.text = transformation.info
            
            if let imageUrl = URL(string: transformation.photo) {
                transformationImageView.kf.setImage(with: imageUrl) // Loads the image using Kingfisher.
            } else {
                transformationImageView.image = nil
            }
        }
    }
       
    /// Configures the navigation bar with a close button.
    private func configureNavigationBar() {
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeModal))
        navigationItem.rightBarButtonItem = closeButton
        navigationItem.title = transformation?.name ?? "Detail"
    }
       
    /// Dismisses the modal view when the close button is tapped.
    @objc func closeModal() {
        dismiss(animated: true, completion: nil)
    }
}
