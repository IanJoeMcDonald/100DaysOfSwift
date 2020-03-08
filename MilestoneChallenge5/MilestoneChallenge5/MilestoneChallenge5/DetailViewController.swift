//
//  DetailViewController.swift
//  MilestoneChallenge5
//
//  Created by Ian McDonald on 07/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, Storyboarded {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var capitalLabel: UILabel!
    @IBOutlet weak var continentLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    
    @IBOutlet weak var languagesLabel: UILabel!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var populationLabel: UILabel!
    
    var country: Country!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = country.displayName

        imageView.image = UIImage(named: country.flag)
        nameLabel.text = country.name
        descriptionLabel.text = country.description
        
        capitalLabel.text = country.capital
        continentLabel.text = country.continentName
        currencyLabel.text = country.currency
        
        languagesLabel.text = country.languagesNames
        areaLabel.text = "\(country.size)km2"
        populationLabel.text = String(country.population)
    }

}
