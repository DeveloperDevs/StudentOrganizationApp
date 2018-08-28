//
//  CalendarItem.swift
//
//  Created by Devin Lee on 12/24/16.
//  Copyright © 2016 Devin Lee. All rights reserved.
//

import UIKit

class CalendarItem: UITableViewCell {
    
    @IBOutlet var month: UILabel!
    @IBOutlet var day: UILabel!
    @IBOutlet var textView: UILabel!
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.textView.endEditing(true)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        textView.sizeToFit()
        super.layoutSubviews()
    }
}
