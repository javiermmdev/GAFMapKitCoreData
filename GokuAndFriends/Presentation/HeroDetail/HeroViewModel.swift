// HeroViewModel.swift
import Foundation

enum StatusHeroDetail {
    case locationUpdated       // Indicates that hero location data has been updated
    case transformationsUpdated // Indicates that hero transformation data has been updated
    case error(msh: String)    // Used to handle errors, with an associated message
    case none                  // Default or uninitialized state
}

class HeroViewModel {
    
    private let hero: Hero
    private var heroLocations: [Location] = []
    private(set) var heroTransformations: [Transformation] = []
    private var useCase: HeroDetailUseCaseProtocol
    private var transformationUseCase: TransformationUseCaseProtocol
    
    var annotations: [HeroAnnotation] = []
    var status: GAObservable<StatusHeroDetail> = GAObservable(.none)
    
    init(hero: Hero, useCase: HeroDetailUseCaseProtocol = HeroDetailUseCase(), transformationUseCase: TransformationUseCaseProtocol = TransformationUseCase()) {
        self.hero = hero
        self.useCase = useCase
        self.transformationUseCase = transformationUseCase
    }
    
    func loadData() {
        loadLocations()
        loadTransformations()
    }
    
    var heroDescription: String {
        return hero.info
    }
    
    private func loadLocations() {
        useCase.loadLocationsForHeroWith(id: hero.id) { [weak self] result in
            switch result {
            case .success(let locations):
                self?.heroLocations = locations
                self?.createAnnotations()
            case .failure(let error):
                self?.status.value = .error(msh: error.description)
            }
        }
    }
    
    private func loadTransformations() {
        transformationUseCase.loadTransformationsForHeroWith(id: hero.id) { [weak self] result in
            switch result {
            case .success(let transformations):
                self?.heroTransformations = transformations
                self?.status.value = .transformationsUpdated
            case .failure(let error):
                self?.status.value = .error(msh: error.description)
            }
        }
    }
    
    var hasTransformations: Bool {
        return !heroTransformations.isEmpty
    }
    
    func transformationAt(index: Int) -> Transformation? {
        guard index < heroTransformations.count else { return nil }
        return heroTransformations[index]
    }
    
    private func createAnnotations() {
        self.annotations = []
        heroLocations.forEach { [weak self] location in
            guard let coordinate = location.coordinate else { return }
            let annotation = HeroAnnotation(title: self?.hero.name, coordinate: coordinate)
            self?.annotations.append(annotation)
        }
        self.status.value = .locationUpdated
    }
}
