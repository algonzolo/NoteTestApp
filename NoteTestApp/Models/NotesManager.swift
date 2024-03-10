//
//  NotesManager.swift
//  NoteTestApp
//
//  Created by Albert Garipov on 09.03.2024.
//

import Foundation

final class NotesManager {
    
    //MARK: - Properties
    private var notes: [Note] = []
    private let notesKey = "notes"
    private let welcomeNote = Note(text: "Welcome to Notes App!")
    
    //MARK: - Methods
    func loadNotes() {
        if let savedNotesData = UserDefaults.standard.object(forKey: notesKey) as? Data {
            let decoder = JSONDecoder()
            if let loadedNotes = try? decoder.decode([Note].self, from: savedNotesData) {
                notes = loadedNotes

                let hasUserNotes = notes.contains { $0.id != welcomeNote.id }
                
                if hasUserNotes, let welcomeNoteIndex = notes.firstIndex(of: welcomeNote) {
                    notes.remove(at: welcomeNoteIndex)
                }

                return
            }
        }
        if notes.isEmpty || (notes.count == 1 && notes.first?.id == welcomeNote.id) {
            notes = [welcomeNote]
        }
    }

    func saveNotes() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(notes) {
            UserDefaults.standard.set(encoded, forKey: notesKey)
        }
    }

    func add(note: Note) {
        notes.insert(note, at: 0)
        saveNotes()
    }

    func update(note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes.remove(at: index)
        }
        notes.insert(note, at: 0)
        saveNotes()
    }

    func delete(note: Note) {
        notes.removeAll { $0.id == note.id }
        saveNotes()
    }

    func getAllNotes() -> [Note] {
        return notes
    }
}

