//
//  ServiceFactory.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 3/6/25.
//

import Foundation
import CoreData

protocol ServiceFactoryProtocol {
    func makeMoviesFetcherService() -> MoviesFetcher
    func makeSearchService() -> SearchFetcher
    func makeCoreDataService() -> CoreDataServiceProtocol
}

protocol CoreDataServiceProtocol {
    var managedContext: NSManagedObjectContext { get }
    func saveContext()
}

class ServiceFactory: ServiceFactoryProtocol {
    private let container: DependencyContainerProtocol
    
    init(container: DependencyContainerProtocol) {
        self.container = container
    }
    
    func makeMoviesFetcherService() -> MoviesFetcher {
        return container.resolve() as MoviesFetcher
    }
    
    func makeSearchService() -> SearchFetcher {
        return container.resolve() as SearchFetcher
    }
    
    func makeCoreDataService() -> CoreDataServiceProtocol {
        return container.resolve() as CoreDataServiceProtocol
    }
}
