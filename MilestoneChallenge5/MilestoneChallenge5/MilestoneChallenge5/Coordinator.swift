//
//  Coordinator.swift
//  MilestoneChallenge5
//
//  Created by Ian McDonald on 08/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start()
}
