import Foundation

/// Domain model for a Transformation.
/// This model is used in the presentation layer.
struct Transformation: Hashable, Decodable {
    let id: String         // Unique identifier for the transformation
    let name: String       // Name of the transformation (e.g., "Super Saiyan")
    let info: String       // Description or additional information about the transformation
    let photo: String      // URL or path to an image representing the transformation

    /// Initializer to create a `Transformation` from a Core Data `MOTransformation` object.
    /// - Parameter moTransformation: The `MOTransformation` object from Core Data.
    init(moTransformation: MOTransformation) {
        self.id = moTransformation.id ?? ""             // Assigns the ID, or an empty string if nil
        self.name = moTransformation.name ?? ""         // Assigns the name, or an empty string if nil
        self.info = moTransformation.info ?? ""         // Assigns the info, or an empty string if nil
        self.photo = moTransformation.photo ?? ""       // Assigns the photo URL, or an empty string if nil
    }
}
