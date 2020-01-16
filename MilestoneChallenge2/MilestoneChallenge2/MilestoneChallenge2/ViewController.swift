//
//  ViewController.swift
//  MilestoneChallenge2
//
//  Created by Masipack Eletronica on 16/01/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var shoppingList = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addItem))
        let clear = UIBarButtonItem(barButtonSystemItem: .refresh, target: self,
                                                           action: #selector(clearList))
        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self,
                                    action: #selector(shareList))
        navigationItem.leftBarButtonItems = [clear, share]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath)
        cell.textLabel?.text = shoppingList[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            shoppingList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    @objc func addItem() {
        let ac = UIAlertController(title: "New Item", message: "Enter the item to add to the list",
                                   preferredStyle: .alert)
        ac.addTextField(configurationHandler: nil)
        ac.addAction(UIAlertAction(title: "Add", style: .default, handler: { (_) in
            if let text = ac.textFields?[0].text {
                self.shoppingList.insert(text, at: 0)
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
    
    @objc func clearList() {
        let ac = UIAlertController(title: "Clear List",
                                   message: "Are you sure you want to clear the list?",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Clear", style: .default, handler: { (_) in
            self.shoppingList.removeAll(keepingCapacity: true)
            self.tableView.reloadData()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
    
    @objc func shareList() {
        let joinedList = shoppingList.joined(separator: "\n")
        let ac = UIActivityViewController(activityItems: [joinedList], applicationActivities: [])
        ac.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
        present(ac, animated: true)
    }

}

