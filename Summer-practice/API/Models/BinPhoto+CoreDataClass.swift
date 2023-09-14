//
//  BinPhoto+CoreDataClass.swift
//  Summer-practice
//
//  Created by work on 14.06.2023.
//
//

import Foundation
import CoreData


@objc(BinPhoto)
public class BinPhoto: NSManagedObject {
    convenience init() {
        self.init(entity: BinPhoto.entity(), insertInto: nil)
        id = UUID()
    }

}
