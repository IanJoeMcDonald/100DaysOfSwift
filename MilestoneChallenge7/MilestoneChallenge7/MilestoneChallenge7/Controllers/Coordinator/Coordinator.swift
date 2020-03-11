//
//  Coordinator.swift
//  MilestoneProject7
//
//  Created by Masipack Eletronica on 11/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}
