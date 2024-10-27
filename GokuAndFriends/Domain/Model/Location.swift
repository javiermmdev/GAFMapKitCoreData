import MapKit

/// Domain model for a Location.
/// This model is used in the presentation layer.
struct Location: Hashable, Decodable {
    let id: String         // Unique identifier for the location
    let date: String       // Date associated with the location
    let latitude: String   // Latitude as a string
    let longitude: String  // Longitude as a string
    
    /// Initializer to map a Core Data `MOLocation` object to a `Location` instance.
    /// - Parameter moLocation: The `MOLocation` object from Core Data.
    init(moLocation: MOLocation) {
        self.id = moLocation.id ?? ""               // Assigns the ID, or an empty string if nil
        self.date = moLocation.date ?? ""           // Assigns the date, or an empty string if nil
        self.latitude = moLocation.latitude ?? ""   // Assigns the latitude, or an empty string if nil
        self.longitude = moLocation.longitude ?? "" // Assigns the longitude, or an empty string if nil
    }
}

/// Extension to add functionality to the `Location` struct.
/// In this case, it provides a computed property to get coordinates,
/// filtering out invalid latitude and longitude values.
extension Location {
    var coordinate: CLLocationCoordinate2D? {
        guard let latitude = Double(self.latitude),
              let longitude = Double(self.longitude),
              abs(latitude) <= 90,
              abs(longitude) <= 180 else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
