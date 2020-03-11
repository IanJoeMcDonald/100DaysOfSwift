//
//  TableViewController.swift
//  MilestoneProject7
//
//  Created by Masipack Eletronica on 11/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit

class TableViewController: NSObject, UITableViewDelegate, UITableViewDataSource {

    var coordinator: MainCoordinator!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coordinator.notes.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = coordinator.notes.list[indexPath.row]
        let displayText = String(note.text.prefix(20))
        
        let dateText: String
        if Calendar.current.isDateInToday(note.date) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            dateText = dateFormatter.string(from: note.date)
        } else if Calendar.current.isDateInYesterday(note.date) {
            dateText = "Yesterday"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            dateText = dateFormatter.string(from: note.date)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = displayText
        cell.detailTextLabel?.text = dateText
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coordinator.showDetailView(index: indexPath.row)
    }
}
