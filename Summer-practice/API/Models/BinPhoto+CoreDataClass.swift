//
//  BinPhoto+CoreDataClass.swift
//  Summer-practice
//
//  Created by work on 14.06.2023.
//
//

import Foundation
import CoreData


//@objc(BinPhoto)
public class BinPhoto: NSManagedObject {
    convenience init() {
        let entity = NSEntityDescription.entity(forEntityName: "BinPhoto", in: BinPhotoProvider.shared.managedContext)!
        self.init(entity: entity, insertInto: BinPhotoProvider.shared.managedContext)
        id = UUID()
    }

}
