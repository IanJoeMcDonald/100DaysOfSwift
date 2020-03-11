//
//  InitialViewController.swift
//  MilestoneProject7
//
//  Created by Masipack Eletronica on 11/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    var coordinator: MainCoordinator!
    private var initialView: InitialView!
    private var tableViewController: TableViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        instantiateNavigationItems()
        instantiateTableViewController()
        instantiateView()
        
        view = initialView
        title = "Notes"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initialView.tableView.reloadData()
    }
    
    private func instantiateTableViewController() {
        tableViewController = TableViewController()
        tableViewController.coordinator = coordinator
    }
    
    private func instantiateView() {
        initialView = InitialView()
        initialView.tableView.delegate = tableViewController
        initialView.tableView.dataSource = tableViewController
    }
    
    private func instantiateNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self,
                                                           action: #selector(addNote))
    }
    
    @objc private func addNote() {
        let note = Note()
        coordinator.addNote(note)
    }
}

