//
//  timerTableViewCell.swift
//  timer
//
//  Created by Valerii Petrychenko on 08.02.2020.
//  Copyright © 2020 Valerii Petrychenko. All rights reserved.
//

import UIKit

class timerTableViewCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(time: String, info: String) {
        timeLabel.text = time
        infoLabel.text = info
    }
}
