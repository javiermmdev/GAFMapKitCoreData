/// Model representing a Hero object from the API
struct ApiHero: Codable {
    /// Unique identifier for the hero
    let id: String?
    
    /// Name of the hero
    let name: String?
    
    /// Description or bio of the hero
    let description: String?
    
    /// URL or path to the hero's photo
    let photo: String?
    
    /// Indicates if the hero is marked as a favorite
    var favorite: Bool?
}
