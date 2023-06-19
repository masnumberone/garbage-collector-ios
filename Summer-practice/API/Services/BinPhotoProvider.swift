//
//  BinPhotoProvider.swift
//  Summer-practice
//
//  Created by work on 06.06.2023.
//


// StorageManager 

import Foundation
import CoreData
import UIKit

class BinPhotoProvider {
    let managedContext: NSManagedObjectContext
    static let shared = BinPhotoProvider()

    private init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext
    }

//    // вроде бы не нужно
//    func saveObject(_ object: BinPhoto) {
//        
//        let entity = NSEntityDescription.entity(forEntityName: "BinPhoto", in: managedContext)!
//        let photo = BinPhoto(entity: entity, insertInto: managedContext)
//        
//        photo.id = object.id
//        photo.date = object.date
//        photo.data = object.data
//        
//        do {
//            try managedContext.save()
//        } catch let error as NSError {
//            print("Could not save. \(error), \(error.userInfo)")
//        }
//    }

    
    
    
    func deleteObject(_ object: BinPhoto) {
        managedContext.delete(object)
        saveContext()
    }
    
    func saveContext() {
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    func fetchObjects() -> [BinPhoto]? {
        let fetchRequest = BinPhoto.fetchRequest()
        var photos = [BinPhoto]()
        do {
            photos = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        return photos
    }


}
