//
//  Notes.swift
//  MilestoneProject7
//
//  Created by Masipack Eletronica on 11/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import Foundation

class Note: Codable {
    var id = UUID()
    var text: String
    var date: Date
    
    init (text: String = "", date: Date = Date()) {
        self.text = text
        self.date = date
    }
}

struct Notes: Codable {
    private(set) var list: [Note]
    static let saveKey = "SavedNotes"
    init() {
        let filename = Notes.getDocumentsDirectory().appendingPathComponent(Notes.saveKey)
        
        if let data = try? Data(contentsOf: filename) {
            if let decoded = try? JSONDecoder().decode([Note].self, from: data) {
                self.list = decoded
                return
            }
        }
        list = []
    }
    
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func save() {
        let filename = Notes.getDocumentsDirectory().appendingPathComponent(Notes.saveKey)
        if let data = try? JSONEncoder().encode(list) {
            try? data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
        }
    }
    
    mutating func update(_ note: Note) {
        if let index = list.firstIndex(where: { $0.id == note.id }) {
            list.remove(at: index)
            list.insert(note, at: index)
            save()
        }
    }
    
    mutating func add(_ note: Note) {
        list.insert(note, at: 0)
        save()
    }
    
    mutating func delete(_ id: UUID) {
        if let index = list.firstIndex(where: { $0.id == id }) {
            list.remove(at: index)
            save()
        }
    }
    
}
