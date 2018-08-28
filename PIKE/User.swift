//
//  User.swift
//  PIKE
//
//  Created by Devin Lee on 10/31/16.
//  Copyright © 2016 Devin Lee. All rights reserved.
//

import Foundation
import FirebaseAuth

struct SilcUser: Equatable {
    /* User has two strings, a username and email */
    let name: String
    let email: String
    
    let id: String
    let profilePic: String
    
    /* Initializer for FIRUser */
    init (userData:UserInfo) {
        name = userData.displayName!
        
        if let mail = userData.email {
            email = mail
        } else {
            email = ""
        }
        
        id = userData.uid
        profilePic = "gs://shining-torch-3755.appspot.com/blank.png"
    }
    
    /* Initializer */
    init (name: String, email: String, id: String) {
        self.name = name
        self.email = email
        self.id = id
        self.profilePic = "gs://shining-torch-3755.appspot.com/blank.png"
    }
    
    func toAnyObject() -> Any {
        return ["name": name, "email": email, "ID": id, "profilePic": profilePic, "type": "C-Class", "priority": "Important"]
    }
}

func == (lhs: SilcUser, rhs: SilcUser) -> Bool {
    return lhs.email == rhs.email
}
