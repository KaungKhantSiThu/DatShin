//
//  WLGenre+CoreDataProperties.swift
//  DatShin
//
//  Created by Kaung Khant Si Thu on 22/05/2024.
//
//

import Foundation
import CoreData


extension WLGenre {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WLGenre> {
        return NSFetchRequest<WLGenre>(entityName: "WLGenre")
    }

    @NSManaged public var id: Int16
    @NSManaged public var name: String
    @NSManaged public var movies: NSSet

}

// MARK: Generated accessors for movies
extension WLGenre {

    @objc(addMoviesObject:)
    @NSManaged public func addToMovies(_ value: WLMovie)

    @objc(removeMoviesObject:)
    @NSManaged public func removeFromMovies(_ value: WLMovie)

    @objc(addMovies:)
    @NSManaged public func addToMovies(_ values: NSSet)

    @objc(removeMovies:)
    @NSManaged public func removeFromMovies(_ values: NSSet)

}

extension WLGenre : Identifiable {

}
