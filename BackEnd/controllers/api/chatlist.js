var mongoose = require("mongoose");
var ChatList = require("../../models/chatlist.js");
var User = require("../../models/user");
var common = require("../../app/common.js");

function filterChatList(chatlist){
    let last_time = chatlist.last_time.toISOString();
    chatlist.last_time = last_time.substring(0, last_time.indexOf("T")+6).replace("T", " ");
    return chatlist;
}
function filterChatLists(chatlists){
    chatlists.forEach(function(current, index, array){
        chatlists[index] = filterChatList(current);
    })
    return chatlists;
}

function getChatList(res, user_id){
    ChatList.find({user_id: user_id}).lean().sort({last_time: -1}).populate("linked_user","-password").exec(function(err, allchatlists){
        if(err){
            res.status(401)
            common.sendMessage(res, 4, err);
        }else{
            common.sendData(res, filterChatLists(allchatlists));
        }
    });
}
exports.add = function(req, res){

    var user_id = req.user._id;
    var linked_users = req.body.linked_users;
    if(linked_users==undefined){
        common.sendMessage(res, 1, "linked_users is undefined.");
        return;
    }
    if(linked_users.length==0 || linked_users.length==undefined){
        getChatList(res, user_id);
        return;
    }
    var ct = 0;
    ChatList.find({user_id: user_id, linked_user: {$in: linked_users}}).distinct("linked_user", function(err, chatlists){
        if(chatlists!=undefined){
            chatlists.forEach(function(current, index, array){
                linked_users.remove(current);
            });
        }
        ChatList.find({}).lean().sort([["_id", "descending"]]).limit(1).exec(function(err, chatlists){
            let _id = (chatlists.length>0) ? chatlists[0]._id+1 : 0
            var ct = 0;
            if(linked_users.length==0){
                getChatList(res, user_id);
            }else{
                linked_users.forEach(function(current, index, array){
                    let chatlist = new ChatList({
                        _id: _id + index,
                        user_id: user_id,
                        linked_user: current,
                    });
                    chatlist.save(function(err){
                        if((++ct)==linked_users.length){
                            getChatList(res, user_id);
                        }
                    });
                });
            }
        });
    });
}

exports.remove = function(req, res){

    if(req.body.delete_ids==undefined){
        common.sendMessage(res, 1, "delete_ids is undefined.");
        return;
    }
    if(req.body.delete_ids.length==0 || req.body.delete_ids.length==undefined){
        common.sendMessage(res, 2, "delete_ids is empty.");
        return;
    }
    ChatList.find({_id: {$in: req.body.delete_ids}}, function(err, chatlists){
        if(err || !chatlists){
            common.sendData(res, "Successfully removed.");
        }else{
            var ct = 0;
            chatlists.forEach(function(current, index, array){
                current.remove(function(err, doc){
                    if((++ct)==chatlists.length){
                        common.sendMessage(res, 200, "Successfully removed.");
                    }
                });
            });
        }
    });
}

exports.get = function(req, res){

    var user_id = req.user._id;
    ChatList.find({user_id: user_id}).lean().sort({last_time: -1}).populate("linked_user","-password").exec(function(err, chatlists){
        if(err){
            common.sendMessage(res, 1, err);
        }else{
            common.sendData(res, filterChatLists(chatlists));
        }
    });
}
