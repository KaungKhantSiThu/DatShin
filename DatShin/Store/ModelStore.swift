//
//  ModelStore.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 16/05/2024.
//


import Foundation

protocol ModelStore {
    associatedtype Model: Identifiable
    
    func fetchByID(_ id: Model.ID) -> Model
}

class AnyModelStore<Model: Identifiable>: ModelStore {
    
    private var models = [Model.ID: Model]()
    private var modelIDs = [Model.ID]()
    
    init(_ models: [Model]) {
        self.models = models.groupingByUniqueID()
        self.modelIDs = models.map { $0.id }
    }
    
    init(duplicatedIDs modelArrays: [[Model]]) {
        self.models = groupingByDuplicatID(modelArrays)
        self.modelIDs = models.map { $0.key }
    }
    
    func fetchByID(_ id: Model.ID) -> Model {
        return self.models[id]!
    }
    
    func fetchByIndexPath(_ indexPath: IndexPath) -> Model? {
        guard indexPath.row < modelIDs.count else { return nil }
        let id = modelIDs[indexPath.row]
        return fetchByID(id)
    }
    
    private func groupingByDuplicatID(_ arrays: [[Model]]) -> [Model.ID: Model] {
        var dictionary = [Model.ID: Model]()
        
        for array in arrays {
            for element in array {
                dictionary[element.id] = element
            }
        }
        
        return dictionary
    }
}

extension AnyModelStore where Model == Section {
    func fetchMovieIDs(by id: Model.ID) -> [Movie.ID] {
        return self.models[id]!.movies
    }
    
    func fetchByIndex(_ index: Int) -> Model? {
        guard index < modelIDs.count else { return nil }
        let id = modelIDs[index]
        return fetchByID(id)
    }
}

extension Sequence where Element: Identifiable {
    func groupingByID() -> [Element.ID: [Element]] {
        return Dictionary(grouping: self, by: { $0.id })
    }
    
    func groupingByUniqueID() -> [Element.ID: Element] {
        return Dictionary(uniqueKeysWithValues: self.map { ($0.id, $0) })
    }
}

