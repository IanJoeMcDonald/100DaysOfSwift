//
//  MainCoordinator.swift
//  MilestoneProject7
//
//  Created by Masipack Eletronica on 11/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit

class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var notes = Notes()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = InitialViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
        navigationController.navigationBar.tintColor = .yellow
    }
    
    func showDetailView(index: Int) {
        let vc = DetailViewController()
        vc.coordinator = self
        vc.note = notes.list[index]
        navigationController.pushViewController(vc, animated: true)
    }
    
    func addNote(_ note: Note) {
        notes.add(note)
        showDetailView(index: 0)
    }
    
    func updateNote(_ note: Note) {
        notes.update(note)
    }
    
    func deleteNote(withId id: UUID) {
        notes.delete(id)
        navigationController.popToRootViewController(animated: true)
    }
    
    func shareNote(text: String) {
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem =
            navigationController.navigationItem.rightBarButtonItem
        navigationController.present(vc, animated: true)
    }
}
