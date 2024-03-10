//  NoteEditorViewController.swift
//  NoteTestApp
//
//  Created by Albert Garipov on 09.03.2024.
//

import UIKit

final class NoteEditorViewController: UIViewController {
    
    //MARK: - Properties
    var note: Note?
    var isBold = false
    var isItalic = false
    var isUnderline = false
    var currentFontSize: CGFloat = 18
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
        
        if let attributedTextData = note?.attributedTextData {
            do {
                if let attributedText = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSAttributedString.self, from: attributedTextData) {
                    textView.attributedText = attributedText
                }
            } catch {
                print("Error unarchiving attributed text: \(error)")
            }
        } else {
            textView.text = note?.text
            textView.font = UIFont.systemFont(ofSize: currentFontSize)
        }
        
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        textView.textContainer.lineFragmentPadding = 0
        view.addSubview(textView)
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveNote))
    }
    
    @objc private func saveNote() {
        guard let attributedText = textView.attributedText else { return }
        
        let attributedTextData = try? NSKeyedArchiver.archivedData(withRootObject: attributedText, requiringSecureCoding: false)
        
        note?.text = attributedText.string
        note?.attributedTextData = attributedTextData
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
        let underlineButton = UIBarButtonItem(image: UIImage(systemName: "underline"), style: .plain, target: self, action: #selector(toggleUnderlineText))
        let imageButton = UIBarButtonItem(image: UIImage(systemName: "photo.artframe"), style: .plain, target: self, action: #selector(imageButtonTapped))
        
        toolbar.setItems([flexibleSpace, boldButton, flexibleSpace, italicButton, flexibleSpace, underlineButton, flexibleSpace, imageButton, flexibleSpace], animated: false)
        textView.inputAccessoryView = toolbar
    }
    
    @objc private func toggleBoldText() {
        isBold.toggle()
        updateFont()
    }
    
    @objc private func toggleItalicText() {
        isItalic.toggle()
        updateFont()
    }
    
    @objc private func toggleUnderlineText() {
        isUnderline.toggle()
        updateFont()
        var newTypingAttributes = textView.typingAttributes
        newTypingAttributes[.underlineStyle] = isUnderline ? NSUnderlineStyle.single.rawValue : 0
        textView.typingAttributes = newTypingAttributes
    }
    
    @objc private func imageButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: - Logic for update font
    private func updateFont() {
        let currentAttributes: [NSAttributedString.Key: Any]
        if let selectedRange = textView.selectedTextRange, !selectedRange.isEmpty, let selectedTextAttributes = textView.textStorage.attributes(at: textView.offset(from: textView.beginningOfDocument, to: selectedRange.start), effectiveRange: nil) as [NSAttributedString.Key: Any]? {
            currentAttributes = selectedTextAttributes
        } else {
            currentAttributes = textView.typingAttributes
        }
        
        var newAttributes = currentAttributes
        
        if let existingFont = currentAttributes[.font] as? UIFont {
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
                let newFont = UIFont(descriptor: newFontDescriptor, size: currentFontSize)
                newAttributes[.font] = newFont
            }
        }
        
        newAttributes[.underlineStyle] = isUnderline ? NSUnderlineStyle.single.rawValue : 0
        
        
        if let selectedRange = textView.selectedTextRange, !selectedRange.isEmpty {
            textView.textStorage.addAttributes(newAttributes, range: textView.selectedRange)
        }
        textView.typingAttributes = newAttributes
    }
}

//MARK: - UITextViewDelegate
extension NoteEditorViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let isNoteEmpty = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        navigationItem.rightBarButtonItem?.isEnabled = !isNoteEmpty
    }
}
