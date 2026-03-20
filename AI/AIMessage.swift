//
//  AIMessage.swift
//  ChainTrackr
//
//  Created by Lakshman Ryali on 18/07/25.
//

import Foundation

struct AIMessage: Identifiable, Codable {
    let id = UUID()
    let content: String
    let isUser: Bool
    
    let timestamp: Date
    
    // Add this convenience initializer for backward compatibility
    init(content: String, isUser: Bool, timestamp: Date = Date()) {
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }
}
