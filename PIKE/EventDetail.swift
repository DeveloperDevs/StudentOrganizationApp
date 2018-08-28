//
//  EventDetail.swift
//
//  Created by Devin Lee on 12/31/16.
//  Copyright © 2016 Devin Lee. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class EventDetail: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var theTable: UITableView!
    @IBOutlet var month: UILabel!
    @IBOutlet var day: UILabel!
    @IBOutlet var location: UILabel!
    @IBOutlet var message: UITextView!
    var id: String?
    
    var dayIn: String?
    var monthIn: String?
    var contentIn: String?
    var locationIn: String?
    var idIn: String?
    
    var items = [Status]()
    /* Reference to events */
    var events: DatabaseReference!
    /* Allows user to slide down to refresh messages */
    var refresh: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Set up refresh variable */
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Refresh")
        refresh.addTarget(self, action: #selector(Feed.loadData), for: .valueChanged)
        theTable.addSubview(refresh)

        
        /* Instantiate message details */
        self.day.text = dayIn
        self.month.text = monthIn
        self.message.text = contentIn
        self.location.text = locationIn
        self.id = idIn
        
        loadData()
        
        self.message.isEditable = false
    }
    
    func loadData() {
        Database.database().reference().child("events").child(id!).child("going").observe(DataEventType.value, with: { (snapshot) in
            /* Array of new items */
            var newMessages = [Status]()
            
            /* Iterate through messages in snapshot*/
            for child in snapshot.children {
                /* Create an object from the message constructor */
                let message = Status(snapshot: child as! DataSnapshot)
                newMessages.append(message)
            }

            self.items = newMessages.sorted(by: {
                $0.status < $1.status
            })
            
            /* Reload data in the table */
            DispatchQueue.main.async {
                /* Reload data in the table */
                self.theTable.reloadData()
            }
            
            /* Stop refreshing */
            self.refresh.endRefreshing()
        })
    }

    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.message.endEditing(true)
    }
    
    @IBAction func going(_ sender: Any) {
        if (id != nil) {
            Database.database().reference().child("events").child(id!).child("going").child(Auth.auth().currentUser!.uid).setValue("Going")
            /* Alert user that action was completed */
            let successAlert = UIAlertController(title: "Confirmed Going", message: "You said you will attend this event", preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action:UIAlertAction) in
             self.loadData()
            }))
            
            /* Present to view controller */
            self.present(successAlert, animated: true, completion: nil)
        }
    }

    @IBAction func notGoing(_ sender: Any) {
        if (id != nil) {
            Database.database().reference().child("events").child(id!).child("going").child(Auth.auth().currentUser!.uid).setValue("Not Going")
            /* Alert user that action was completed */
            let successAlert = UIAlertController(title: "Confirmed Not Going", message: "You said you will not attend this event", preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action:UIAlertAction) in
               self.loadData()
            }))
            
            /* Present to view controller */
            self.present(successAlert, animated: true, completion: nil)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! GoingCell
        
        /* If there are no events, just return */
        if items.count == 0 {
            return cell
        }
        Database.database().reference().child("users").child(items[indexPath.row].name).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let name = value?["name"] as? String
            cell.name.text = name
            cell.status.text = self.items[indexPath.row].status
            
            cell.layoutSubviews()
        })
        return cell
    }
}
