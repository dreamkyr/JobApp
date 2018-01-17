var common = require("../../app/common");
var User = require('../../models/user');
var Skill = require('../../models/skill');
var Contact = require("../../models/contact.js");
var ChatList = require("../../models/chatlist.js");
var mailer = require('express-mailer');
var constants = require('../../app/constants');

var jwt = require('jsonwebtoken');
var _ = require("underscore");

var graph = require('fbgraph');

exports.get = function(req, res) {
    console.log(req.user)

    var user_id = req.body.user_id;
    if (user_id == undefined) {
        user_id = req.user._id;
    }
    User.findById({
        _id: user_id
    }, function(err, user) {
        if (err) {
            common.sendMessage(res, 1, "Error while find user data.");
            return;
        }
        if (!user) {
            common.sendMessage(res, 2, "please input correct user_id");
            return;
        }
        common.sendData(res, user);
    });
}
exports.search = function(req, res) {

    var search = req.body.search;
    if (search == undefined) {
        common.sendMessage(res, 1, "Search field is empty.");
        return
    }
    console.log(req.body);
    Contact.find({
        user_id: req.user._id
    }).lean().populate("contact_user").exec(function(err, contact_users) {
        if (err) {
            common.sendMessage(res, 2, err);
        } else {
            if (search == "") {
                common.sendData(res, contact_users);
                return;
            }
            User.find({
                $or: [{
                        full_name: {
                            "$regex": search,
                            "$options": "i"
                        }
                    },
                    {
                        email: {
                            "$regex": search,
                            "$options": "i"
                        }
                    },
                    {
                        phone: {
                            "$regex": search.length > 0 ? search.substring(search.length - 10) : search,
                            "$options": "i"
                        }
                    }
                ],
                _id: {
                    "$ne": req.user._id
                }
            }).sort([
                ["_id", "ascending"]
            ]).limit(100).exec(function(err, userDatas) {
                if (err) {
                    common.sendMessage(res, 1, "Error while find user data.");
                    return;
                }
                if (!userDatas) {
                    common.sendMessage(res, 2, "please input correct user_id");
                    return;
                }
                var size = contact_users.length;
                userDatas.forEach(function(userData, index, array) {
                    for (i = 0; i < size; i++) {
                        if (userData._id == contact_users[i].contact_user._id) {
                            userDatas.remove(userData);
                            break;
                        }
                    }
                });
                common.sendData(res, userDatas);
            });
        }
    });
}
exports.passwordRecover = function(req, res) {
    var user = new User(req.body);
    user.email = req.body.email;
    if (req.body.password != undefined) {
        user.password = user.generateHash(req.body.password);
    }
    User.findOne({
        email: req.body.email
    }, function(err, doc) {
        try {
            user._id = doc._id;
            User.update({
                _id: user._id
            }, user, function(err, doc1) {
                if (err) {
                    common.sendMessage(res, 1, err);
                } else {
                    common.sendMessage(res, 200, "Successfully updated.");
                }
            });
        } catch (e) {}
    });
}

exports.resetPassword =  function(req, res) {
    let user_id = req.body.user_id;
    let key = req.body.code;
    User.findById(user_id, function(err, user){
        if(err){
            common.sendMessage(res, 0, "Bad Request.");
        }else if(!user){
            common.sendMessage(res, 1, "User Not Found.");
        }else if(user.code != key){
            common.sendMessage(res, 2, "Bad Request.");
        }else if(req.body.password==undefined){
            common.sendMessage(res, 3, "Bad Request.");
        }else{
            User.update( { _id: user_id }, {password: user.generateHash(req.body.password)}, function(err, doc1){
                if(err) {
                    common.sendMessage(res, 1, err);
                }else{
                    common.sendMessage(res, 200, "success");
                }
            });
        }
    });
}

exports.update = function(req, res) {
    if(req.body.email!==undefined) delete req.body.email;
    var user = new User(req.body);
    user._id = req.user._id;
    if (user.first_name != undefined && user.last_name != undefined) {
        user.full_name = user.first_name + " " + user.last_name;
    }
    if (user.password != undefined) {
        user.password = user.generateHash(user.password);
    }
    
 
    User.findOneAndUpdate({
        _id: user._id
    }, user, {
        upsert: true
    }, function(err, doc) {
        if (err) {
            common.sendMessage(res, 1, err);
        } else {
            common.sendMessage(res, 200, "Successfully updated.");
        }
    });
}

var multer = require('multer');
var profileUpload = multer({
    storage: multer.diskStorage({
        destination: function(req, file, cb) {
            if (!req.user) {
                cb(null, "tmp");
            } else {
                cb(null, 'public/uploads/profile')
            }
        },
        filename: function(req, file, cb) {
            console.log(file.originalname)
            if (!req.user) {
                cb(null, file.originalname);
            } else {
                var filename = req.user._id + '-' + Date.now();
                if (file.mimetype.startsWith("image/")) {
                    filename += "." + file.mimetype.replace("image/", "");
                }
                cb(null, filename);
            }
        }
    }),
    limits: {
        fileSize: 1024 * 1024
    }
}).single('photo');

exports.updateWithPhoto = function(req, res) {

    profileUpload(req, res, function(err) {
        
        var fields = req.body.fields;
        if (fields == undefined) {
            common.sendMessage(res, 0, "Fields is empty.");
            return;
        }
        console.log(req.body.fields)
        fields = JSON.parse(fields)
        
        var user = new User(fields);
        user._id = req.user._id;
        if (user.first_name != undefined && user.last_name != undefined) {
            user.full_name = user.first_name + " " + user.last_name;
        }
        if (req.file != undefined) user.photo = req.protocol + '://' + req.get('host') + "/uploads/profile/" + req.file.filename;

        if (user.password != undefined) {
            user.password = user.generateHash(user.password);
        }

        User.findOneAndUpdate({
            _id: user._id
        }, user, {
            upsert: true
        }, function(err, doc) {
            if (err) {
                common.sendMessage(res, 2, err);
            } else {
                if (req.file != undefined) {
                    common.sendFullResponse(res, user.photo, "Successfully updated.")
                } else {
                    common.sendMessage(res, 200, "Successfully updated.");
                }
            }
        });
    });
}

var fileUpload = multer({
    storage: multer.diskStorage({
        destination: function(req, file, cb) {
            if (!req.user) {
                cb(null, "tmp");
            } else {
                cb(null, 'public/uploads/share');
            }
        },
        filename: function(req, file, cb) {
            if (!req.user) {
                cb(null, file.originalname);
            } else {
                var filename = req.user._id + "_" + Date.now() + "_" + file.originalname;
                cb(null, filename);
            }
        }
    }),
    limits: {
        fileSize: 100 * 1024 * 1024
    }
});

exports.upload = function(req, res) {
    fileUpload.single('file')(req, res, function(err) {
        if (err) {
            common.sendMessage(res, 0, err);
        } else {
            var url = req.protocol + '://' + req.get('host') + "/uploads/share/" + req.file.filename;
            common.sendData(res, url);
        }
    })
};
exports.verifyConfirm = function(req, res) {
    if (req.body.code == undefined) {
        res.status(400)
        common.sendMessage(res, 1, "Bad Request.");
        return;
    }

    User.findOne({
        _id: req.user._id
    }, function(err, userdata) {
        if (err) {
            res.status(400)
            common.sendMessage(res, 2, "Bad Request.");
        } else {

            if (userdata) {
                console.log(userdata.code)


                if (userdata.code == req.body.code) {
                    var user = new User(userdata);
                    user.verified = true;
                    User.findOneAndUpdate({
                        _id: user._id
                    }, user, {
                        upsert: true
                    }, function(err, doc) {
                        if (err) {
                            res.status(400)
                            common.sendMessage(res, 1, err);
                        } else {
                            common.sendMessage(res, 200, "Your account verified successfully.");
                        }
                    });
                } else {
                    res.status(400)
                    common.sendMessage(res, 2, "Invalid Code.");
                }

            }

        }
    })


}

function checkLogin(body, userData) {
    if (body.type == "social") {
        if (userData.social_id == body.social_id) return true;
    } else {
        if (userData.validPassword(body.password)) return true;
    }
    return false;
}

exports.me = function(req, res){
    console.log(req.user)
    User.findOne({
        email: req.user.email
    }, function(err, userdata) {
        if (err) {
            common.sendMessage(res, 2, "Bad Request.");
        } else {

            if (userdata) {

                    validatedLogin(req, res, userdata);

            } else {
                res.status(401);
                common.sendMessage(res, 4, "Account not exists.")
            }
        }
    });

}

exports.loginFacebook = function(req, res) {
    if (req.body.access_token == undefined) {
        res.status(401)
        common.sendMessage(res, 0, "Bad Request.");
        return;
    }

    graph.get("/me?fields=email,name&access_token=" + req.body.access_token, function(err, resface) {
        // returns the post id
        if (err) {
            console.log(err)
            res.status(401)
            common.sendMessage(res, 1, err.message)

        } else {
            console.log(resface)
            User.findOne({
                email: resface.email
            }, function(err, userdata) {
                if (err) {
                    res.status(401)
                    common.sendMessage(res, 2, "Bad Request.");
                } else {
                    if (userdata) {
                        validatedLogin(req, res, userdata);
                    } else {
                        //common.sendMessage(res, 3, "Account create")

                        User.find().sort([
                            ["_id", "descending"]
                        ]).limit(1).exec(function(err, userdatas) {
                            if (err) {
                                res.status(401)
                                common.sendMessage(res, 4, err);
                            } else {
                                var newUser = new User();
                                newUser._id = (userdatas.length > 0) ? userdatas[0]._id + 1 : 0;
                                newUser.email = resface.email;
                                newUser.created_date = new Date();
                                newUser.updated_date = new Date();
                                newUser.verified = true;
                                newUser.save(function(err) {
                                    if (err) {
                                        res.status(401)
                                        common.sendMessage(res, 5, "error");
                                    } else {

                                        validatedLogin(req, res, newUser);
                                    }
                                });
                            }
                        });

                    }

                }
            })


        }


        
    });


}


exports.login = function(req, res) {
    if (req.body.email == undefined) {
        common.sendMessage(res, 0, "Bad Request.");
        return;
    }
    if (req.body.type == "social") {
        if (req.body.social_id != undefined) {
            User.findOne({
                email: req.body.email
            }, function(err, userdata) {
                if (err) {
                    common.sendMessage(res, 2, "Bad Request.");
                } else {
                    if (!userdata) {
                        User.find().sort([
                            ["_id", "descending"]
                        ]).limit(1).exec(function(err, userdatas) {
                            var newUser = new User();
                            newUser._id = (userdatas.length > 0) ? userdatas[0]._id + 1 : 0;
                            newUser.email = req.body.email;
                            newUser.social_id = req.body.social_id;
                            newUser.save(function(err) {
                                if (err) {
                                    common.sendMessage(res, 0, err);
                                } else {
                                    login(req, res);
                                }
                            });
                        });
                    } else {
                        login(req, res);
                    }
                }
            });
        }
    } else {
        login(req, res);
    }
};

exports.signup = function(req, res) {
    if (req.body.email == undefined) {
        res.status(401)
        common.sendMessage(res, 0, "Bad Request.");
        return;
    }
    if (req.body.password == undefined) {
        res.status(401)
        common.sendMessage(res, 1, "Bad Request.");
        return;
    }
    User.findOne({
        email: req.body.email
    }, function(err, userdata) {
        if (err) {
            res.status(401)
            common.sendMessage(res, 2, "Bad Request.");
        } else {
            if (userdata) {
                res.status(401)
                common.sendMessage(res, 3, "Account already exists.")
            } else {
                User.find().sort([
                    ["_id", "descending"]
                ]).limit(1).exec(function(err, userdatas) {
                    if (err) {
                        res.status(401)
                        common.sendMessage(res, 4, err);
                    } else {
                        var newUser = new User();
                        newUser._id = (userdatas.length > 0) ? userdatas[0]._id + 1 : 0;
                        newUser.email = req.body.email;
                        newUser.password = newUser.generateHash(req.body.password);
                        newUser.created_date = new Date();
                        newUser.updated_date = new Date();
                        newUser.verified = false;
                        newUser.save(function(err) {
                            if (err) {
                                res.status(401)
                                common.sendMessage(res, 5, "error");
                            } else {

                                login(req, res);
                            }
                        });
                    }
                });
            }
        }
    });
};

function validatedLogin(req, res, userdata) {

    var user_id = userdata._id;

    var sanitizedUser = new User(userdata)
    sanitizedUser.password = ""
    
    /*{
        _id: userdata._id,
        verified: userdata.verified,
        email: userdata.email,
        role_id: userdata.role_id,
        skills: userdata.skills,
        organizations: userdata.organizations,
        courses: userdata.courses,
        share: userdata.share
    }*/

    var sanitizedUserJWT = {
        _id: userdata._id,
        verified: userdata.verified,
        email: userdata.email,
        role_id: userdata.role_id,
        share: userdata.share
    }

    var token = jwt.sign(sanitizedUserJWT, constants.jwtsecret, {
        expiresIn: 60 * 24 * 365
    });
    //console.log(token)

    Skill.find({}, function(err, skills) {
        if (err) {
            common.sendMessage(res, 3, "Error while get all skills.")
        } else {
            Contact.find({
                user_id: user_id
            }).sort([
                ["status", "ascending"]
            ]).populate("contact_user").exec(function(err, contacts) {
                if (err) {
                    common.sendMessage(res, 3, "Error while get all skills.")
                } else {
                    ChatList.find({
                        user_id: user_id
                    }).populate("linked_user").exec(function(err, chatlists) {
                        if (err) {
                            common.sendMessage(res, 4, err);
                        } else {

                            if (req.body.phone_contacts == undefined) {
                                Contact.find({
                                    user_id: user_id
                                }).lean().sort([
                                    ["status", "ascending"]
                                ]).populate("contact_user").exec(function(err, contacts) {
                                    if (err) {
                                        common.sendMessage(res, 5, err);
                                    } else {
                                        common.sendData(res, {
                                            profile: sanitizedUser,
                                            skills: skills,
                                            contacts: contacts,
                                            chatlists: chatlists,
                                            contacts: contacts,
                                            token: token
                                        });
                                    }
                                });
                                return;
                            }
                            if (req.body.phone_contacts.length == undefined || req.body.phone_contacts.length == 0) {
                                Contact.find({
                                    user_id: user_id
                                }).lean().sort([
                                    ["status", "ascending"]
                                ]).populate("contact_user").exec(function(err, contacts) {
                                    if (err) {
                                        common.sendMessage(res, 5, err);
                                    } else {
                                        common.sendData(res, {
                                            profile: sanitizedUser,
                                            skills: skills,
                                            contacts: contacts,
                                            chatlists: chatlists,
                                            contacts: contacts,
                                            token: token
                                        });
                                    }
                                });
                                return;
                            }
                            var phone_contacts = req.body.phone_contacts;
                            var email = new Array();
                            var phone = new Array();
                            phone_contacts.forEach(function(current, index, array) {
                                email.push(current.contact_user.email);
                                if (current.contact_user.phone != undefined) {
                                    var newPhone = current.contact_user.phone;
                                    newPhone = newPhone.replace("(", "").replace(")", "").replace(" ", "").replace("-", "").replace("*", "").replace("#", "");
                                    if (newPhone.length > 10) {
                                        newPhone = newPhone.substring(newPhone.length - 10);
                                    }
                                    phone.push(new RegExp(newPhone, 'i'));
                                }
                            });
                            User.find({
                                $or: [{
                                    email: {
                                        $in: email
                                    }
                                }, {
                                    phone: {
                                        $in: phone
                                    }
                                }]
                            }).lean().exec(function(err, users) {
                                var ct = 0;

                                function checkFinish() {
                                    if ((++ct) >= users.length) {
                                        Contact.find({
                                            user_id: user_id
                                        }).lean().sort([
                                            ["status", "ascending"]
                                        ]).populate("contact_user").exec(function(err, contacts) {
                                            if (err) {
                                                common.sendMessage(res, 7, err);
                                            } else {
                                                common.sendData(res, {
                                                    profile: sanitizedUser,
                                                    skills: skills,
                                                    contacts: contacts,
                                                    chatlists: chatlists,
                                                    contacts: contacts,
                                                    token: token
                                                });
                                            }
                                        });
                                    }
                                };
                                if (users.length == 0) {
                                    checkFinish();
                                    return;
                                }
                                Contact.find().lean().sort([
                                    ["_id", "descending"]
                                ]).limit(1).exec(function(err, contacts) {
                                    let _id = (contacts.length > 0) ? contacts[0]._id + 1 : 0
                                    users.forEach(function(current, index, array) {
                                        if (user_id == current._id) {
                                            checkFinish();
                                            return;
                                        }
                                        Contact.findOne({
                                            user_id: user_id,
                                            contact_user: current._id
                                        }, function(err, contact) {
                                            if (contact) {
                                                checkFinish();
                                                return;
                                            }
                                            if (err) {
                                                common.sendMessage(res, 5, err);
                                                return;
                                            }
                                            let myContact = new Contact({
                                                _id: _id + index * 2,
                                                user_id: user_id,
                                                contact_user: current._id,
                                                status: 0
                                            });
                                            let linkedContact = new Contact({
                                                _id: _id + index * 2 + 1,
                                                user_id: current._id,
                                                contact_user: user_id,
                                                status: 0
                                            });
                                            myContact.save(function(err) {
                                                if (err) {
                                                    common.sendMessage(res, 6, err);
                                                } else {
                                                    linkedContact.save(function(err) {
                                                        checkFinish();
                                                    });
                                                }
                                            });
                                        });
                                    });
                                });
                            });
                        }
                    });
                }
            });
        }
    });


}

function login(req, res) {

    //User.find({email: req.body.email}).limit(1).exec(function(err, userdata){
    User.findOne({
        email: req.body.email
    }, function(err, userdata) {
        if (err) {
            common.sendMessage(res, 2, "Bad Request.");
        } else {

            if (userdata) {

                if (checkLogin(req.body, userdata)) {
                    validatedLogin(req, res, userdata);
                } else {
                    res.status(401);
                    common.sendMessage(res, 3, "Security info is incorrect.");
                }
            } else {
                res.status(401);
                common.sendMessage(res, 4, "Account not exists.")
            }
        }
    });
}
