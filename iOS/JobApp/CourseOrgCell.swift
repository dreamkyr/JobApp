//
//  CourseOrgCell.swift
//  JobApp
//
//  Created by JaonMicle on 04/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class CourseOrgCell: UITableViewCell {
    
    @IBOutlet weak var courseTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    public var removeCallBack: ((_ index: [Int])->Void)! = nil
    public var indexnum: [Int] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func removeCourseOrg(_ sender: UIButton) {
        self.removeCallBack(self.indexnum);
    }
    

}
