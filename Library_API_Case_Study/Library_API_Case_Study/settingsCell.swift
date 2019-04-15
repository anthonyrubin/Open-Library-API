//
//  settingsCellTableViewCell.swift
//  Library_API_Case_Study
//
//  Created by Anthony Rubin on 4/14/19.
//  Copyright © 2019 Anthony Rubin. All rights reserved.
//

import UIKit

class settingsCell: UITableViewCell {


    @IBOutlet weak var wordLabel: UILabel!
    var switchChanged: (Bool) -> () = {  _ in }
    
    
    @IBOutlet weak var wordGroupSwitch: UISwitch!
    
    @IBAction func switchValueChanged( _ switch: UISwitch) {
        switchChanged(`switch`.isOn)
    
    }
    
}
