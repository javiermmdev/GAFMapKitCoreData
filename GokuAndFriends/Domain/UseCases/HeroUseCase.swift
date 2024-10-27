import Foundation

/// Use case for managing Hero-related information.
protocol HeroUseCaseProtocol {
    
    /// Loads heroes based on a specified filter.
    /// - Parameters:
    ///   - filter: Optional predicate to filter heroes.
    ///   - completion: Completion handler returning either an array of heroes or an error.
    func loadHeros(filter: NSPredicate?, completion: @escaping ((Result<[Hero], GAError>) -> Void))
}

class HeroUseCase: HeroUseCaseProtocol {
    
    private var apiProvider: ApiProviderProtocol
    private var storeDataPRovider: StoreDataProvider
    
    /// Initializer with dependency injection for testing and flexibility.
    /// - Parameters:
    ///   - apiProvider: Injected API provider, default is `ApiProvider`.
    ///   - storeDataPRovider: Core Data provider, default is shared instance.
    init(apiProvider: ApiProviderProtocol = ApiProvider(), storeDataPRovider: StoreDataProvider = .shared) {
        self.apiProvider = apiProvider
        self.storeDataPRovider = storeDataPRovider
    }
    
    /// If data exists in the database, returns it.
    /// If no data is found:
    /// - Fetches heroes from the API.
    /// - Inserts heroes into the database.
    /// - Returns the fetched data.
    /// - Parameters:
    ///   - filter: Optional predicate to filter heroes.
    ///   - completion: Completion handler returning either an array of heroes or an error.
    func loadHeros(filter: NSPredicate? = nil, completion: @escaping ((Result<[Hero], GAError>) -> Void)) {
        let localHeroes = storeDataPRovider.fetchHeroes(filter: filter)
        
        if localHeroes.isEmpty {
            apiProvider.loadHeros(name: "") { [weak self] result in
                switch result {
                case .success(let apiHeros):
                    // Core Data is not thread-safe, so ensure that operations on the context are executed
                    // within the same thread where the context was created (main thread here).
                    // Hence, we call `storeDataProvider` within DispatchQueue.main.
                    // Alternatively, use `context.perform { ... }` or `context.performAndWait { ... }`:
                    // The former is asynchronous (does not block), while the latter waits to finish (blocks).
                    DispatchQueue.main.async {
                        self?.storeDataPRovider.add(heroes: apiHeros)
                        let bdHeroes = self?.storeDataPRovider.fetchHeroes(filter: filter) ?? []
                        let heroes = bdHeroes.map({ Hero(moHero: $0) })
                        completion(.success(heroes))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            let heroes = localHeroes.map({ Hero(moHero: $0) })
            // Equivalent to the line above:
            // let heroes = localHeroes.map { moHero in
            //     Hero(moHero: moHero)
            // }
            completion(.success(heroes))
        }
    }
}
