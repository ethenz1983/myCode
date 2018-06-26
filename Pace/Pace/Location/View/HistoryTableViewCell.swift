//
//  HistoryTableViewCell.swift
//  Pace
//
//  Created by ethan on 2018/6/26.
//  Copyright © 2018年 ethan. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet var timeLabel: UILabel?
    @IBOutlet var scoreLabel: UILabel?
    @IBOutlet var distanceLabel: UILabel?
    @IBOutlet var timecostLabel: UILabel?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
