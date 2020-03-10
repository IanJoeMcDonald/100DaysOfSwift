//
//  TableViewController.swift
//  Extension
//
//  Created by Masipack Eletronica on 10/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var actionFiles = [ActionFile]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadActions()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                           target: self,
                                                           action: #selector(addItem))
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return actionFiles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            cell.textLabel?.text = actionFiles[indexPath.row].title
            
            return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showDetailView(with: actionFiles[indexPath.row])
    }
    
    @objc func addItem() {
        let ac = UIAlertController(title: "Add Script", message: "Enter the name for your script", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Enter", style: .default, handler: { [weak self] _ in
            if let title = ac.textFields?[0].text {
                let action = ActionFile(title: title, text: "")
                self?.actionFiles.append(action)
                self?.tableView.reloadData()
                self?.showDetailView(with: action)
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    func showDetailView(with action: ActionFile) {
        let vc = storyboard?.instantiateViewController(identifier: "DetailView") as! ActionViewController
        vc.actionFile = action
        vc.delegate = self
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func loadActions() {
        let decoder = JSONDecoder()
        
        if let data = UserDefaults.standard.value(forKey: "actionFiles") as? Data {
            if let decoded = try? decoder.decode([ActionFile].self, from: data) {
                actionFiles = decoded
            }
        }
    }
    
    func saveActions() {
        let encoder = JSONEncoder()
        
        if let data = try? encoder.encode(actionFiles) {
            UserDefaults.standard.set(data, forKey: "actionFiles")
        }
    }
}

extension TableViewController: ActionViewDelegate {
    func updateAction(_ action: ActionFile) {
        if let index = actionFiles.firstIndex(where: { $0.uuid == action.uuid }) {
            actionFiles.remove(at: index)
            actionFiles.append(action)
        }
        saveActions()
    }
}
