import CoreData

/// Enum representing the type of data persistency: on disk or in memory.
enum TypePersistency {
    case disk
    case inMemory
}

/// Core Data stack for managing data storage and retrieval.
class StoreDataProvider {
    
    /// Singleton instance of `StoreDataProvider`
    static var shared: StoreDataProvider = .init()
    
    /// Core Data managed object model loaded from the specified resource.
    static var managedModel: NSManagedObjectModel = {
        let bundle = Bundle(for: StoreDataProvider.self)
        guard let url = bundle.url(forResource: "Model", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Error loading model")
        }
        return model
    }()
    
    private let persistentContainer: NSPersistentContainer
    private let persistency: TypePersistency
    
    /// ManagedObjectContext with specified merge policy for handling conflicts
    /// on objects with the same unique key (constraints added in Model Editor).
    private var context: NSManagedObjectContext {
        let viewContext = persistentContainer.viewContext
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return viewContext
    }
    
    /// Initializes `StoreDataProvider` with a specified persistency type.
    /// - Parameter persistency: Specifies whether to use disk or in-memory storage.
    init(persistency: TypePersistency = .disk) {
        self.persistency = persistency
        self.persistentContainer = NSPersistentContainer(name: "Model", managedObjectModel: Self.managedModel)
        if self.persistency == .inMemory {
            let persistentStore = persistentContainer.persistentStoreDescriptions.first
            persistentStore?.url = URL(filePath: "/dev/null")
        }
        self.persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Error loading database \(error.localizedDescription)")
            }
        }
    }
    
    /// Executes a fetch request for a specific `NSManagedObject` type.
    /// - Parameter request: The fetch request to execute.
    /// - Throws: An error if the fetch fails.
    /// - Returns: An array of fetched results.
    func perform<T: NSFetchRequestResult>(request: NSFetchRequest<T>) throws -> [T] {
        return try context.fetch(request)
    }
    
    /// Saves the context if there are pending changes.
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                debugPrint("Error saving context \(error.localizedDescription)")
            }
        }
    }
}


/// Extension with functions to insert and retrieve data from the database.
extension StoreDataProvider {
    
    /// Inserts `MOHero` entities into Core Data from an array of `ApiHero` objects.
    func add(heroes: [ApiHero]) {
        for hero in heroes {
            let newHero = MOHero(context: context)
            newHero.id = hero.id
            newHero.name = hero.name
            newHero.info = hero.description
            newHero.favorite = hero.favorite ?? false
            newHero.photo = hero.photo
        }
        save()
    }
    
    /// Retrieves heroes, optionally filtered and sorted by name.
    /// - Parameters:
    ///   - filter: Optional predicate for filtering heroes.
    ///   - sortAscending: Determines if sorting should be ascending by name.
    /// - Returns: An array of `MOHero` objects.
    func fetchHeroes(filter: NSPredicate?,
                     sortAscending: Bool = true) -> [MOHero] {
        let request = MOHero.fetchRequest()
        request.predicate = filter
        let sortDescriptor = NSSortDescriptor(keyPath: \MOHero.name, ascending: sortAscending)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            return try self.perform(request: request)
        } catch {
            debugPrint("Error loading heroes \(error.localizedDescription)")
            return []
        }
        // For just counting records, using `count` on context is more efficient.
        // try? context.count(for: request)
    }
    
    /// Inserts `MOLocation` entities from an array of `ApiLocation` objects.
    /// Associates each location with a hero if one exists.
    func add(locations: [ApiLocation]) {
        for location in locations {
            let newLocation = MOLocation(context: context)
            newLocation.id = location.id
            newLocation.latitude = location.latitude
            newLocation.longitude = location.longitude
            newLocation.date = location.date
            
            if let heroId = location.hero?.id {
                let predicate = NSPredicate(format: "id == %@", heroId)
                let hero = fetchHeroes(filter: predicate).first
                newLocation.hero = hero
            }
        }
        save()
    }
    
    /// Inserts `MOTransformation` entities from an array of `ApiTransformation` objects.
    /// Associates each transformation with a hero if one exists.
    func add(transformations: [ApiTransformation]) {
        for transformation in transformations {
            let newTransformation = MOTransformation(context: context)
            newTransformation.id = transformation.id
            newTransformation.name = transformation.name
            newTransformation.info = transformation.description
            newTransformation.photo = transformation.photo
            
            if let heroId = transformation.hero?.id {
                let predicate = NSPredicate(format: "id == %@", heroId)
                let hero = fetchHeroes(filter: predicate).first
                newTransformation.hero = hero
            }
        }
        save()
    }
    
    /// Clears all data in the database by deleting `MOHero`, `MOLocation`, and `MOTransformation` entities.
    func clearBBDD() {
        let batchDeleteHeroes = NSBatchDeleteRequest(fetchRequest: MOHero.fetchRequest())
        let batchDeleteLocations = NSBatchDeleteRequest(fetchRequest: MOLocation.fetchRequest())
        let batchDeleteTransformations = NSBatchDeleteRequest(fetchRequest: MOTransformation.fetchRequest())
        
        let deleteTasks = [batchDeleteHeroes, batchDeleteLocations, batchDeleteTransformations]
        
        for task in deleteTasks {
            do {
                try context.execute(task)
                context.reset()
            } catch {
                debugPrint("Error clearing database \(error.localizedDescription)")
            }
        }
    }
}
