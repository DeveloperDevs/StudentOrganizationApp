//
//  Message.swift
//  PIKE
//
//  Created by Devin Lee on 10/31/16.
//  Copyright © 2016 Devin Lee. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Message: CustomStringConvertible{
    
    /* Message has a user, ID, itemRef and the actual content */
    let content: String!
    let addedByUser: String!
    let priority: String!
    let creationDateID: Int!
    let photo: String!
    let category: String!
    let itemRef: DatabaseReference?
    
    init (content: String, addedByUser: String, id: Int, photo: String, category: String, priority: String) {
        self.content = content
        self.addedByUser = addedByUser
        self.photo = photo
        self.category = category
        self.itemRef = nil
        self.creationDateID = id
        self.priority = priority
    }
    
    init (snapshot:DataSnapshot) {
        itemRef = snapshot.ref
        let value = snapshot.value as? NSDictionary

        if let messageContent = value?["content"] as? String {
            content = messageContent
        } else {
            content = ""
        }
        
        if let theUser = value?["addedByUser"] as? String {
            addedByUser = theUser
        } else {
            addedByUser = ""
        }
        
        if let theID = value?["id"] as? Int {
            creationDateID = theID
        } else {
            creationDateID = 0
        }
        
        if let thePhoto = value?["photo"] as? String {
            photo = thePhoto
        } else {
            photo = ""
        }
        
        if let theCat = value?["category"] as? String {
            category = theCat
        } else {
            category = ""
        }
        if let thePrio = value?["priority"] as? String {
            priority = thePrio
        } else {
            priority = ""
        }
        

    }
    
    func toAnyObject() -> Any {
        return ["content": content, "addedByUser": addedByUser, "id": creationDateID, "photo": photo, "category": category, "priority": priority]
    }
    
    internal var description: String { return "{\(content): \(creationDateID)}" }
    
}
