//
//  Country.swift
//  MilestoneChallenge5
//
//  Created by Ian McDonald on 07/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import Foundation

class Country: Codable {
    
    var name: String
    var displayName: String
    var continent: Int
    var capital: String
    var size: Int
    var population: Int
    var currency: String
    var flag: String
    var languages: [Int]
    var description: String
    
    static var Continents: [String:String] = Bundle.main.decode("Continents.json")
    static var Languages: [String:String] = Bundle.main.decode("Languages.json")
    
    var continentName: String {
        get {
            return Country.Continents[String(continent)] ?? "None"
        }
    }
    
    var languagesNames: String {
        get {
            var languageNames = [String]()
            for language in languages {
                if let name = Country.Languages[String(language)] {
                    languageNames.append(name)
                }
            }
            return languageNames.joined(separator: ", ")
        }
    }
}
