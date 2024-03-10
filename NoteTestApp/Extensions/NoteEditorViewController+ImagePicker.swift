//
//  EditNoteVC+ImagePicker.swift
//  NoteTestApp
//
//  Created by Albert Garipov on 09.03.2024.
//

import UIKit

extension NoteEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            let resizedImage = resizeImage(selectedImage, targetSize: CGSize(width: UIScreen.main.bounds.width - 16*2, height: 200))
            insertImageIntoNote(resizedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func insertImageIntoNote(_ image: UIImage) {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        
        let mutableAttributedString = NSMutableAttributedString(attributedString: textView.attributedText)
        mutableAttributedString.append(NSAttributedString(string: "\n"))
        
        let imageString = NSAttributedString(attachment: imageAttachment)
        mutableAttributedString.append(imageString)
        mutableAttributedString.append(NSAttributedString(string: "\n"))
        
        textView.attributedText = mutableAttributedString
        restoreTypingAttributes()
    }
    
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio = targetSize.width / size.width
        let newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        let rect = CGRect(origin: .zero, size: newSize)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
    
    private func restoreTypingAttributes() {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: currentFontSize),
            .paragraphStyle: NSParagraphStyle.default
        ]
        
        if isBold {
            attributes[.font] = UIFont.boldSystemFont(ofSize: currentFontSize)
        }
        if isItalic {
            let fontDescriptor = UIFont.systemFont(ofSize: currentFontSize).fontDescriptor.withSymbolicTraits(.traitItalic)
            attributes[.font] = UIFont(descriptor: fontDescriptor!, size: currentFontSize)
        }
        if isUnderline {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        
        textView.typingAttributes = attributes
    }
}
