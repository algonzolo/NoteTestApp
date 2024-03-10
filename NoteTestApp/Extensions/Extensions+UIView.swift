//
//  Extensions+UIView.swift
//  NoteTestApp
//
//  Created by Albert Garipov on 09.03.2024.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach({
            addSubview($0)
        })
    }
}
