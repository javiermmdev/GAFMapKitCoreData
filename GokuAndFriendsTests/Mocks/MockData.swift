
import Foundation
@testable import GokuAndFriends

/// Helper class to provide mock data for testing
class MockData {
    
    /// Returns the mock data for heroes from a JSON file in the test bundle
    static func loadHeroesData() throws -> Data {
        let bundle = Bundle(for: MockData.self)
        guard let url = bundle.url(forResource: "Heroes", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            throw NSError(domain: "io.keepcoding.GokuandrRiends", code: -1)
        }
        return data
    }
    
    /// Returns the mock data for transformations from a JSON file in the test bundle
    static func loadTransformationData() throws -> Data {
        let bundle = Bundle(for: MockData.self)
        guard let url = bundle.url(forResource: "Transformations", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            throw NSError(domain: "io.keepcoding.GokuandrRiends", code: -1)
        }
        return data
    }
    
    /// Returns the mock data for locations from a JSON file in the test bundle
    static func loadLocationData() throws -> Data {
        let bundle = Bundle(for: MockData.self)
        guard let url = bundle.url(forResource: "Locations", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            throw NSError(domain: "io.keepcoding.GokuandrRiends", code: -1)
        }
        return data
    }
    
    /// Decodes and returns an array of `ApiHero` from the mock heroes data
    static func mockHeroes() throws -> [ApiHero] {
        do {
            let data = try self.loadHeroesData()
            let heroes = try JSONDecoder().decode([ApiHero].self, from: data)
            return heroes
        } catch {
            throw error
        }
    }
    
    /// Decodes and returns an array of `ApiTransformation` from the mock transformations data
    static func mockTransformations() throws -> [ApiTransformation] {
        do {
            let data = try self.loadTransformationData()
            let transformations = try JSONDecoder().decode([ApiTransformation].self, from: data)
            return transformations
        } catch {
            throw error
        }
    }

    /// Decodes and returns an array of `ApiLocation` from the mock locations data
    static func mockLocations() throws -> [ApiLocation] {
        do {
            let data = try self.loadLocationData()
            let locations = try JSONDecoder().decode([ApiLocation].self, from: data)
            return locations
        } catch {
            throw error
        }
    }
}
