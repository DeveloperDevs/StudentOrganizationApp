//
//  Results.swift
//
//  Created by Devin Lee on 5/27/18.
//  Copyright © 2018 Devin Lee. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class Results: UIViewController {
    
    /* Reference to users */
    var users: DatabaseReference!

    
    @IBOutlet var name: UILabel!
    @IBOutlet var age: UILabel!
    @IBOutlet var sex: UILabel!
    @IBOutlet var birthday: UILabel!
    @IBOutlet var major: UILabel!
    @IBOutlet var grade: UILabel!
    @IBOutlet var position: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        users = Database.database().reference().child("users")
        
        Auth.auth().addStateDidChangeListener({ (Auth, User) in
            /* If someone is logged in, load data */
            if Auth.currentUser != nil /* let user = FIRAuth.auth()!.currentUser */ {
                self.users.child(Auth.currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in

                    let value = snapshot.value as? NSDictionary
                    
                    if (value?["name"] != nil) {
                        self.name.text = value!["name"] as? String
                    }
                    if (value?["Major"] != nil) {
                        self.major.text = value!["Major"] as? String
                    }
                    if (value?["Birthday"] != nil) {
                        self.birthday.text = value!["Birthday"] as? String
                    }
                    if (value?["Age"] != nil) {
                        self.age.text = value!["Age"] as? String
                    }
                    if (value?["Sex"] != nil) {
                        self.sex.text = value!["Sex"] as? String
                    }
                    if (value?["Grade"] != nil) {
                        self.grade.text = value!["Grade"] as? String
                    }
                    if (value?["Position"] != nil) {
                        self.position.text = value!["Position"] as? String
                    }
                })
            }
                /* Otherwise, no one logged in... */
            else {
                let failureAlert = UIAlertController(title: "You need to register or log in", message: "Click the login button to do so", preferredStyle: .alert)
                failureAlert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action:UIAlertAction) in
                }))
                /* Present to view controller */
                self.present(failureAlert, animated: true, completion: nil)
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
