//
//  Sender.swift
//
//  Created by Devin Lee on 12/28/16.
//  Copyright © 2016 Devin Lee. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

protocol SenderDelegate {
    func receivePayload(info: String, category: String, priority: String)
}

class Sender: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {


    @IBOutlet var priority: UIPickerView!
    @IBOutlet var theMessage: UITextView!
    @IBOutlet var category: UITextField!
    var priorityLevel: String! = "Normal"
    /* Reference to users */
    var users: DatabaseReference!
    
    var pickerData: [String] = []

    var theDelegate: SenderDelegate!
    
    override func viewDidLoad() {
        users = Database.database().reference().child("users")
        
        /* If someone is logged in, load data */
        if Auth.auth().currentUser != nil /* let user = FIRAuth.auth()!.currentUser */ {
            self.users.child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                
                let account = value?["type"] as! String
                if (account == "Standard") {
                    self.pickerData = ["Normal", "Social"]
                    self.priority.delegate = self;
                } else if (account == "Advanced") {
                    self.pickerData = ["Normal", "Social", "Official"]
                    self.priority.delegate = self;
                } else if (account == "Premium") {
                    self.pickerData = ["Normal", "Social", "Official", "Important"]
                    self.priority.delegate = self;
                } else {
                    print("ACCOUNT TYPING FUCKED UP")
                }
            })
        }
        super.viewDidLoad()

        priority.dataSource = self
        priority.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.theMessage.endEditing(true)
        self.category.endEditing(true)
    }

    
    @IBAction func send(_ sender: Any) {
        if theDelegate != nil {
            let info = theMessage.text
            let category = self.category.text
            theDelegate.receivePayload(info: info!, category: category!, priority: priorityLevel)
        }
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    /* THIS IS WHAT HAPPENS WHEN THE PICKER SELECTS SOMETHING */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        priorityLevel = pickerData[row]
    }
    
    
}
