//
//  Item.swift
//  Sector 471
//
//  Created by Fajer alQahtani on 16/08/1447 AH.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
