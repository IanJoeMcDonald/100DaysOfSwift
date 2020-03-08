//
//  ViewController.swift
//  MilestoneChallenge5
//
//  Created by Ian McDonald on 07/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, Storyboarded {
    
    weak var coordinator: MainCoordinator?
    
    private let countries: [Country] = Bundle.main.decode("Countries.json")
    
    var sortedCountries: [Country]!
    
    var sortOrder: Int! {
        didSet {
            switch sortOrder {
            case 1:
                sortedCountries = countries.sorted(by: { $0.continent < $1.continent })
            case 2:
                sortedCountries = countries.sorted(by: { $0.size > $1.size })
            case 3:
                sortedCountries = countries.sorted(by: { $0.population > $1.population })
            default:
                sortedCountries = countries.sorted(by: { $0.name < $1.name })
            }
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sortOrder = 0
        title = "World Reader"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort", style: .plain,
                                                            target: self,
                                                            action: #selector(showSortOrder))
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortedCountries.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CountryCell", for: indexPath) as! CountryCell
        
        cell.imageView.image = UIImage(named: sortedCountries[indexPath.item].flag)
        cell.label.text = sortedCountries[indexPath.item].displayName
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        vc.country = sortedCountries[indexPath.item]
        
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func showSortOrder() {
        
        let ac = UIAlertController(title: "Sort by...", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Alphabetical", style: .default,
                                   handler: { _ in self.sortOrder = 0 }))
        ac.addAction(UIAlertAction(title: "Continents", style: .default,
                                   handler: { _ in self.sortOrder = 1 }))
        ac.addAction(UIAlertAction(title: "Size", style: .default,
                                   handler: { _ in self.sortOrder = 2 }))
        ac.addAction(UIAlertAction(title: "Population", style: .default,
                                   handler: { _ in self.sortOrder = 3 }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
}
