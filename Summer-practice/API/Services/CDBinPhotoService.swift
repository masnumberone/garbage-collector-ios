//
//  CDBinPhotoService.swift
//  Summer-practice
//
//  Created by work on 12.09.2023.
//

import CoreData

protocol Observable {
    func subscribe(onUpdate: @escaping () -> ())
}


protocol BinPhotoServiceProtocol: Observable {
    func getPhotos() -> [BinPhoto]
    func savePhoto(_: BinPhoto)
    func processPhoto(_: BinPhoto)
    func saveAndProcessPhoto(_: BinPhoto)
    func removePhoto(_: BinPhoto)
}

class CDBinPhotoService: BinPhotoServiceProtocol {
    private let managedContext: NSManagedObjectContext
    private let networkService: NetworkServiceProtocol

    init(with managedContext: NSManagedObjectContext, _ networkService: NetworkServiceProtocol) {
        self.managedContext = managedContext
        self.networkService = networkService
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

    private func saveContext() {
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }

        valueDidUpdated()
    }

    func savePhoto(_ photo: BinPhoto) {
        managedContext.insert(photo)
        saveContext()
    }

    func processPhoto(_ photo: BinPhoto) {
        networkService.classifyBin(in: photo) { [weak self] result in
            switch result {
            case .success(let bins):
                self?.addBins(bins, to: photo)
            case .failure(_):
                break
            }
        }
    }

    private func addBins(_ bins: [Bin], to photo: BinPhoto) {
        bins.forEach {
            managedContext.insert($0)
            $0.binPhoto = photo
            $0.id_bin_photo = photo.id
        }

        photo.bins = NSSet(array: bins)
        photo.is_checked = true

        saveContext()
    }

    func saveAndProcessPhoto(_ photo: BinPhoto) {
        self.savePhoto(photo)
        self.processPhoto(photo)
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
        DispatchQueue.main.async {
            self.onUpdate.forEach { $0() }
        }
    }
}

