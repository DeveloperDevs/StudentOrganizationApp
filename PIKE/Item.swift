//
//  Item.swift
//  PIKE
//
//  Created by Devin Lee on 1/19/17.
//  Copyright © 2017 Devin Lee. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Item {

    let photo: String!
    let name: String!
    let price: String!
    let itemRef: DatabaseReference?
    var id: String!
    
    init (photo: String, name: String, price: String, id: String) {
        self.photo = photo
        self.name = name
        self.itemRef = nil
        self.price = price
        self.id = id
    }
    
    init (snapshot:DataSnapshot) {
        itemRef = snapshot.ref
        let value = snapshot.value as? NSDictionary
        
        if let thePhoto = value?["photo"] as? String {
            photo = thePhoto
        } else {
            photo = ""
        }
        
        if let theName = value?["name"] as? String {
            name = theName
        } else {
            name = ""
        }
        
        if let thePrice = value?["price"] as? String {
            price = thePrice
        } else {
            price = ""
        }
        
        if let theID = value?["id"] as? String {
            id = theID
        } else {
            id = ""
        }
        
    }
    
    mutating func setID(id: String) {
        self.id = id
    }

    
    func toAnyObject() -> Any {
        return ["photo": photo, "name": name, "price": price, "id": id]
    }
}
