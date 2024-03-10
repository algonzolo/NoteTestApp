//
//  NotesListVC.swift
//  NoteTestApp
//
//  Created by Albert Garipov on 09.03.2024.
//

import UIKit

final class NotesListViewController: UIViewController {
    
    //MARK: - Properties
    private var tableView: UITableView!
    private var notesManager = NotesManager()
    private var notes: [Note] = []
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Notes"
        setupTableView()
        loadNotes()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewNote))
    }
    
    //MARK: - Private methods
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.register(NoteListTableViewCell.self, forCellReuseIdentifier: NoteListTableViewCell.cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }
    
    private func loadNotes() {
        notesManager.loadNotes()
        notes = notesManager.getAllNotes()
        tableView.reloadData()
    }
    
    @objc private func addNewNote() {
        let newNoteVC = NoteEditorViewController(note: nil, completion: { [weak self] newNote in
            self?.notesManager.add(note: newNote)
            self?.loadNotes()
        })
        navigationController?.pushViewController(newNoteVC, animated: true)
    }
}

//MARK: - UITableViewDelegate & UITableViewDataSource
extension NotesListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteListTableViewCell.cellIdentifier, for: indexPath) as? NoteListTableViewCell else { fatalError() }
        let note = notes[indexPath.row]
        
        if let attributedTextData = note.attributedTextData {
            do {
                let attributedText = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSAttributedString.self, from: attributedTextData)
                cell.contentLabel.attributedText = attributedText
            } catch {
                print("Error unarchiving attributed text: \(error)")
                cell.contentLabel.text = note.text
            }
        } else {
            cell.contentLabel.text = note.text
        }
        
        cell.titleLabel.text = "№\(indexPath.row + 1)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let note = notes[indexPath.row]
        let editorVC = NoteEditorViewController(note: note, completion: { [weak self] updatedNote in
            self?.notesManager.update(note: updatedNote)
            self?.loadNotes()
        })
        navigationController?.pushViewController(editorVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let noteToDelete = notes[indexPath.row]
            notesManager.delete(note: noteToDelete)
            loadNotes()
        }
    }
}
