//
//  Card.swift
//  MilestoneChallenge10
//
//  Created by Ian McDonald on 22/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import Foundation

class Card {
    var id: UUID
    var value: String
    var isFaceUp = false
    var isHidden = false
    
    init(id: UUID = UUID(), value: String) {
        self.id = id
        self.value = value
    }
}
