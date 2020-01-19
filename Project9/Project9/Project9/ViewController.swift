//
//  ViewController.swift
//  Project7
//
//  Created by Masipack Eletronica on 17/01/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var petitions = [Petition]()
    var basePetitions = [Petition]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain,
                                                            target: self,
                                                            action: #selector(creditsTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain,
                                                           target: self,
                                                           action: #selector(filterTapped))
        
        let urlString: String
        if navigationController?.tabBarItem.tag == 0 {
            //urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
            urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
            
        } else {
            //urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
            urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    self.parse(json: data)
                    return
                }
            }
            
            self.showError()
        }
        
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = petitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            basePetitions = jsonPetitions.results
            petitions = basePetitions
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func showError() {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Loading error",
                                       message: "There was a problem loading the feed; please check your connection and try again",
                                       preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }
    
    @objc func creditsTapped() {
        let ac = UIAlertController(title: "Credits",
                                   message: "This data comes from the We The People API of the whitehouse",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Close", style: .default))
        present(ac, animated: true)
    }
    
    @objc func filterTapped() {
        let ac = UIAlertController(title: "Search", message: "Enter the term to search for",
                                   preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Search", style: .default, handler: { (_) in
            guard let term = ac.textFields?[0].text else { return }
            DispatchQueue.global(qos: .userInitiated).async {
                let filteredPetitions = self.basePetitions.filter { (petition) -> Bool in
                    return petition.title.contains(term)
                }
                self.petitions = filteredPetitions
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
            self.petitions = self.basePetitions
            self.tableView.reloadData()
        }))
        present(ac, animated: true)
        
    }
}

