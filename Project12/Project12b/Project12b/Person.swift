//
//  Person.swift
//  Project10
//
//  Created by Masipack Eletronica on 06/02/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit

class Person: NSObject, Codable {
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
