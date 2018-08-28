//
//  Event.swift
//  PIKE
//
//  Created by Devin Lee on 12/29/16.
//  Copyright © 2016 Devin Lee. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Event: CustomStringConvertible{
    
    /* Event has a user, date, itemRef and the actual content */
    let content: String!
    let day: String!
    let month: String!
    let location: String!
    var id: String!

    let itemRef: DatabaseReference?
    
    init (day: String, month: String, content: String, location: String) {
        self.content = content
        self.itemRef = nil
        self.day = day
        self.month = month
        self.location = location
    }
    
    mutating func setID(id: String) {
        self.id = id
    }
    
    init (snapshot:DataSnapshot) {
        itemRef = snapshot.ref
        let value = snapshot.value as? NSDictionary
        
        if let messageDay = value?["day"] as? String {
            day = messageDay
        } else {
            day = ""
        }
        
        if let messageMonth = value?["month"] as? String {
            month = messageMonth
        } else {
            month = ""
        }
        
        if let messageContent = value?["content"] as? String {
            content = messageContent
        } else {
            content = ""
        }
        
        if let messageCat = value?["location"] as? String {
            location = messageCat
        } else {
            location = ""
        }
        if let messageID = value?["id"] as? String {
            id = messageID
        } else {
            id = ""
        }
    }
    
    func toAnyObject() -> Any {
        return ["day": day, "month": month, "content": content, "location": location, "id": id]
    }
    
    internal var description: String { return "{\(month!) \(day!)}: \(content.hashValue.description)" }
    
}
