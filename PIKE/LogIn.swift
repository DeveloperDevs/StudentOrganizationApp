//
//  LogIn.swift
//
//  Created by Devin Lee on 5/17/18.
//  Copyright © 2018 Devin Lee. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LogIn: UIViewController {

    @IBOutlet var email: UILabel!
    @IBOutlet var textfield: UITextField!
    
    /* This is how we order messages */
    var theID: DatabaseReference!
    /* Reference to users */
    var users: DatabaseReference!
    /* A database reference */
    var dbRef: DatabaseReference!
    /* Reference to number of users */
    var userCount: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /* Initialize database reference (Sets to child for better access of items */
        dbRef = Database.database().reference().child("messages")
        theID = Database.database().reference().child("count")
        users = Database.database().reference().child("users")
        userCount = Database.database().reference().child("userCount")
    }
    
    @IBAction func logIn(_ sender: Any) {
        /* Sign them into Firebase */
        Auth.auth().signIn(withEmail: email.text!, password: textfield.text!, completion: { (User, Error) in
            if Error != nil {
                print("LOG IN FAILED")
            } else {
                print("LOG IN SUCCESS")
            }
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.textfield.endEditing(true)
    }
}
