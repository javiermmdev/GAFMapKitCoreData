import MapKit

/// Class to display hero locations on a map; inherits from `NSObject` and conforms to the `MKAnnotation` protocol.
class HeroAnnotation: NSObject, MKAnnotation {
    var title: String?  // Optional title for the map annotation.
    var coordinate: CLLocationCoordinate2D  // Coordinate property required by MKAnnotation.
    
    /// Initializer for creating an annotation with a title and coordinate.
    /// - Parameters:
    ///   - title: Title to display on the annotation.
    ///   - coordinate: Coordinate for the annotation's location on the map.
    init(title: String? = nil, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}
