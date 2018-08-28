//
//  EventCreator.swift
//
//  Created by Devin Lee on 12/29/16.
//  Copyright © 2016 Devin Lee. All rights reserved.
//

import UIKit

protocol DateDelegate {
    func receivePayload(info: String, day: String, month: String, location: String)
}

class EventCreator: UIViewController {

    @IBOutlet var eventDetails: UITextView!
    @IBOutlet var eventTime: UIDatePicker!
    @IBOutlet var location: UITextField!
    
    var theDelegate: DateDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.eventDetails.endEditing(true)
    }

    @IBAction func createEvent(_ sender: Any) {
        if theDelegate != nil {
            let info = eventDetails.text
            let time = eventTime.date

            let formMonth = DateFormatter()
            let formDay = DateFormatter()
            
            formMonth.dateFormat = "MM"
            formDay.dateFormat = "dd"
            
            let day = formDay.string(from: time)
            let month = formMonth.string(from: time)
            
            let location = self.location.text
            
            theDelegate.receivePayload(info: info!, day: day, month: month, location: location!)
        }
    }
}
