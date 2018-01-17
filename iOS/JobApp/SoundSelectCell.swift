//
//  SoundSelectCell.swift
//  JobApp
//
//  Created by Admin on 5/24/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class SoundSelectCell: UITableViewCell {

    @IBOutlet weak var soundNameLabel: UILabel!
    @IBOutlet weak var checkIconView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}
