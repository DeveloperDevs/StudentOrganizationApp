//
//  SetUp.swift
//
//  Copyright © 2018 Devin Lee. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase


class SetUp: UIViewController {

    @IBOutlet var month: UITextField!
    @IBOutlet var day: UITextField!
    @IBOutlet var year: UITextField!
    @IBOutlet var major: UITextField!
    @IBOutlet var grade: UITextField!
    @IBOutlet var position: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.major.endEditing(true)
        self.grade.endEditing(true)
        self.month.endEditing(true)
        self.day.endEditing(true)
        self.year.endEditing(true)
        self.position.endEditing(true)
    }
    
    @IBAction func setMale(_ sender: Any) {
        Auth.auth().addStateDidChangeListener({ (Auth, User) in
            /* If someone is logged in, save pet data */
            if Auth.currentUser != nil /* let user = FIRAuth.auth()!.currentUser */ {
                
                /* Add sex*/
                Database.database().reference().child("users").child(Auth.currentUser!.uid).child("Sex").setValue("Male")
                
                let successAlert = UIAlertController(title: "Sex Selected", message: "You have set your sex to Male", preferredStyle: .alert)
                successAlert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action:UIAlertAction) in
                }))
                /* Present to view controller */
                self.present(successAlert, animated: true, completion: nil)
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
    
    @IBAction func setFemale(_ sender: Any) {
        Auth.auth().addStateDidChangeListener({ (Auth, User) in
            /* If someone is logged in, save pet data */
            if Auth.currentUser != nil /* let user = FIRAuth.auth()!.currentUser */ {
                
                /* Add sex*/
                Database.database().reference().child("users").child(Auth.currentUser!.uid).child("Sex").setValue("Female")
                
                let successAlert = UIAlertController(title: "Sex Selected", message: "You have set your sex to Female", preferredStyle: .alert)
                    successAlert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action:UIAlertAction) in
                    }))
                    /* Present to view controller */
                    self.present(successAlert, animated: true, completion: nil)
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

    @IBAction func savePetData(_ sender: Any) {
        Auth.auth().addStateDidChangeListener({ (Auth, User) in
            /* If someone is logged in, save pet data */
            if Auth.currentUser != nil /* let user = FIRAuth.auth()!.currentUser */ {
                
                /* Add pet name, breed and age to database*/
                Database.database().reference().child("users").child(Auth.currentUser!.uid).child("Major").setValue(self.major.text)
                Database.database().reference().child("users").child(Auth.currentUser!.uid).child("Grade").setValue(self.grade.text)
                Database.database().reference().child("users").child(Auth.currentUser!.uid).child("Position").setValue(self.position.text)
                
                var birthday = self.month.text! + "/"
                birthday = birthday + self.day.text! + "/"
                birthday = birthday + self.year.text!
                let age = String(self.calcAge(birthday: birthday))
               
                Database.database().reference().child("users").child(Auth.currentUser!.uid).child("Age").setValue(age)
                Database.database().reference().child("users").child(Auth.currentUser!.uid).child("Birthday").setValue(birthday)
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
    
    /* Calculates age from birthday */
    func calcAge(birthday: String) -> Int {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM/dd/yyyy"
        let birthdayDate = dateFormater.date(from: birthday)
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
        let now = Date()
        if (birthdayDate != nil) {
            let calcAge = calendar.components(.year, from: birthdayDate!, to: now, options: [])
            let age = calcAge.year
            return age!
        } else {
            return 0
        }
    }
    

}
