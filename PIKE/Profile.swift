//
//  Profile.swift
//
//  Created by Devin Lee on 12/7/16.
//  Copyright © 2016 Devin Lee. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class Profile: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    /* Reference to users */
    var users: DatabaseReference!
    /* A database reference */
    var dbRef: DatabaseReference!
    /* A database storage reference */
    var sRef: StorageReference!
    
    var imagePicker = UIImagePickerController()
    
    @IBOutlet var priorityLevel: UILabel!
    @IBOutlet var email: UILabel!
    @IBOutlet var username: UILabel!
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var accountType: UILabel!
    @IBOutlet var imageLoader: UIActivityIndicatorView!
    @IBOutlet var points: UILabel!
    @IBOutlet var homeAddress: UILabel!
    
    @IBOutlet var age: UILabel!
    @IBOutlet var sex: UILabel!
    @IBOutlet var major: UILabel!
    @IBOutlet var grade: UILabel!
    @IBOutlet var position: UILabel!
    @IBOutlet var birthday: UILabel!

    
    
    /*
     * Load function
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Initialize database reference (Sets to child for better access of items */
        dbRef = Database.database().reference().child("messages")
        users = Database.database().reference().child("users")
        sRef = Storage.storage().reference()
        
        //self.imageLoader.stopAnimating()
        self.imageLoader.startAnimating()
        /* Load user information */
        loadUserData()
    }
    
    
    /*
     * Check if authentication state changes before displaying data
     */
    override func viewDidAppear(_ animated: Bool) {
        /* Call from the super class */
        super.viewDidAppear(animated)
        
        /* Loads user information */
        loadUserData()
    }
    
    
    /* Updates User Information */
    func loadUserData() {
        /* Now we need to get user info */
        let user = Auth.auth().currentUser
        
        Auth.auth().addStateDidChangeListener({ (Auth, User) in
            /* If someone is logged in, load data */
            if Auth.currentUser != nil /* let user = FIRAuth.auth()!.currentUser */ {
                self.users.child(Auth.currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    
                    
                    if (value?["profilePic"] != nil) {
                        let sessionConfig = URLSessionConfiguration.default
                        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: OperationQueue.main)
                        let urlString = value!["profilePic"] as? String
                        let url = NSURL(string: urlString!)
                        let request = NSURLRequest(url: url! as URL)
                        
                        print("PRELOADING")
                        print(urlString!)
                        let islandRef = Storage.storage().reference(forURL: urlString!)

                        if (UserDefaults.standard.object(forKey: "propic") != nil ){
                            let loadedImg = UserDefaults.standard.object(forKey: "propic") as! NSData
                            self.setProfilePicture(imageView: self.profilePic, imageToSet: UIImage(data: loadedImg as Data)!)
                            self.imageLoader.stopAnimating()
                        }
                    }
                    
                    if (value?["name"] != nil) {
                        self.username.text = value!["name"] as? String
                    }
                    if (value?["email"] != nil) {
                        self.email.text = value!["email"] as? String
                    }
                    if (value?["type"] != nil) {
                        self.accountType.text = value!["type"] as? String
                    }
                    if (value?["priority"] != nil) {
                        self.priorityLevel.text = value!["priority"] as? String
                    }
                    if (value?["points"] != nil) {
                        self.points.text = value!["points"] as? String
                    }
                    if (value?["homeAddress"] != nil) {
                        self.homeAddress.text = value!["homeAddress"] as? String
                    }
                    
                    if (value?["Age"] != nil) {
                        self.age.text = value!["Age"] as? String
                    }
                    if (value?["Sex"] != nil) {
                        self.sex.text = value!["Sex"] as? String
                    }
                    if (value?["Major"] != nil) {
                        self.major.text = value!["Major"] as? String
                    }
                    if (value?["Grade"] != nil) {
                        self.grade.text = value!["Grade"] as? String
                    }
                    if (value?["Position"] != nil) {
                        self.position.text = value!["Position"] as? String
                    }
                    if (value?["Birthday"] != nil) {
                        self.birthday.text = value!["Birthday"] as? String
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
    
    
    
    
    /* Enables a user to change their user name*/
    @IBAction func changeName(_ sender: Any) {
        Auth.auth().addStateDidChangeListener({ (Auth, User) in
            /* If someone is logged in, load data */
            if Auth.currentUser != nil /* let user = FIRAuth.auth()!.currentUser */ {
        /* Generate an alert notice to add the  message */
        let alert = UIAlertController(title: "Enter your new username", message: "", preferredStyle: .alert)
        /* Generate a textfield within the event, along with a placeholder value */
        alert.addTextField { (textField:UITextField) -> Void in
            textField.placeholder = "New Name"
        }
        
        /* Add a cancel button that simply cancels the alert */
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        /* Add confirm button that submits the message */
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action:UIAlertAction) in
            
            if let messageContent = alert.textFields?.first?.text {
                let changeRequest = Auth.currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = messageContent
                self.users.child(Auth.currentUser!.uid).child("name").setValue(messageContent)
                changeRequest?.commitChanges(completion: { (error) in
                    if error != nil {
                        print("NAME CHANGE MESSED UP")
                    } else {
                        /* Loads user information */
                        self.loadUserData()
                    }
                
                })
            }
        }))
        
        /* Display */
        self.present(alert, animated: true, completion: nil)
            } else {
                
            }
        })
    }
    
    

    /* Enables a user to change their email address */
    @IBAction func changeEmail(_ sender: Any) {
        Auth.auth().addStateDidChangeListener({ (Auth, User) in
            /* If someone is logged in, load data */
            if Auth.currentUser != nil /* let user = FIRAuth.auth()!.currentUser */ {
        /* Generate an alert notice to add the  message */
        let alert = UIAlertController(title: "Enter your new email", message: "", preferredStyle: .alert)
        /* Generate a textfield within the event, along with a placeholder value */
        alert.addTextField { (textField:UITextField) -> Void in
            textField.placeholder = "Old Email"
        }
        /* Generate a textfield within the event, along with a placeholder value */
        alert.addTextField { (textField:UITextField) -> Void in
            textField.placeholder = "New Email"
        }
        /* Generate a textfield within the event, along with a placeholder value */
        alert.addTextField { (textField:UITextField) -> Void in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        /* Add a cancel button that simply cancels the alert */
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        /* Add confirm button that submits the message */
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action:UIAlertAction) in
        }))
        
        /* Display */
        self.present(alert, animated: true, completion: nil)
            } else {
                
            }
        })
    }
    
    internal func setProfilePicture(imageView: UIImageView, imageToSet: UIImage) {
        imageView.layer.borderWidth = 1
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        imageView.image = imageToSet
    }
    
    /* Enables a user to change their profile picture*/
    @IBAction func changePicture(_ sender: Any) {
        Auth.auth().addStateDidChangeListener({ (Auth, User) in
            /* If someone is logged in, load data */
            if Auth.currentUser != nil /* let user = FIRAuth.auth()!.currentUser */ {
        /* Create action sheet */
        let myActionSheet = UIAlertController(title: "Profile Picture", message: "Select", preferredStyle: .actionSheet)
        
        /* First option simply views full screen version of picture */
        let viewPicture = UIAlertAction(title: "View Picture", style: .default) { (action) in
            let newImageView = UIImageView(image: self.profilePic.image)
            
            newImageView.frame = self.view.frame
            newImageView.backgroundColor = UIColor.black
            newImageView.contentMode = .scaleAspectFit
            newImageView.isUserInteractionEnabled = true
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissFullScreenImage))
            
            newImageView.addGestureRecognizer(tap)
            self.view.addSubview(newImageView)
        }
                
        /* Second option allows them to select a photo from their saved photos */
        let photoGallery = UIAlertAction(title: "Photos", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        
        /* Third option allows them to access the camera */
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        
        myActionSheet.addAction(viewPicture)
        myActionSheet.addAction(photoGallery)
        myActionSheet.addAction(camera)
        
        /* Fourth option cancels */
        myActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(myActionSheet, animated: true, completion: nil)
            } else {
                
            }
        })
    }
    
    
    @objc func dismissFullScreenImage(sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
    
    
    /* This function is called after a user selects their photo from their library */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.imageLoader.startAnimating()
        
        var itemID = 0
        let picCount = Database.database().reference().child("pictureCount")
        
        /* We need to give each message an id before sending */
        picCount.observeSingleEvent(of: .value, with: { (snapshot) in
            
            /* Get the data snapshot in order to give the message an ID */
            let value = snapshot.value as? NSString
            let anID = value?.integerValue
            itemID = anID! + 1
            picCount.setValue("\(itemID)")
            
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.setProfilePicture(imageView: self.profilePic, imageToSet: image)
            
            // Create a root reference
            let storageRef = self.sRef
            
            // Create a reference to "mountains.jpg"
            let mountainsRef = storageRef?.child("mountains.jpg")
            
            // Create a reference to 'images/mountains.jpg'
            let mountainImagesRef = storageRef?.child("images/mountains.jpg")
            
            // While the file names are the same, the references point to different files
            mountainsRef?.name == mountainImagesRef?.name;            // true
            mountainsRef?.fullPath == mountainImagesRef?.fullPath;    // false
            
            
            // Data in memory
            let imageData: NSData = (UIImagePNGRepresentation(self.profilePic.image!)! as NSData?)!
            
            // Create a reference to the file you want to upload
            let riversRef = storageRef?.child("users/\(itemID)/\(Auth.auth().currentUser!.uid)")
            print(riversRef?.fullPath)
            self.users.child(Auth.auth().currentUser!.uid).child("profilePic").setValue("gs://silcfetch.appspot.com/" + (riversRef?.fullPath)!)
            self.imageLoader.stopAnimating()
            // Upload the file to the path "images/rivers.jpg"
            let uploadTask = riversRef?.putData(imageData as Data, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }

            }
            UserDefaults.standard.set(imageData, forKey: "propic")
            
        self.dismiss(animated: true, completion: nil)
        })
    }
    
    
    @IBAction func changePriority(_ sender: Any) {
        Auth.auth().addStateDidChangeListener({ (Auth, User) in
            /* If someone is logged in, load data */
            if Auth.currentUser != nil /* let user = FIRAuth.auth()!.currentUser */ {
        /* Generate an alert notice to add the  message */
        let alert = UIAlertController(title: "Select A Priority Level", message: "", preferredStyle: .alert)
        
        /* Add a cancel button that simply cancels the alert */
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        /* Add confirm button that submits the message */
        alert.addAction(UIAlertAction(title: "Normal (Receive All Notifications)", style: .default, handler: { (action:UIAlertAction) in
            self.users.child(Auth.currentUser!.uid).child("priority").setValue("Normal")
            self.loadUserData()
        }))
        
        /* Add confirm button that submits the message */
        alert.addAction(UIAlertAction(title: "Social (Ignore Normal Announcements)", style: .default, handler: { (action:UIAlertAction) in
            self.users.child(Auth.currentUser!.uid).child("priority").setValue("Social")
            self.loadUserData()
        }))
        
        /* Add confirm button that submits the message */
        alert.addAction(UIAlertAction(title: "Official (Ignore Normal & Social)", style: .default, handler: { (action:UIAlertAction) in
            self.users.child(Auth.currentUser!.uid).child("priority").setValue("Official")
            self.loadUserData()
        }))
        
        /* Add confirm button that submits the message */
        alert.addAction(UIAlertAction(title: "Important (Ignore Normal, Social & Official)", style: .default, handler: { (action:UIAlertAction) in
            self.users.child(Auth.currentUser!.uid).child("priority").setValue("Important")
            self.loadUserData()
        }))
        
        /* Display */
        self.present(alert, animated: true, completion: nil)
            } else {
                
            }
        })
    }
    
}
