//
//  DataManager.swift
//  Summer-practice
//
//  Created by work on 12.09.2023.
//

import CoreData

protocol Observable {
    func subscribe(onUpdate: @escaping () -> ())
}


protocol BinPhotoManager: Observable {
    func getPhotos() -> [BinPhoto]
    func savePhoto(_: BinPhoto)
    func processPhoto(_: BinPhoto)
    func saveAndProcessPhoto(_: BinPhoto)
    func removePhoto(_: BinPhoto)
}

class DataManager: BinPhotoManager {
    private let managedContext: NSManagedObjectContext

    init(with managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
    }

    func getPhotos() -> [BinPhoto] {
        let fetchRequest = BinPhoto.fetchRequest()
        var photos = [BinPhoto]()
        do {
            photos = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        return photos
    }

    func savePhoto(_ photo: BinPhoto) {
        managedContext.insert(photo)
        saveContext()
    }

    private func saveContext() {
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }

        valueDidUpdated()
    }

    func processPhoto(_ photo: BinPhoto) {
        QueryManager.shared.classifyBin(in: photo) { [weak self] result in
            switch result {
            case .success(let bins):
                self?.addBins(bins, to: photo)
            case .failure(_):
                break
            }
        }
    }

    private func addBins(_ bins: [Bin], to photo: BinPhoto) {
        photo.bins = NSSet(array: bins)
        photo.is_checked = true

        bins.forEach {
            managedContext.insert($0)
            $0.binPhoto = photo
            $0.id_bin_photo = photo.id
        }
        saveContext()
    }

    func saveAndProcessPhoto(_ photo: BinPhoto) {
        savePhoto(photo)
        processPhoto(photo)
    }

    func removePhoto(_ photo: BinPhoto) {
        removePhotoFromContext(photo)
        saveContext()
    }

    private func removePhotoFromContext(_ photo: BinPhoto) {
        managedContext.delete(photo)
    }



    private var onUpdate: [() -> ()] = []

    func subscribe(onUpdate: @escaping () -> ()) {
        self.onUpdate.append(onUpdate)
    }

    private func valueDidUpdated() {
        onUpdate.forEach { $0() }
    }
}

