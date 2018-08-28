//
//  Register.swift
//
//  Created by Devin Lee on 6/14/18.
//  Copyright © 2018 Devin Lee. All rights reserved.
//

import UIKit

class Register: UIViewController {

    @IBOutlet var address: UITextField!
    @IBOutlet var carrier: UITextField!
    @IBOutlet var phone: UITextField!
    @IBOutlet var name: UITextField!
    @IBOutlet var email: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.address.endEditing(true)
        self.carrier.endEditing(true)
        self.phone.endEditing(true)
        self.name.endEditing(true)
        self.email.endEditing(true)
    }

}
