//
//  Bin+CoreDataProperties.swift
//  Summer-practice
//
//  Created by work on 15.06.2023.
//
//

import Foundation
import CoreData


extension Bin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bin> {
        return NSFetchRequest<Bin>(entityName: "Bin")
    }

    @NSManaged public var class_name: String?
    @NSManaged public var classify_prob: Double
    @NSManaged public var detect_prob: Double
    @NSManaged public var id: UUID?
    @NSManaged public var id_bin_photo: UUID?
    @NSManaged public var x1: Int16
    @NSManaged public var x2: Int16
    @NSManaged public var y1: Int16
    @NSManaged public var y2: Int16
    @NSManaged public var binPhoto: BinPhoto?

}

extension Bin : Identifiable {

}

extension Bin {
    static func decode(fromSting string: String) -> Bin? {
        let stringArray = string.components(separatedBy: ",")
        guard stringArray.count > 6 else {
            return nil
        }
        
        let bin = Bin()
        
        bin.x1 = Int16(stringArray[0].trimmingCharacters(in: .whitespaces))!
        bin.y1 = Int16(stringArray[1].trimmingCharacters(in: .whitespaces))!
        bin.x2 = Int16(stringArray[2].trimmingCharacters(in: .whitespaces))!
        bin.y2 = Int16(stringArray[3].trimmingCharacters(in: .whitespaces))!
        
        bin.class_name = stringArray[4].trimmingCharacters(in: CharacterSet(charactersIn: "' '"))
        bin.detect_prob = Double(stringArray[5].trimmingCharacters(in: .whitespaces))!
        bin.classify_prob = Double(stringArray[6].trimmingCharacters(in: .whitespaces))!
        
        return bin
    }
}
