//
//  NoteEditorViewController.swift
//  NoteTestApp
//
//  Created by Albert Garipov on 09.03.2024.
//

import UIKit

final class NoteEditorViewController: UIViewController {
    //MARK: - Properties
    var note: Note?
    private var isBold = false
    private var isItalic = false
    private var isUnderline = false
    private var currentFontSize: CGFloat = 18
    var completion: (Note) -> Void
    var textView: UITextView!
    
    //MARK: - Init
    init(note: Note?, completion: @escaping (Note) -> Void) {
        self.note = note ?? Note(text: "")
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()
        setupNavigationBar()
        setupFormattingToolbar()
        navigationItem.rightBarButtonItem?.isEnabled = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    //MARK: - Private methods
    private func setupTextView() {
        textView = UITextView(frame: view.bounds)
        textView.delegate = self
        textView.text = note?.text
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        textView.font = UIFont.systemFont(ofSize: 18)
        view.addSubview(textView)
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveNote))
    }
    
    @objc private func saveNote() {
        guard let text = textView.text else { return }
        note?.text = text
        completion(note!)
        navigationController?.popViewController(animated: true)
    }
}
//MARK: - Buttons methods
extension NoteEditorViewController {
    private func setupFormattingToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let boldButton = UIBarButtonItem(image: UIImage(systemName: "bold"), style: .plain, target: self, action: #selector(toggleBoldText))
        let italicButton = UIBarButtonItem(image: UIImage(systemName: "italic"), style: .plain, target: self, action: #selector(toggleItalicText))
        let underlinebutton = UIBarButtonItem(image: UIImage(systemName: "underline"), style: .plain, target: self, action: #selector(toggleUnderlineText))
        let fontButton = UIBarButtonItem(image: UIImage(systemName: "textformat.size"), style: .plain, target: self, action: #selector(toggleFontText))
        let imageButton = UIBarButtonItem(image: UIImage(systemName: "photo.artframe"), style: .plain, target: self, action: #selector(imageButtonTapped))
        
        toolbar.setItems([flexibleSpace, boldButton, flexibleSpace, italicButton, flexibleSpace, underlinebutton, flexibleSpace, fontButton, flexibleSpace, imageButton, flexibleSpace], animated: false)
        textView.inputAccessoryView = toolbar
    }
    
    @objc private func toggleBoldText() {
        isBold.toggle()
        updateFont(isBold: isBold, isItalic: isItalic, isUnderline: isUnderline, fontSize: currentFontSize)
    }
    
    @objc private func toggleItalicText() {
        isItalic.toggle()
        updateFont(isBold: isBold, isItalic: isItalic, isUnderline: isUnderline, fontSize: currentFontSize)
    }
    
    @objc private func toggleUnderlineText() {
        isUnderline.toggle()
        updateFont(isBold: isBold, isItalic: isItalic, isUnderline: isUnderline, fontSize: currentFontSize)
    }
    
    @objc private func toggleFontText() {
        currentFontSize = (currentFontSize == 24) ? 18 : 24
        updateFont(isBold: isBold, isItalic: isItalic, isUnderline: isUnderline, fontSize: currentFontSize)
    }
    
    @objc private func imageButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func updateFont(isBold: Bool, isItalic: Bool, isUnderline: Bool, fontSize: CGFloat) {
        guard textView.selectedTextRange != nil else { return }
        
        var attributes: [NSAttributedString.Key: Any] = [:]
        let existingFont = textView.font ?? UIFont.systemFont(ofSize: fontSize)
        var newTraits = existingFont.fontDescriptor.symbolicTraits
        
        if isBold {
            newTraits.insert(.traitBold)
        } else {
            newTraits.remove(.traitBold)
        }
        
        if isItalic {
            newTraits.insert(.traitItalic)
        } else {
            newTraits.remove(.traitItalic)
        }
        
        if let newFontDescriptor = existingFont.fontDescriptor.withSymbolicTraits(newTraits) {
            let newFont = UIFont(descriptor: newFontDescriptor, size: fontSize)
            attributes[.font] = newFont
        }
        
        if isUnderline {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        } else {
            attributes[.underlineStyle] = 0
        }
        
        textView.textStorage.addAttributes(attributes, range: textView.selectedRange)
    }
}

//MARK: - UITextViewDelegate
extension NoteEditorViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let isNoteEmpty = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        navigationItem.rightBarButtonItem?.isEnabled = !isNoteEmpty
    }
}
