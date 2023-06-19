//
//  ViewModel.swift
//  Summer-practice
//
//  Created by work on 03.06.2023.
//

import Foundation
import UIKit
import CoreData

enum Section: Int, CaseIterable {
    case camera
    case photo
}

struct ViewModel: Hashable {
    let id = UUID()
    let color: UIColor
    let date: Date
    
}





