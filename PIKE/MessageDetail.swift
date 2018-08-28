//
//  MessageDetail.swift
//
//  Created by Devin Lee on 12/25/16.
//  Copyright © 2016 Devin Lee. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MessageDetail: UIViewController {
    
    @IBOutlet var picture: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var message: UITextView!
    @IBOutlet var category: UILabel!
    @IBOutlet var priority: UILabel!
    
    var nameIn: String?
    var contentIn: String?
    var photoIn: UIImage?
    var categoryIn: String?
    var priorityIn: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Instantiate message details */
        Database.database().reference().child("users").child(nameIn!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let name = value?["name"] as? String
            self.name.text = name
        })
        
        self.message.text = contentIn
        self.category.text = categoryIn
        self.priority.text = priorityIn
        self.name.sizeToFit()
        self.category.sizeToFit()
        
        self.message.isEditable = false
        print("is photoin not nil?")
        print(photoIn != nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // change 2 to desired number of seconds
            // Your code with delay
            if (self.photoIn != nil) {
                print("photoin is not nil")
                self.picture.image = self.photoIn!
                
                self.picture.layer.cornerRadius = 10.0
                self.picture.layer.borderColor = UIColor.white.cgColor
                //self.picture.layer.masksToBounds = true
                self.picture.layer.borderWidth = 1
                self.picture.layer.masksToBounds = false
                self.picture.layer.cornerRadius = self.picture.frame.height/2
                self.picture.clipsToBounds = true
            }
        }

    }

    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.message.endEditing(true)
    }

}
