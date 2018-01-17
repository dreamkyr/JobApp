//
//  SkillCell.swift
//  JobApp
//
//  Created by Admin on 5/22/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class SelectCell: UITableViewCell {

    @IBOutlet weak var selTitle: UILabel!
    @IBOutlet weak var selImg: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
