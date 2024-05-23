//
//  WLMovie+CoreDataProperties.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 22/05/2024.
//
//

import Foundation
import CoreData


extension WLMovie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WLMovie> {
        return NSFetchRequest<WLMovie>(entityName: "WLMovie")
    }

    @NSManaged public var id: Int32
    @NSManaged public var title: String
    @NSManaged public var posterPath: URL
    @NSManaged public var savedAt: Date
    @NSManaged public var hasWatched: Bool
    @NSManaged public var genres: NSSet

}

// MARK: Generated accessors for genres
extension WLMovie {

    @objc(addGenresObject:)
    @NSManaged public func addToGenres(_ value: WLGenre)

    @objc(removeGenresObject:)
    @NSManaged public func removeFromGenres(_ value: WLGenre)

    @objc(addGenres:)
    @NSManaged public func addToGenres(_ values: NSSet)

    @objc(removeGenres:)
    @NSManaged public func removeFromGenres(_ values: NSSet)

}

extension WLMovie : Identifiable {

}
