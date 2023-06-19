//
//  BinPhoto+CoreDataProperties.swift
//  Summer-practice
//
//  Created by work on 14.06.2023.
//
//

import Foundation
import CoreData


extension BinPhoto {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BinPhoto> {
        return NSFetchRequest<BinPhoto>(entityName: "BinPhoto")
    }

    @NSManaged public var data: Data?
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var is_checked: Bool
    @NSManaged public var bins: NSSet?

}

// MARK: Generated accessors for bins
extension BinPhoto {

    @objc(addBinsObject:)
    @NSManaged public func addToBins(_ value: Bin)

    @objc(removeBinsObject:)
    @NSManaged public func removeFromBins(_ value: Bin)

    @objc(addBins:)
    @NSManaged public func addToBins(_ values: NSSet)

    @objc(removeBins:)
    @NSManaged public func removeFromBins(_ values: NSSet)

}

extension BinPhoto : Identifiable {

}
