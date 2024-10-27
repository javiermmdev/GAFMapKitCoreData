
import XCTest
import CoreData

@testable import GokuAndFriends

/// Subclass of StoreDataProvider to simulate error scenarios for fetch requests in testing
class StoreDataProviderErrorMock: StoreDataProvider {
    override func perform<T>(request: NSFetchRequest<T>) throws -> [T] {
        throw GAError.noDataReceived
    }
}

/// Tests for Core Data Stack and its extension methods
final class StoreProviderTests: XCTestCase {
    
    var sut: StoreDataProvider!

    /// Initializes the `sut` (System Under Test) for each test
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = StoreDataProvider(persistency: .inMemory)
    }

    /// Cleans up `sut` after each test
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Tests for Adding Heroes

    /// Test to add heroes and verify the number of items inserted
    func test_addHeroes_shouldReturnTheItemsInserted() throws {
        // Given
        let initialCount = sut.fetchHeroes(filter: nil).count
        let apiHero = ApiHero(id: "123", name: "name", description: "description", photo: "photo", favorite: false)
        
        // When
        sut.add(heroes: [apiHero])
        let heroes = sut.fetchHeroes(filter: nil)
        let finalCount = heroes.count
        
        // Then
        XCTAssertEqual(finalCount, initialCount + 1)
        let hero = try XCTUnwrap(heroes.first)
        XCTAssertEqual(hero.id, apiHero.id)
        XCTAssertEqual(hero.name, apiHero.name)
        XCTAssertEqual(hero.info, apiHero.description)
        XCTAssertEqual(hero.photo, apiHero.photo)
        XCTAssertEqual(hero.favorite, apiHero.favorite)
    }
    
    /// Test to verify that heroes are sorted in ascending order
    func test_fetchHeroes_ShoulBeSortedAsc() throws {
        // Given
        let initialCount = sut.fetchHeroes(filter: nil).count
        let apiHero = ApiHero(id: "123", name: "Luis", description: "description", photo: "photo", favorite: true)
        let apiHero2 = ApiHero(id: "1234", name: "Alberto", description: "description", photo: "photo", favorite: false)
        
        // When
        sut.add(heroes: [apiHero, apiHero2])
        let heroes = sut.fetchHeroes(filter: nil)
        
        // Then
        XCTAssertEqual(initialCount, 0)
        let hero = try XCTUnwrap(heroes.first)
        XCTAssertEqual(hero.id, apiHero2.id)
        XCTAssertEqual(hero.name, apiHero2.name)
        XCTAssertEqual(hero.info, apiHero2.description)
        XCTAssertEqual(hero.photo, apiHero2.photo)
        XCTAssertEqual(hero.favorite, apiHero2.favorite)
    }
    
    // MARK: - Tests for Adding Locations

    /// Test to add locations and validate the association with a hero
    func test_addLocations_ShouldInsertLocationAndAssociateHero() throws {
        // Given
        let apiHero = ApiHero(id: "123", name: "Luis", description: "description", photo: "photo", favorite: true)
        let apiLocation = ApiLocation(id: "id", date: "date", latitude: "0000", longitude: "11111", hero: apiHero)
        
        // When
        sut.add(heroes: [apiHero])
        sut.add(locations: [apiLocation])
        let heroes = sut.fetchHeroes(filter: nil)
        let hero = try XCTUnwrap(heroes.first)
        
        // Then
        XCTAssertEqual(hero.locations?.count, 1)
        let location = try XCTUnwrap(hero.locations?.first)
        
        XCTAssertEqual(location.id, apiLocation.id)
        XCTAssertEqual(location.date, apiLocation.date)
        XCTAssertEqual(location.latitude, apiLocation.latitude)
        XCTAssertEqual(location.longitude, apiLocation.longitude)
        XCTAssertEqual(location.hero?.id, hero.id)
    }

    /// Test to check that fetch locations returns an empty array when there’s an error
    func test_fetchLocations_Error_ShouldReturnEmptyArray() throws {
        // Given
        let apiHero = ApiHero(id: "123", name: "Luis", description: "description", photo: "photo", favorite: true)
        let apiLocation = ApiLocation(id: "id", date: "date", latitude: "0000", longitude: "11111", hero: apiHero)
        
        // Replace `sut` with error mock
        sut = StoreDataProviderErrorMock(persistency: .inMemory)
        
        // When
        sut.add(heroes: [apiHero])
        sut.add(locations: [apiLocation])
        let heroes = sut.fetchHeroes(filter: nil)
        
        // Then
        XCTAssertEqual(heroes.count, 0, "Although a hero and location were inserted, an error should result in an empty array")
    }

    // MARK: - Tests for Adding Transformations

    /// Test to add transformations and validate the association with a hero
    func test_addTransformations_ShouldInsertTransformationAndAssociateHero() throws {
        // Given
        let apiHero = ApiHero(id: "123", name: "Goku", description: "Saiyan Warrior", photo: "photo", favorite: true)
        let apiTransformation = ApiTransformation(id: "transformationID", name: "Super Saiyan", photo: "transformationPhoto", description: "Transformation to Super Saiyan", hero: apiHero)
        
        // When
        sut.add(heroes: [apiHero])
        sut.add(transformations: [apiTransformation])
        let heroes = sut.fetchHeroes(filter: nil)
        let hero = try XCTUnwrap(heroes.first)
        
        // Then
        XCTAssertEqual(hero.transformations?.count, 1)
        let transformation = try XCTUnwrap(hero.transformations?.first)
        
        XCTAssertEqual(transformation.id, apiTransformation.id)
        XCTAssertEqual(transformation.name, apiTransformation.name)
        XCTAssertEqual(transformation.photo, apiTransformation.photo)
        XCTAssertEqual(transformation.info, apiTransformation.description)
        XCTAssertEqual(transformation.hero?.id, hero.id)
    }

    /// Test to ensure fetch transformations returns an empty array when there’s an error
    func test_fetchTransformations_Error_ShouldReturnEmptyArray() throws {
        // Given
        let apiHero = ApiHero(id: "123", name: "Goku", description: "Saiyan Warrior", photo: "photo", favorite: true)
        let apiTransformation = ApiTransformation(id: "transformationID", name: "Super Saiyan", photo: "transformationPhoto", description: "Transformation to Super Saiyan", hero: apiHero)
        
        // Replace `sut` with error mock
        sut = StoreDataProviderErrorMock(persistency: .inMemory)
        
        // When
        sut.add(heroes: [apiHero])
        sut.add(transformations: [apiTransformation])
        let heroes = sut.fetchHeroes(filter: nil)
        
        // Then
        XCTAssertEqual(heroes.count, 0, "Although a hero and transformation were inserted, an error should result in an empty array")
    }
    
    // MARK: - Tests for Fetch Heroes Error

    /// Test to verify fetch heroes returns an empty array when there’s an error
    func test_fetchHeroes_Error_ShouldReturnEmptyArray() throws {
        // Given
        let apiHero = ApiHero(id: "123", name: "Luis", description: "description", photo: "photo", favorite: true)
        let apiLocation = ApiLocation(id: "id", date: "date", latitude: "0000", longitude: "11111", hero: apiHero)
        
        // Replace `sut` with error mock
        sut = StoreDataProviderErrorMock(persistency: .inMemory)
        
        // When
        sut.add(heroes: [apiHero])
        sut.add(locations: [apiLocation])
        let heroes = sut.fetchHeroes(filter: nil)
        
        // Then
        XCTAssertEqual(heroes.count, 0, "Although two heroes were inserted, an error should result in an empty array")
    }
}
