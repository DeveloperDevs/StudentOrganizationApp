//
//  Calendar.swift
//
//  Created by Devin Lee on 12/24/16.
//  Copyright © 2016 Devin Lee. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import UserNotifications

class Calendar: UITableViewController, DateDelegate {

    /* Array of events held within the Table*/
    var events = [Event]()
    /* Reference to users */
    var users: DatabaseReference!
    /* A database reference */
    var dbRef: DatabaseReference!
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
        dbRef = Database.database().reference().child("events")
        users = Database.database().reference().child("users")
        
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
    func loadData() {
        Auth.auth().addStateDidChangeListener({ (Auth, User) in
            /* If someone is logged in, load data */
            if Auth.currentUser != nil /* let user = FIRAuth.auth()!.currentUser */ {
                /* Listen for new comments in Firebase database */
                self.dbRef.observe(.value, with: { (snapshot:DataSnapshot) in
                    /* Array of new items */
                    var newMessages = [Event]()
                    
                    /* Iterate through messages in snapshot*/
                    for child in snapshot.children {
                        /* Create an object from the message constructor */
                        let message = Event(snapshot: child as! DataSnapshot)
                        newMessages.append(message)
                    }
                    
                    self.events = newMessages
                    
                    /* Reload data in the table */
                    self.tableView.reloadData()
                    
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

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
    }
    
    
    /* This simply initializes the delegate */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DateSegue" {
            
            if let theSender = segue.destination as? EventCreator {
                theSender.theDelegate = self
            }
        }
    }
    
    
    /* This receives information from the textfield in the event creator and adds to calendar */
    func receivePayload(info: String, day: String, month: String, location: String) {
        /* Check auth */
        Auth.auth().addStateDidChangeListener({ (Auth, User) in
            /* If someone is logged in, load data */
            if Auth.currentUser != nil /* let user = FIRAuth.auth()!.currentUser */ {
                /* Now create the actual message*/
                var message = Event(day: day, month: month, content: info, location: location)
                message.setID(id: message.description)
                
                /* Send message to database reference to update database */
                let messageRef = self.dbRef.child(message.description)
                /* Set value of reference content to message content */
                messageRef.setValue(message.toAnyObject())
                self.events.append(message)

            }
                /* Otherwise, no one logged in... */
            else {
                let failureAlert = UIAlertController(title: "Event Not Created", message: "Log In First", preferredStyle: .alert)
                failureAlert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action:UIAlertAction) in
                }))
                /* Present to view controller */
                self.present(failureAlert, animated: true, completion: nil)
            }
        })
    }
    
    
    
    /* Allows configuration of each individual cell */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath) as! CalendarItem

        /* If there are no events, just return */
        if events.count == 0 {
            return cell
        }
        
        /* Otherwise, generate message */
        let message = events[indexPath.row]
        
        /* Set the message content and date info */
        cell.textView.text = message.content
        cell.day.text = message.day
        
        if (message.month! == "01") {
            cell.month.text = "Jan"
        }
        else if (message.month! == "02") {
            cell.month.text = "Feb"
        }
        else if (message.month! == "03") {
            cell.month.text = "Mar"
        }
        else if (message.month! == "04") {
            cell.month.text = "Apr"
        }
        else if (message.month! == "05") {
            cell.month.text = "May"
        }
        else if (message.month! == "06") {
            cell.month.text = "Jun"
        }
        else if (message.month! == "07") {
            cell.month.text = "Jul"
        }
        else if (message.month! == "08") {
            cell.month.text = "Aug"
        }
        else if (message.month! == "09") {
            cell.month.text = "Sep"
        }
        else if (message.month! == "10") {
            cell.month.text = "Oct"
        }
        else if (message.month! == "11") {
            cell.month.text = "Nov"
        }
        else if (message.month! == "12") {
            cell.month.text = "Dec"
        }
        else {
            cell.month.text = "N/A"
        }
        
        cell.layoutSubviews()
        
        return cell
    }
    
    
    /* This is what happens when you click on a cell */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        /* Instantiate the view controller */
        if let details = sb.instantiateViewController(withIdentifier: "EventObject") as? EventDetail {
            
            /* Grab message from cell */
            let message = self.events[indexPath.row]
            
            /* Instantiate message details THIS IS WHERE WE ADD ADDITIONAL STUFF */
            details.dayIn = message.day
            details.contentIn = message.content
            details.locationIn = message.location
            details.idIn = message.id
            
            
            if (message.month! == "01") {
                details.monthIn = "Jan"
            }
            else if (message.month! == "02") {
                details.monthIn = "Feb"
            }
            else if (message.month! == "03") {
                details.monthIn = "Mar"
            }
            else if (message.month! == "04") {
                details.monthIn = "Apr"
            }
            else if (message.month! == "05") {
                details.monthIn = "May"
            }
            else if (message.month! == "06") {
                details.monthIn = "Jun"
            }
            else if (message.month! == "07") {
                details.monthIn = "Jul"
            }
            else if (message.month! == "08") {
                details.monthIn = "Aug"
            }
            else if (message.month! == "09") {
                details.monthIn = "Sep"
            }
            else if (message.month! == "10") {
                details.monthIn = "Oct"
            }
            else if (message.month! == "11") {
                details.monthIn = "Nov"
            }
            else if (message.month! == "12") {
                details.monthIn = "Dec"
            }
            else {
                details.monthIn = "N/A"
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
                    /* Alert user deletion can't be completed */
                    let successAlert = UIAlertController(title: "Delete Failed", message: "Don't have permission to delete calendar events", preferredStyle: .alert)
                    successAlert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action:UIAlertAction) in
                    }))
                    
                    /* Present to view controller */
                    self.present(successAlert, animated: true, completion: nil)
                }
            }
        })
    }

}
