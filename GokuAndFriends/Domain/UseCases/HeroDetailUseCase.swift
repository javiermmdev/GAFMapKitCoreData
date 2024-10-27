import Foundation

/// Use case for handling hero details, responsible for retrieving hero locations
/// and managing the retrieval of transformations.
protocol HeroDetailUseCaseProtocol {
    /// Loads locations for a specific hero by ID.
    /// - Parameters:
    ///   - id: The ID of the hero.
    ///   - completion: Completion handler that returns either a list of locations or an error.
    func loadLocationsForHeroWith(id: String, completrion: @escaping ((Result<[Location], GAError>) -> Void))
}

class HeroDetailUseCase: HeroDetailUseCaseProtocol {
    private var apiProvider: ApiProviderProtocol
    private var storeDataProvider: StoreDataProvider
    
    /// Initializer with dependency injection for flexible testing and use.
    /// - Parameters:
    ///   - apiProvider: Injected API provider, default is `ApiProvider`.
    ///   - storeDataProvider: Core Data provider, default is shared instance.
    init(apiProvider: ApiProviderProtocol = ApiProvider(), storeDataProvider: StoreDataProvider = .shared) {
        self.apiProvider = apiProvider
        self.storeDataProvider = storeDataProvider
    }
    
    /// Retrieves a hero's locations, either from the database or API if not already stored.
    /// - Parameters:
    ///   - id: The ID of the hero.
    ///   - completion: Completion handler returning either a list of locations or an error.
    /// - Logic:
    ///   - If the hero has locations stored in the database, they are returned.
    ///   - If not, locations are fetched from the API, stored in the database, and then returned.
    func loadLocationsForHeroWith(id: String, completrion: @escaping ((Result<[Location], GAError>) -> Void)) {
        guard let hero = self.getHeroWith(id: id) else {
            completrion(.failure(.heroNotFound(heroId: id)))
            return
        }
        let bdLocations = hero.locations ?? []
        if bdLocations.isEmpty {
            apiProvider.loadLocations(id: id) { [weak self] result in
                switch result {
                case .success(let locations):
                    // Ensure main thread execution for Core Data operations.
                    DispatchQueue.main.async {
                        self?.storeDataProvider.add(locations: locations)
                        let bdLocations = hero.locations ?? []
                        let domainLocations = bdLocations.map({ Location(moLocation: $0) })
                        completrion(.success(domainLocations))
                    }
                case .failure(let error):
                    completrion(.failure(error))
                }
            }
        } else {
            let domainLocations = bdLocations.map({ Location(moLocation: $0) })
            completrion(.success(domainLocations))
        }
    }
    
    /// Retrieves a hero from the database by ID.
    /// - Parameter id: The ID of the hero.
    /// - Returns: The `MOHero` instance if found, otherwise nil.
    private func getHeroWith(id: String) -> MOHero? {
        let predicate = NSPredicate(format: "id == %@", id)
        let heroes = storeDataProvider.fetchHeroes(filter: predicate)
        return heroes.first
    }
}
