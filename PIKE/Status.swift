//
//  Status.swift
//  PIKE
//
//  Created by Devin Lee on 1/16/17.
//  Copyright © 2017 Devin Lee. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Status {
    
    /* Message has a user, ID, itemRef and the actual content */
    var name: String!
    let status: String!
    let itemRef: DatabaseReference?
    
    init (name: String, status: String) {
        self.name = name
        self.status = status
        self.itemRef = nil
    }
    
    init (snapshot:DataSnapshot) {
        itemRef = snapshot.ref
        let value = snapshot.value as? String
        self.name = ""
        
        let id = snapshot.key
        
        self.name = id
        
        if let theStatus = value {
            status = theStatus
            print(theStatus)
        } else {
            status = ""
        }
    }
    
    
}
