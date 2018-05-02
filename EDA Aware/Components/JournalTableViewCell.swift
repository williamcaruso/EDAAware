//
//  JournalTableViewCell.swift
//  EDA Aware
//
//  Created by William Caruso on 5/1/18.
//  Copyright © 2018 wcaruso. All rights reserved.
//

import UIKit

class JournalTableViewCell: UITableViewCell {

    // Mark: - Outlets
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var edaValueLabel: UILabel!
    @IBOutlet var hrValueLabel: UILabel!
    @IBOutlet var accValueLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
