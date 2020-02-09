//
//  CaptionedImage.swift
//  MilestoneChallenge4
//
//  Created by Ian McDonald on 09/02/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import Foundation

class CaptionedImage: Codable {
    var image: String
    var caption: String
    var date: Date
    
    init(caption: String, image: String, date: Date = Date()) {
        self.caption = caption
        self.image = image
        self.date = date
    }
}
