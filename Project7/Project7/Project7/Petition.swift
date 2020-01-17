//
//  Petition.swift
//  Project7
//
//  Created by Masipack Eletronica on 17/01/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import Foundation

struct Petition : Codable {
    var title: String
    var body: String
    var signatureCount: Int
}
