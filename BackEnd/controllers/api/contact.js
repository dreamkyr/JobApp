var mongoose = require("mongoose");
var Contact = require("../../models/contact.js");
var User = require("../../models/user");
var common = require("../../app/common.js");

var constants = require('../../app/constants');
var mqtt = require('mqtt');

exports.addContact = function(req, res){

    if(req.body.contact_user==undefined){
        common.sendMessage(res, 1, "contact_user is undefined.");
    }else{
        var user_id = req.user._id;
        var contact_user = req.body.contact_user;
        Contact.findOne({user_id: user_id, contact_user: contact_user}, function(err, contact){
            if(err){
                common.sendMessage(res, 2, "Error while add contact.")
            }else{
                if(contact){
                    common.sendMessage(res, 3, "This user was already added.");
                }else{
                    Contact.find().lean().sort([["_id", "descending"]]).limit(1).exec(function(err, contacts){
                        if(err){
                            common.sendMessage(res, 5, err);
                        }else{
                            let _id = (contacts.length>0) ? contacts[0]._id+1 : 0
                            let myContact = new Contact({
                                _id: _id,
                                user_id: user_id,
                                contact_user: contact_user,
                                status: 1
                            });
                            let linkedContact = new Contact({
                                _id: _id+1,
                                user_id: contact_user,
                                contact_user: user_id,
                                status: 2
                            });
                            myContact.save(function(err){
                                if(err){
                                    common.sendMessage(res, 6, err);
                                }else{
                                    linkedContact.save(function(err){
                                        var mqtt_client = mqtt.connect("mqtt://localhost:" + constants.mqtt_notification_server);
                                        let topic = constants.mqtt_notification_prefix + contact_user;
                                        let message = {
                                            type: constants.notification_type.contact,
                                        	content: req.user.full_name  + " has added you to his contacts."
                                        }
                                        mqtt_client.publish(topic, JSON.stringify(message));
                                        mqtt_client.end();
                                        common.sendMessage(res, 200, "Successfully added.");
                                    });
                                }
                            });
                        }
                    });
                }
            }
        });
    }
}
exports.agree = function(req, res){

    if(req.body.contact_user==undefined){
        common.sendMessage(res, 1, "contact_user  is undefined.");
    }else{
        var user_id = req.user._id;
        var contact_user = req.body.contact_user;
        Contact.findOne({user_id: user_id, contact_user: contact_user, status: 2}, function(err, myContact){
            if(err || !myContact){
                common.sendMessage(res, 2, "Bad Request.")
            }else{
                Contact.findOne({user_id: contact_user, contact_user: user_id, status: 1}, function(err, linkedContact){
                    if(err || !linkedContact){
                        common.sendMessage(res, 3, "Bad Request.");
                    }else{
                        if(err){
                            common.sendMessage(res, 4, err);
                        }else{
                            myContact.status = 0;
                            linkedContact.status = 0;
                            Contact.update({_id: myContact._id}, myContact, {upsert: true}, function(err, doc){
                                if(err){
                                    common.sendMessage(res, 5, err);
                                }else{
                                    Contact.update({_id: linkedContact._id}, linkedContact, {upsert: true}, function(err, doc){
                                        var mqtt_client = mqtt.connect("mqtt://localhost:" + constants.mqtt_notification_server);
                                        let topic = constants.mqtt_notification_prefix + contact_user;
                                        let message = {
                                            type: constants.notification_type.contact,
                                        	content: req.user.full_name  + " has added you to his contacts."
                                        }
                                        mqtt_client.publish(topic, JSON.stringify(message));
                                        mqtt_client.end();
                                        common.sendMessage(res, 200, "Successfully added.");
                                    });
                                }
                            });
                        }
                    }
                });
            }
        });
    }
}
exports.remove = function(req, res){
    if(req.body.contact_user==undefined){
        common.sendMessage(res, 1, "contact_user is undefined.");
    }else{
        var user_id = req.user._id;
        var contact_user = req.body.contact_user;
        Contact.findOne({user_id: user_id, contact_user: contact_user}, function(err, myContact){
            if(err || !myContact){
                common.sendMessage(res, 2, "Bad Request.")
            }else{
                Contact.findOne({user_id: contact_user, contact_user: user_id}, function(err, linkedContact){
                    if(err || !linkedContact){
                        common.sendMessage(res, 3, "Bad Request.");
                    }else{
                        if(err){
                            common.sendMessage(res, 4, err);
                        }else{
                            if(myContact.status==0){
                                myContact.status = 2;
                                linkedContact.status = 1;
                                Contact.update({_id: myContact._id}, myContact, {upsert: true}, function(err, doc){
                                    if(err){
                                        common.sendMessage(res, 5, err);
                                    }else{
                                        Contact.update({_id: linkedContact._id}, linkedContact, {upsert: true}, function(err, doc){
                                            common.sendMessage(res, 200, "Successfully added.");
                                        });
                                    }
                                });
                            }else{
                                myContact.remove(function(err, doc){});
                                linkedContact.remove(function(err, doc){});
                                common.sendMessage(res, 200, "Successfully added.");
                            }
                        }
                    }
                });
            }
        });
    }
}
function getContact(req, res){
    var user_id = req.user._id;
    Contact.find({user_id: user_id}).lean().sort({status: -1}).populate({
    path: 'contact_user',
    match: {
      verified: true 
    }
  }).exec(function(err, contacts){
        if(err){
            common.sendMessage(res, 1, err);
        }else{
            common.sendData(res, contacts.filter(function(x){ return x.contact_user != null }) );
        }
    });
}
exports.get = function(req, res){
    getContact(req, res);
}
exports.getFavorite = function(req, res){

    var user_id = req.user._id;
    Contact.find({user_id: user_id, favorite: true}).lean().sort([["status", "ascending"]]).populate("contact_user").exec(function(err, contacts){
        if(err){
            common.sendMessage(res, 2, err);
        }else{
            var result = new Array();
            contacts.forEach(function(contact){
                result.push(contact.user_id);
            });
            common.sendData(res, result);
        }
    });
}
exports.share = function(req, res){
    console.log(req.body);
    var user_id = req.body.user_id, isShared = req.body.isShared;
    if(user_id==undefined || isShared==undefined){
        common.sendMessage(res, 1, "user_id or isShared is undefined.");
        return;
    }

    Contact.update({user_id: req.user._id, contact_user: user_id}, {isShared: isShared}, { upsert: true}, function(err, doc){
        if(err){
            common.sendMessage(res, 3, err);
        }else{
            common.sendMessage(res, 200, "Successfully.");
        }
    });
}
