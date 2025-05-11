//
//  Item.swift
//  habit-tracker
//
//  Created by Alex Johny on 5/11/25.
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
