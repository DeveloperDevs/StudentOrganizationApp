//
//  Order.swift
//  PIKE
//
//  Created by Devin Lee on 1/20/17.
//  Copyright © 2017 Devin Lee. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Order {
    
    /* Message has a user, ID, itemRef and the actual content */
    var name: String!
    let size: String!
    var quantity: String!
    let itemRef: DatabaseReference?
    
    init (name: String, size: String, quantity: String) {
        self.name = name
        self.size = size
        self.quantity = quantity
        self.itemRef = nil
    }
    
    init (snapshot:DataSnapshot) {
        itemRef = snapshot.ref
        let value = snapshot.value as? NSDictionary

        if let theName = value?["name"] as? String {
            name = theName
        } else {
            name = ""
        }
        
        if let theSize = value?["size"] as? String {
            size = theSize
        } else {
            size = ""
        }
        
        if let theQuant = value?["quantity"] as? String {
            quantity = theQuant
        } else {
            quantity = ""
        }
    }
    
    func toAnyObject() -> Any {
        return ["name" : name, "size" : size, "quantity": quantity]
    }
    
    func testFun() -> Bool {
        if Int(size) ?? -1 > 0 {
            return true
        } else {
            return false
        }
    }
    
}
