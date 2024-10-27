import Foundation

/// Domain model for a Hero.
/// This model is used in the presentation layer.
struct Hero: Hashable, Decodable {
    
    let id: String        // Unique identifier for the hero
    let name: String      // Name of the hero
    let info: String      // Description or biography of the hero
    let photo: String     // URL or path to the hero's photo
    let favorite: Bool    // Indicates if the hero is marked as a favorite
    
    /// Initializer to map a Core Data `MOHero` object to a `Hero` instance.
    /// - Parameter moHero: The `MOHero` object from Core Data.
    init(moHero: MOHero) {
        self.id = moHero.id ?? ""            // Assigns the ID, or an empty string if nil
        self.name = moHero.name ?? ""        // Assigns the name, or an empty string if nil
        self.info = moHero.info ?? ""        // Assigns the info, or an empty string if nil
        self.photo = moHero.photo ?? ""      // Assigns the photo URL, or an empty string if nil
        self.favorite = moHero.favorite      // Assigns the favorite status directly
    }
}
