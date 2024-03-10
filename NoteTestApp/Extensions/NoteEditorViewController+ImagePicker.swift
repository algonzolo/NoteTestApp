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
            let resizedImage = resizeImage(selectedImage, targetSize: CGSize(width: 200, height: 200))
            insertImageIntoNote(resizedImage, withAttributes: textView.typingAttributes)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func insertImageIntoNote(_ image: UIImage, withAttributes attributes: [NSAttributedString.Key: Any]) {
        guard let currentText = textView.attributedText else { return }
        let mutableAttributedString = NSMutableAttributedString(attributedString: currentText)

        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image

        let imageString = NSAttributedString(attachment: imageAttachment)
        mutableAttributedString.append(imageString)

        textView.attributedText = mutableAttributedString
        textView.typingAttributes = attributes
    }
    
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
}

