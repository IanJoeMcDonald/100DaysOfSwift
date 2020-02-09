//
//  DocumentsDirectory.swift
//  MilestoneChallenge4
//
//  Created by Ian McDonald on 09/02/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import Foundation

struct DocumentsDirectory {
    static var shared = DocumentsDirectory()
    
    func get() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
