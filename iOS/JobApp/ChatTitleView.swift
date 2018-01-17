//
//  ChatTitleView.swift
//  JobApp
//
//  Created by JaonMicle on 18/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import SDWebImage

class ChatTitleView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    public func initView(photourl: String!, name: String!){
        let photoView: ExtentionImageView = ExtentionImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        photoView.cornerRadius = 20.0;
        photoView.borderColor = UIColor.gray
        photoView.borderWidth = 1.0;
        if photourl != nil{
            if let url = URL(string: photourl){
                photoView.sd_setImage(with:url, placeholderImage: UIImage(named: "profilemain"))
            }
        }
        let nameLabel: UILabel = UILabel(frame: CGRect(x: 50, y: 0, width: 150, height: 40))
        nameLabel.textColor = UIColor.gray
        nameLabel.font = UIFont.boldSystemFont(ofSize: 17)
        nameLabel.text = name;
        self.addSubview(photoView)
        self.addSubview(nameLabel)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
