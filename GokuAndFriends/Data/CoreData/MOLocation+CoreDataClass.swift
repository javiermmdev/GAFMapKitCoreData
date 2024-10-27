import Foundation
import CoreData

/// Core Data class generated by Xcode using Editor -> Create NSManagedObject Subclass
/// Requires the Core Data model to be selected in the project navigator.
@objc(MOLocation)
public class MOLocation: NSManagedObject {

}

extension MOLocation {

    /// Fetch request for retrieving `MOLocation` entities from Core Data
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MOLocation> {
        return NSFetchRequest<MOLocation>(entityName: "CDLocation")
    }

    @NSManaged public var id: String?          // Unique identifier for the location
    @NSManaged public var latitude: String?    // Latitude coordinate of the location
    @NSManaged public var longitude: String?   // Longitude coordinate of the location
    @NSManaged public var date: String?        // Date associated with the location, usually when it was recorded
    @NSManaged public var hero: MOHero?        // Associated hero for this location

}

// MARK: - Identifiable Conformance

extension MOLocation: Identifiable {

}