//
//  MainCoordinator.swift
//  MilestoneChallenge5
//
//  Created by Ian McDonald on 08/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit

class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = ViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func showDetailView(for country: Country) {
        let vc = DetailViewController.instantiate()
        vc.country = country
        navigationController.pushViewController(vc, animated: true)
    }
}
