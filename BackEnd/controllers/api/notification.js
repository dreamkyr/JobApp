var mongoose = require("mongoose");
var Notification = require("../../models/notification.js");
var common = require("../../app/common.js");

exports.get = function(req, res){

    Notification.find( { user_id: req.user._id, isRead: false } ).lean().sort([['_id', 'descending']]).exec(function(err, notifications){
        if(err){
            common.sendMessage(res, 1, err);
        }else{
            Notification.update({ user_id: req.user._id, isRead: false }, {isRead: true}, {multi: true},
                function(err, num) {
                    if(err){
                        common.sendMessage(res, 1, err);
                    }else{
                        common.sendData(res, notifications);
                    }
                }
            );
        }
    });
}
exports.read = function(req, res){

    if(req.body.type==undefined){
        common.sendMessage(res, 1, "_id is undefined.");
        return;
    }
    Notification.update({type: req.body.type, isRead: false}, {isRead: true}, {multi: true},
        function(err, num) {
            if(err){
                common.sendMessage(res, 1, err);
            }else{
                common.sendMessage(res, 200, "Success");
            }
        }
    );
}
