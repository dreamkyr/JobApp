//
//  ChatListCell.swift
//  JobApp
//
//  Created by Admin on 5/25/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import SDWebImage


class ChatListCell: UITableViewCell {

    private var chatlist: ChatList! = nil;
    
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var lastMsgLabel: UILabel!
    @IBOutlet weak var lastChatTimeLabel: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var checkIconImage: UIImageView!
    @IBOutlet weak var notiView: EffectView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setData(params: Any!){
        if params != nil{
            self.chatlist = params as! ChatList
            self.initCell();
        }
    }
    
    public func setNotification(){
        self.notiView.isHidden = false;
    }
    
    public func unSetNotification(){
        self.notiView.isHidden = true;
    }
    
    private func initCell(){
        self.userNameLabel.text = CtrCommon.convertNiltoEmpty(string: self.chatlist.linked_user.first_name, defaultstr: "") + " " + CtrCommon.convertNiltoEmpty(string: self.chatlist.linked_user.first_name, defaultstr: "")
        self.lastMsgLabel.text = CtrCommon.convertNiltoEmpty(string: self.chatlist.last_message, defaultstr: "")
        self.lastChatTimeLabel.text = CtrCommon.convertNiltoEmpty(string: self.chatlist.last_time, defaultstr: "")
        if self.chatlist.linked_user.photo != nil{
            if let url = URL(string: self.chatlist.linked_user.photo){
                self.userPhoto.sd_setImage(with: url, placeholderImage: UIImage(named: "profilemain"))
            }
        }
    }

}
