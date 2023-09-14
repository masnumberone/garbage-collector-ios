//
//  Bin+CoreDataClass.swift
//  Summer-practice
//
//  Created by work on 15.06.2023.
//
//

import Foundation
import CoreData


public class Bin: NSManagedObject {
    convenience init() {
        self.init(entity: Bin.entity(), insertInto: nil)
        id = UUID()
    }
}
