import MapKit

/// Custom view class to display a custom annotation view on the map.
class HeroAnnotationView: MKAnnotationView {
    
    /// Identifier for reusing the annotation view in the map.
    static var identifier: String {
        return String(describing: HeroAnnotationView.self)
    }

    /// Initializes the annotation view with a custom frame and callout settings.
    /// - Parameters:
    ///   - annotation: The annotation associated with the view.
    ///   - reuseIdentifier: Reuse identifier for the view.
    override init(annotation: (any MKAnnotation)?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        // Sets the view's frame dimensions.
        self.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        // Centers the view over the annotation point.
        self.centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
        
        // Enables callout display when the annotation is tapped.
        self.canShowCallout = true
        
        // Configures the view's appearance.
        self.setupView()
    }
    
    /// Required initializer with NSCoder, not implemented.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Sets up the custom view for the annotation, including background image and callout button.
    func setupView() {
        backgroundColor = .clear
        
        // Adds a custom image to represent the annotation.
        let view = UIImageView(image: UIImage(resource: .bolaDragon))
        addSubview(view)
        view.frame = self.frame
        
        // Adds an info button on the right side of the callout.
        rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    }
}
