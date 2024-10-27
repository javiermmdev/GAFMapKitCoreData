import Foundation

/// Enum representing the status of hero data updates.
enum StatusHeroes {
    case dataUpdated  // Data has been successfully updated.
    case error(msg: String)  // An error occurred, with a message.
    case none  // Initial state with no updates.
}

/// ViewModel for managing hero data in the view.
class HeroesViewModel {
    
    // Use case for loading hero data.
    let useCase: HeroUseCaseProtocol
    
    // Observable variable for view binding; updates based on status changes.
    var statusHeroes: GAObservable<StatusHeroes> = GAObservable(.none)
    var heroes: [Hero] = []  // Array storing hero data.
    
    // Initializes with a default or injected HeroUseCase for testability.
    init(useCase: HeroUseCaseProtocol = HeroUseCase()) {
        self.useCase = useCase
    }
    
    // Loads hero data, applying a name filter if provided.
    // - Parameter filter: Optional name filter for heroes.
    func loadData(filter: String?) {
        
        var predicate: NSPredicate?
        if let filter {
            // [cd] modifier: c -> case insensitive, d -> ignores diacritical marks like accents.
            predicate = NSPredicate(format: "name CONTAINS[cd] %@", filter)
        }
        useCase.loadHeros(filter: predicate) { [weak self] result in
            switch result {
            case .success(let heroes):
                self?.heroes = heroes
                self?.statusHeroes.value = .dataUpdated  // Notify observers of data update.
            case .failure(let error):
                self?.statusHeroes.value = .error(msg: error.description)  // Notify observers of an error.
            }
        }
    }
    
    // Returns the hero at the specified index, if valid.
    // - Parameter index: The index of the hero in the array.
    func heroAt(index: Int) -> Hero? {
        guard index < heroes.count else {
            return nil
        }
        return heroes[index]
    }
}
