//
//  Feed.swift
//
//  Created by Devin Lee on 10/21/16.
//  Copyright © 2016 Devin Lee. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import CloudKit
import UserNotifications

class Feed: UITableViewController, SenderDelegate {
    
    /* Array of events held within the Table*/
    var events = [Message]()
    /* This is how we order messages */
    var theID: DatabaseReference!
    /* Reference to users */
    var users: DatabaseReference!
    /* A database reference */
    var dbRef: DatabaseReference!
    /* Reference to number of users */
    var userCount: DatabaseReference!
    /* Allows user to slide down to refresh messages */
    var refresh: UIRefreshControl!
    
    
    /*
     * Load function
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Set up refresh variable */
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Refresh")
        refresh.addTarget(self, action: #selector(Feed.loadData), for: .valueChanged)
        self.tableView.addSubview(refresh)
        
        /* Initialize database reference (Sets to child for better access of items */
        dbRef = Database.database().reference().child("messages")
        theID = Database.database().reference().child("count")
        users = Database.database().reference().child("users")
        userCount = Database.database().reference().child("userCount")
        
        /* Observe the database for changes */
        loadData()
    }
    
    
    
    
    /* 
     * Check if authentication state changes before displaying data
     */
    override func viewDidAppear(_ animated: Bool) {
        /* Call from the super class */
        super.viewDidAppear(animated)
        /* Check auth */
        Auth.auth().addStateDidChangeListener({ (Auth, User) in
            /* If someone is logged in, load data */
            if Auth.currentUser != nil /* let user = FIRAuth.auth()!.currentUser */ {
                self.loadData()
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
    
    
    
    /* 
     * Observe the database for any changes and then update the feed 
     */
    @objc func loadData () {
        /* Check auth */
        Auth.auth().addStateDidChangeListener({ (Auth, User) in
            /* If someone is logged in, load data */
            if Auth.currentUser != nil /* let user = FIRAuth.auth()!.currentUser */ {
                /* Listen for new comments in Firebase database */
                self.dbRef.observe(.value, with: { (snapshot:DataSnapshot) in
                    /* Array of new items */
                    var newMessages = [Message]()
                    
                    /* Iterate through messages in snapshot*/
                    for child in snapshot.children {
                        /* Create an object from the message constructor */
                        let message = Message(snapshot: child as! DataSnapshot)
                        newMessages.append(message)
                    }
                    
                    /* Sort the array in ascending order */
                    self.events = newMessages.sorted(by: {
                        $0.creationDateID! > $1.creationDateID!
                    })
                    
                    DispatchQueue.main.async {
                        /* Reload data in the table */
                        self.tableView.reloadData()
                    }
                    
                    /* Stop refreshing */
                    self.refresh.endRefreshing()
                    
                }) { (error: Error) in
                }
            }
                /* Otherwise, no one logged in... */
            else {
            }
        })
    }
    
    
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
    }
    
    /* This simply initializes the delegate */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SenderSegue" {
            
            if let theSender = segue.destination as? Sender {
                theSender.theDelegate = self
            }
        }
    }
    
    
    
    /* This receives information from the textfield in the message sender and adds to feed */
    func receivePayload(info: String, category: String, priority: String) {
        let messageContent = info
        /* Check auth */
        Auth.auth().addStateDidChangeListener({ (Auth, User) in
            /* If someone is logged in, load data */
            if Auth.currentUser != nil /* let user = FIRAuth.auth()!.currentUser */ {
                /* We need to give each message an id before sending */
                self.theID.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    /* Get the data snapshot in order to give the message an ID */
                    let value = snapshot.value as? NSString
                    var anID = value?.integerValue
                    anID = anID! + 1
                    self.theID.setValue("\(anID!)")
                    
                    let id = 1000000 - anID!
                    
                    /* Now we need to get user info */
                    let user = Auth.currentUser
                    let name = user?.uid
                    /* Get profile picture */
                    self.users.child(Auth.currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        let value = snapshot.value as? NSDictionary
                        
                        if (value?["profilePic"] != nil) {
                            let link = value!["profilePic"] as? String
                            /* Now create the actual message*/
                            let message = Message(content: messageContent, addedByUser: name!, id: anID!, photo: link!, category: category, priority: priority)
                            /* Send message to database reference to update database */
                            let messageRef = self.dbRef.child(id.description)
                            /* Set value of reference content to message content */
                            messageRef.setValue(message.toAnyObject())
                            self.events.append(message)
                        } else {
                            /* Now create the actual message*/
                            let message = Message(content: messageContent, addedByUser: name!, id: anID!, photo: "", category: category, priority: priority)
                            /* Send message to database reference to update database */
                            let messageRef = self.dbRef.child(id.description)
                            /* Set value of reference content to message content */
                            messageRef.setValue(message.toAnyObject())
                            self.events.append(message)
                        }
                     
                        /* THIS IS THE CLOUDKIT NOTIFICATION */
                        let record = CKRecord(recordType: priority)
                        record.setValue(messageContent, forKey: "Content")
                        record.setValue(name!, forKey: "User")
                        
                        let publicData = CKContainer.default().publicCloudDatabase
                        publicData.save(record, completionHandler: { (rec, error) -> Void in
                            if error == nil {
                            } else {
                                print("DIDNT SAVE")
                                print(error!)
                            }
                        })

                    /*
                    /* This is where a notification will be sent. */
                        self.scheduleNotification(inSeconds: 0.1, name: name!, message: messageContent, completion: { success in
                            if success {
                                print("SUCCESSFULLY SCHEDULED NOTIFICATION")
                            } else {
                                print("ERROR SCHEDULING")
                            }
                        })
                    */
                    })
                })
            }
                /* Otherwise, no one logged in... */
            else {
                let failureAlert = UIAlertController(title: "Message Not Sent", message: "Log In First", preferredStyle: .alert)
                failureAlert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action:UIAlertAction) in
                }))
                /* Present to view controller */
                self.present(failureAlert, animated: true, completion: nil)
            }
        })
    }
    
    
    /*
     * This function is called when you press the menu button, allows user to sign up
     */
    @IBAction func signIn(_ sender: Any) {
        /* Create an alert that allows the user to sign in */
        let userAlert = UIAlertController(title: "Sign In", message: "", preferredStyle: .alert)
        /* Three textfields that allow for an email, username and password */
        userAlert.addTextField { (textfield:UITextField) in
            textfield.placeholder = "Email"
        }
        userAlert.addTextField { (textfield:UITextField) in
            textfield.placeholder = "Username"
        }
        userAlert.addTextField { (textfield:UITextField) in
            textfield.isSecureTextEntry = true
            textfield.placeholder = "Password (At least 6 characters long)"
        }
        
        
        /*  The first possible option is to log in */
        userAlert.addAction(UIAlertAction(title: "Sign In", style: .default, handler: { (action:UIAlertAction) in
            let emailTextField = userAlert.textFields!.first!
            let passwordtextField = userAlert.textFields!.last!
            
            /* Sign them into Firebase */
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordtextField.text!, completion: { (User, Error) in
                if Error != nil {
                    /* Then the log in failed, let them know they failed with an alert*/
                    let failureAlert = UIAlertController(title: "Log In Failed", message: "Sucks", preferredStyle: .alert)
                    failureAlert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action:UIAlertAction) in
                    }))
                    /* Present to view controller */
                    self.present(failureAlert, animated: true, completion: nil)
                } else {
                    /* Then the log in succeeded, let them know they succeeded with an alert */
                    let successAlert = UIAlertController(title: "Log In Success", message: "Welcome", preferredStyle: .alert)
                    successAlert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action:UIAlertAction) in
                    }))
                    
                    /* Present to view controller */
                    self.present(successAlert, animated: true, completion: nil)
                }
            })
        }))
        
        
        /* Second option is to register */
        userAlert.addAction(UIAlertAction(title: "Register", style: .default, handler: { (action:UIAlertAction) in
            let emailTextField = userAlert.textFields!.first!
            let nameTextField = userAlert.textFields![1]
            let passwordtextField = userAlert.textFields!.last!
            
            /* Register them in Firebase */
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordtextField.text!, completion: { (User, Error) in
                if Error != nil {
                    /* Then the registration failed, let them know they failed with an alert*/
                    let failureAlert = UIAlertController(title: "Registration Failed", message: "Sucks", preferredStyle: .alert)
                    failureAlert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action:UIAlertAction) in
                    }))
                    /* Present to view controller */
                    self.present(failureAlert, animated: true, completion: nil)
                } else {
                    /* We need to give each message an id before sending */
                    self.userCount.observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        /* Get the data snapshot in order to give the message an ID */
                        let value = snapshot.value as? NSString
                        var anID = value?.integerValue
                        anID = anID! + 1
                        self.userCount.setValue("\(anID!)")
                        
                        /* Create the user */
                        let theUser = SilcUser(name: nameTextField.text!, email: emailTextField.text!, id: "\(anID!)")
                        
                        /* Send message to database reference to update database */
                        let userRef = self.users.child("\(Auth.auth().currentUser!.uid)")
                        /* Set value of reference content to message content */
                        userRef.setValue(theUser.toAnyObject())
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        changeRequest?.displayName = nameTextField.text
                        changeRequest?.commitChanges(completion: { (error) in
                            // ...
                        })
                        
                        /* Then the registration succeeded, let them know they succeeded with an alert */
                        let successAlert = UIAlertController(title: "Welcome", message: "Register Complete", preferredStyle: .alert)
                        successAlert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action:UIAlertAction) in
                        }))
                        
                        /* Present to view controller */
                        self.present(successAlert, animated: true, completion: nil)
                    })
                }
            })
            
        }))
        
        
        /* Third option is to cancel the alert and do nothing*/
        userAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action:UIAlertAction) in
        }))
        
        
        /* Present alert to view controller */
        self.present(userAlert, animated: true, completion: nil)
    }
    
    
    /*
    /* This function simply schedules the notification*/
    func scheduleNotification(inSeconds: TimeInterval, name: String, message: String, completion: @escaping (_ Success: Bool) -> ()) {
        if #available(iOS 10.0, *) {
            let notif = UNMutableNotificationContent()
            notif.title = name
            notif.body = message
            
            let notifTrigger = UNTimeIntervalNotificationTrigger(timeInterval: inSeconds, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: notif, trigger: notifTrigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                if error != nil {
                    print(error ?? "")
                    completion(false)
                } else {
                    completion(true)
                }
            })
        } else {
            // Fallback on earlier versions
        }
    }
     */
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    
    /* 
     * Allows us to configure each cell individually
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        /* Generate the cell, index path is location in table */
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! PikeCell
        
        /* If there are no events, just return */
        if events.count == 0 {
            return cell
        }
        
        /* Otherwise, generate message */
        let message = events[indexPath.row]
        
        /* Set the message content and user info */
        cell.message?.text = message.content
        self.users.child(message.addedByUser).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let name = value?["name"] as? String
            cell.name?.text = name
        })
        cell.category?.text = message.category
        
        if (message.photo != nil) {
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: OperationQueue.main)
            let urlString = message.photo
            let url = NSURL(string: urlString!)
            let request = NSURLRequest(url: url! as URL)
            
            if (UserDefaults.standard.object(forKey: "petpic") != nil && cell.name.text == "Mylo"){
                let loadedImg = UserDefaults.standard.object(forKey: "petpic") as! NSData
                let image = UIImage(data: loadedImg as Data)!
                cell.photo.image = image
                cell.photo.layer.cornerRadius = 10.0
                cell.photo.layer.borderColor = UIColor.white.cgColor
                cell.photo.layer.masksToBounds = true
            } else if (UserDefaults.standard.object(forKey: "propic") != nil && cell.name.text != "Mylo") {
                let loadedImg = UserDefaults.standard.object(forKey: "propic") as! NSData
                let image = UIImage(data: loadedImg as Data)!
                cell.photo.image = image
                cell.photo.layer.cornerRadius = 10.0
                cell.photo.layer.borderColor = UIColor.white.cgColor
                cell.photo.layer.masksToBounds = true
            }
        }
        cell.layoutSubviews()
        
        return cell
    }
    
    
    
    
    /* This is what happens when you click on a cell */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        /* Instantiate the view controller */
        if let details = sb.instantiateViewController(withIdentifier: "DetailObject") as? MessageDetail {
            
            /* Grab message from cell */
            let message = self.events[indexPath.row]
            
            /* Instantiate message details */
            details.nameIn = message.addedByUser
            details.contentIn = message.content
            details.categoryIn = message.category
            details.priorityIn = message.priority
            
                if (message.photo != nil) {
                    print("message.photo is not nil")
                    if (UserDefaults.standard.object(forKey: "propic") != nil && message.category != "Pet Response"){
                        let loadedImg = UserDefaults.standard.object(forKey: "propic") as! NSData
                        let propicimg = UIImage(data: loadedImg as Data)!
                        details.photoIn = propicimg
                    } else if (UserDefaults.standard.object(forKey: "petpic") != nil && message.category == "Pet Response") {
                        let loadedImg = UserDefaults.standard.object(forKey: "petpic") as! NSData
                        let petpicimg = UIImage(data: loadedImg as Data)!
                        details.photoIn = petpicimg
                    }
                }
            
            /* Present the detail object */
            self.present(details, animated: true, completion: nil)
        }
    }
    
    
    /* 
     * This function enables delete capacity 
     */
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        self.users.child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let type = value?["type"] as? String
            if (type! == "Premium") {
                /* Editing style is the left swipe */
                if editingStyle == .delete {
                    /* Grab the message from the indexPath */
                    let message = self.events[indexPath.row]
                    /* Remove the value from the database */
                    message.itemRef?.removeValue()
                }
            } else {
                if editingStyle == .delete {
                    /* Grab the message from the indexPath */
                    let message = self.events[indexPath.row]
                    let ourID = Auth.auth().currentUser!.uid
                    let messageID = message.addedByUser
                    
                    if (ourID == messageID) {
                        /* Remove the value from the database */
                        message.itemRef?.removeValue()
                    } else {
                        /* Alert user deletion can't be completed */
                        let successAlert = UIAlertController(title: "Delete Failed", message: "Only have permission to delete your own messages", preferredStyle: .alert)
                        successAlert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action:UIAlertAction) in
                        }))
                        
                        /* Present to view controller */
                        self.present(successAlert, animated: true, completion: nil)
                    }
                }
            }
        })
    }
}
