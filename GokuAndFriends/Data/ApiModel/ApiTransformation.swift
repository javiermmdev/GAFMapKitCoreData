/// Model representing a Transformation object from the API
struct ApiTransformation: Codable {
    /// Unique identifier for the transformation
    let id: String?
    
    /// Name of the transformation (e.g., Super Saiyan)
    let name: String?
    
    /// URL or path to an image representing the transformation
    let photo: String?
    
    /// Description or details about the transformation
    let description: String?
    
    /// Associated hero who undergoes this transformation
    let hero: ApiHero?
}
