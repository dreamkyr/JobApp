//
//  CourseOrgViewCell.swift
//  JobApp
//
//  Created by JaonMicle on 28/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class CourseOrgViewCell: UITableViewCell {

    @IBOutlet weak var couorgNameText: UILabel!
    @IBOutlet weak var majorText: UILabel!
    @IBOutlet weak var dateText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
