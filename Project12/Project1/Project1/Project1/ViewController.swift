//
//  ViewController.swift
//  Project1
//
//  Created by Ian McDonald on 01/01/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var pictures = [String]()
    
    var countDictionary = [String:Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix("nssl"){
                pictures.append(item)
            }
        }
        pictures.sort()
        
        let defaults = UserDefaults.standard
        
        if let savedCounts = defaults.object(forKey: "counts") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                countDictionary = try jsonDecoder.decode([String:Int].self, from: savedCounts)
            } catch {
                print("Failed to load savedCounts")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        cell.textLabel?.text = pictures[indexPath.row]
        cell.detailTextLabel?.text = "Viewed: \(  countDictionary[pictures[indexPath.row]] ?? 0)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            vc.selectedImage = pictures[indexPath.row]
            vc.imageNumber = indexPath.row + 1
            vc.totalImages = pictures.count
            saveViewCount(index: indexPath)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func saveViewCount(index: IndexPath) {
        let image = pictures[index.row]
        let count = countDictionary[image] ?? 0
        countDictionary[image] = count + 1
        tableView.reloadRows(at: [index], with: .none)
        
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(countDictionary) {
            UserDefaults.standard.set(savedData, forKey: "counts")
        } else {
            print("Failed to save count")
        }
    }
}

