import Foundation

/// Protocol defining the use case for managing transformations.
protocol TransformationUseCaseProtocol {
    /// Loads transformations for a given hero by ID.
    /// - Parameters:
    ///   - id: The ID of the hero whose transformations are being loaded.
    ///   - completion: Completion handler returning either a list of transformations or an error.
    func loadTransformationsForHeroWith(id: String, completion: @escaping ((Result<[Transformation], GAError>) -> Void))
}

/// Use case for loading a hero's transformations.
class TransformationUseCase: TransformationUseCaseProtocol {
    private var apiProvider: ApiProviderProtocol
    private var storeDataProvider: StoreDataProvider
    
    /// Initializer with dependency injection for testing purposes.
    /// - Parameters:
    ///   - apiProvider: The API provider to fetch transformations if not in the database.
    ///   - storeDataProvider: Core Data provider to fetch and store transformations.
    init(apiProvider: ApiProviderProtocol = ApiProvider(), storeDataProvider: StoreDataProvider = .shared) {
        self.apiProvider = apiProvider
        self.storeDataProvider = storeDataProvider
    }
    
    /// Loads transformations for a given hero by ID.
    /// - Parameters:
    ///   - id: The ID of the hero whose transformations are being loaded.
    ///   - completion: Completion handler that returns either a list of `Transformation` objects or an error.
    func loadTransformationsForHeroWith(id: String, completion: @escaping ((Result<[Transformation], GAError>) -> Void)) {
        // Attempt to retrieve the hero from the database
        guard let hero = self.getHeroWith(id: id) else {
            completion(.failure(.heroNotFound(heroId: id)))
            return
        }
        
        // Check if the hero already has transformations stored in the database
        let bdTransformations = hero.transformations ?? []
        if bdTransformations.isEmpty {
            // If no transformations in the database, fetch them from the API
            apiProvider.loadTransformations(id: id) {[weak self] result in
                switch result {
                case .success(let transformations):
                    // Store fetched transformations in the database
                    DispatchQueue.main.async {
                        self?.storeDataProvider.add(transformations: transformations)
                        // Fetch the newly stored transformations from the database
                        let bdTransformations = hero.transformations ?? []
                        let domainTransformations = bdTransformations.map({ Transformation(moTransformation: $0) })
                        completion(.success(domainTransformations))
                    }
                case .failure(let error):
                    // Handle API load errors
                    completion(.failure(error))
                }
            }
        } else {
            // If transformations exist in the database, return them
            let domainTransformations = bdTransformations.map({ Transformation(moTransformation: $0) })
            completion(.success(domainTransformations))
        }
    }
    
    /// Private function to retrieve a hero from the database by their ID.
    /// - Parameter id: The ID of the hero to be fetched.
    /// - Returns: The `MOHero` instance if found, otherwise nil.
    private func getHeroWith(id: String) -> MOHero? {
        let predicate = NSPredicate(format: "id == %@", id)
        let heroes = storeDataProvider.fetchHeroes(filter: predicate)
        return heroes.first
    }
}
