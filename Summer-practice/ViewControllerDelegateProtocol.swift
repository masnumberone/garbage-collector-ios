//
//  ViewControllerDelegateProtocol.swift
//  Summer-practice
//
//  Created by work on 14.06.2023.
//

import Foundation

protocol ViewControllerDelegateProtocol: AnyObject {
    func getCameraBackgroundView() -> BackgroundView
    func needUpdate()
}
