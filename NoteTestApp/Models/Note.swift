//
//  Note.swift
//  NoteTestApp
//
//  Created by Albert Garipov on 09.03.2024.
//

import UIKit

struct Note: Codable, Equatable {
    var id: UUID
    var text: String
    var attributedTextData: Data?
    
    init(id: UUID = UUID(), text: String, attributedTextData: Data? = nil) {
        self.id = id
        self.text = text
        self.attributedTextData = attributedTextData
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, text, attributedTextData
    }
}

//MARK: - Decode & Encode methods for attributedTextData
extension Note {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        
        if let attributedTextData = try container.decodeIfPresent(Data.self, forKey: .attributedTextData) {
            self.attributedTextData = attributedTextData
        } else {
            attributedTextData = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        
        if let attributedTextData = self.attributedTextData {
            try container.encode(attributedTextData, forKey: .attributedTextData)
        }
    }
}


