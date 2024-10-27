/// Model representing a Location object from the API
struct ApiLocation: Codable {
    /// Unique identifier for the location
    let id: String?
    
    /// Date associated with the location, often used to indicate when the location was recorded
    let date: String?
    
    /// Latitude coordinate of the location
    let latitude: String?
    
    /// Longitude coordinate of the location
    let longitude: String?
    
    /// Associated hero who was present at this location
    let hero: ApiHero?
    
    // MARK: - Coding Keys
    /// CodingKeys used to map API response fields to properties
    /// Maps API fields to Swift properties where names differ
    enum CodingKeys: String, CodingKey {
        case id
        case date = "dateShow"
        case latitude = "latitud"
        case longitude = "longitud"
        case hero
    }
}
