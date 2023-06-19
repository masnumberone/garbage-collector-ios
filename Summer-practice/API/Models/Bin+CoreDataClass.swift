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
        let entity = NSEntityDescription.entity(forEntityName: "Bin", in: BinPhotoProvider.shared.managedContext)!
        self.init(entity: entity, insertInto: BinPhotoProvider.shared.managedContext)
        id = UUID()
    }
}
