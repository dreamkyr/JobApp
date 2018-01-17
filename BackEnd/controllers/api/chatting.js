var mongoose = require("mongoose");
var Chatting = require("../../models/chatting.js");
var common = require("../../app/common.js");

exports.get = function(req, res){

    if(req.body.user_id==undefined){
        common.sendMessage(res, 1, "sender is undefined.");
        return;
    }
    Chatting.find({ $or: [{reciever: req.user._id, sender: req.body.user_id}, {reciever: req.body.user_id, sender: req.user._id}] })
    .lean().sort([['_id', 'descending']]).limit(50)
    .exec(function(err, notifications){
        if(err){
            common.sendMessage(res, 1, err);
        }else{
            common.sendData(res, notifications.reverse());
        }
    });
}
exports.getBefor = function(req, res){

    if(req.body._id==undefined || req.body.user_id==undefined){
        common.sendMessage(res, 1, "_id or user_id is undefined.");
        return;
    }
    Chatting.find({ _id: { "$lt": req.body._id }, $or: [{reciever: req.user._id, sender: req.body.user_id}, {reciever: req.body.user_id, sender: req.user._id}]})
    .lean().sort([['_id', 'ascending']]).limit(50)
    .exec(function(err, notifications){
        if(err){
            common.sendMessage(res, 1, err);
        }else{
            common.sendData(res, notifications);
        }
    });
}
exports.read = function(req, res){

    if(req.body.user_id==undefined){
        common.sendMessage(res, 1, "user_id is undefined.");
        return;
    }
    Chatting.update({ $or: [{sender: req.body.user_id}, {reciever: req.body.user_id}], isRead: false}, {isRead: true}, {multi: true},
        function(err, num) {
            if(err){
                common.sendMessage(res, 1, err);
            }else{
                common.sendMessage(res, 200, "Success");
            }
        }
    );
}
