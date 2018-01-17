var mongoose = require("mongoose");
var Job = require("../../models/job");
var User = require("../../models/user");
var Contact = require("../../models/contact");
var common = require("../../app/common");
var constants = require('../../app/constants');
var mqtt = require('mqtt');


function getPeriod(date) {
    var period = parseInt((new Date() - date) / (1000.0 * 60)) + 1;
    if (isNaN(period)) return date;
    if (period < 60) {
        return (period + " mins ago");
    }
    period = parseInt(period / 60);
    if (period < 24) {
        return (period + " hours ago");
    }
    period = parseInt(period / 24);
    if (period < 30) {
        return (period + " days ago");
    }
    period = parseInt(period / 30);
    return (period + " months ago");
}

function filterPostedDateJob(job) {
    job.posted_date = getPeriod(job.posted_date);
    var share_dates = job.share_dates;
    var newArray = new Array(share_dates.length);
    share_dates.forEach(function(current, index, array) {
        newArray[index] = getPeriod(current);
    })
    job.share_dates = newArray;
    return job;
}

function filterPostedDateJobs(jobs) {
    jobs.forEach(function(current, index, array) {
        array[index] = filterPostedDateJob(current);
    });
    return jobs;
}

exports.add = function(req, res) {

    let user_id = req.user._id;
    var newJob = new Job(req.body);
    newJob.referrer = user_id;
    Job.find().lean().sort([
        ['_id', 'descending']
    ]).limit(1).exec(function(err, jobData) {
        newJob.posted_date = new Date();
        if (req.body._id == undefined) {
            newJob._id = jobData.length > 0 ? jobData[0]._id + 1 : newJob._id;
            newJob.share_users = [req.user._id];
            newJob.share_dates = [new Date()];
            newJob.save(function(err) {
                if (err) {
                    common.sendMessage(res, 1, err);
                } else {
                    var mqtt_client = mqtt.connect("mqtt://localhost:" + constants.mqtt_chatting_server);
                    if (req.body.invited_users.length != 0) {
                        req.body.invited_users.forEach(function(current, index, array) {
                            let topic = constants.mqtt_chatting_prefix + current;
                            let message = {
                                type: "text",
                                sender: req.user._id,
                                content: "Hi. Are you interested my project?\n please reply."
                            }
                            mqtt_client.publish(topic, JSON.stringify(message));
                        });
                    }
                    mqtt_client.end();
                    Contact.find({
                        user_id: user_id,
                        isShared: true
                    }).lean().distinct("contact_user").exec(function(err, contact_users) {
                        mqtt_client = mqtt.connect("mqtt://localhost:" + constants.mqtt_notification_server);
                        contact_users.forEach(function(current, index, array) {
                            let topic = constants.mqtt_notification_prefix + current;
                            let message = {
                                type: constants.notification_type.job_posted,
                                content: JSON.stringify({
                                    referrer: user_id,
                                    job_id: newJob._id
                                })
                            }
                            mqtt_client.publish(topic, JSON.stringify(message));
                        });
                        mqtt_client.end();
                    });
                    common.sendMessage(res, 200, "Successfully added.");
                }
            });
        } else {
            newJob.share_users = undefined;
            newJob.share_dates = undefined;
            Job.findOneAndUpdate({
                _id: newJob._id
            }, newJob, {
                upsert: true
            }, function(err, doc) {
                if (err) {
                    common.sendMessage(res, 1, err);
                } else {
                    common.sendMessage(res, 200, "Successfully added.");
                }
            });
        }
    });
}
exports.delete = function(req, res) {

    let job_id = req.body.job_id;
    if (job_id == undefined) {
        common.sendMessage(res, 1, "job_id is undefined.");
        return;
    }
    Job.findById(job_id).exec(function(err, jobData) {
        if (err) {
            common.sendMessage(res, 1, "Error while find job.");
            return;
        }
        if (jobData == undefined) {
            common.sendMessage(res, 2, "The job not exists.");
            return;
        }
        if (jobData.referrer != req.user._id) {
            common.sendMessage(res, 3, "This job is not your job.");
            return;
        }
        jobData.remove(function(err) {
            if (err) {
                common.sendMessage(res, 4, "Error while delete job.");
            } else {
                common.sendMessage(res, 200, "Successfully deleted.");
            }
        });
    });
}

exports.getById = function(req, res) {

    let _id = req.body._id;
    if (_id == undefined) {
        common.sendMessage(res, 1, "_id is undefined.");
        return;
    }
    Job.findById(_id)
        .populate("referrer")
        .populate("share_users")
        .populate("proposed_users.profile")
        .populate("accepted_user")
        .populate("favorite_users")
        .exec(function(err, resultJob) {
            if (err) {
                common.sendMessage(res, 1, "Error while findById.");
                return;
            }
            if (jobData.referrer != req.user._id) {
                common.sendMessage(res, 3, "This job is not your job.");
                return;
            }
            common.sendData(res, filterPostedDateJob(resultJob));
        })
}
exports.getMyPost = function(req, res) {

    Job.find({
            share_users: req.user._id
        }).lean()
        .populate("referrer")
        .populate("proposed_users.profile")
        .populate("accepted_user")
        .populate("favorite_users")
        .limit(100).exec(function(err, resultJobs) {
            resultJobs.sort(function(a, b) {
                var share_dates1 = a.share_dates
                var share_dates2 = b.share_dates
                var share_users1 = a.share_users
                var share_users2 = b.share_users
                var date1, date2;
                share_users1.forEach(function(share_user, sindex, sarray) {
                    if (share_user == req.user._id) date1 = share_dates1[sindex];
                });
                share_users2.forEach(function(share_user, sindex, sarray) {
                    if (share_user == req.user._id) date2 = share_dates2[sindex];
                });
                return date2.getTime() - date1.getTime();
            });
            Job.populate(resultJobs, "share_users", function(err) {
                if (err) {
                    common.sendMessage(res, 1, "Error while get proposed.");
                } else {
                    common.sendData(res, filterPostedDateJobs(resultJobs));
                }
            });
        });
}

exports.getByUserId = function(req, res) {

    let user_id = req.body.user_id;
    if (user_id == undefined) {
        common.sendMessage(res, 1, "user_id is undefined.");
        return;
    }
    Job.find({
            share_users: user_id,
            hidden_users: {
                "$nin": [req.user._id]
            }
        }).lean()
        .populate("referrer")
        .populate("share_users")
        .populate("proposed_users.profile")
        .populate("accepted_user")
        .populate("favorite_users")
        .limit(100).exec(function(err, resultJobs) {
            resultJobs.sort(function(a, b) {
                var share_dates1 = a.share_dates
                var share_dates2 = b.share_dates
                var share_users1 = a.share_users
                var share_users2 = b.share_users
                var date1, date2;
                share_users1.forEach(function(share_user, sindex, sarray) {
                    if (share_user == user_id) date1 = share_dates1[sindex];
                });
                share_users2.forEach(function(share_user, sindex, sarray) {
                    if (share_user == user_id) date2 = share_dates2[sindex];
                });
                return 1;
            });
            Job.populate(resultJobs, "share_users", function(err) {
                if (err) {
                    common.sendMessage(res, 1, "Error while get proposed.");
                } else {
                    common.sendData(res, filterPostedDateJobs(resultJobs));
                }
            });
        });
}

exports.searchJob = function(req, res) {

    var searchFields = {
        referrer: {
            "$ne": req.user._id
        },
        hidden_users: {
            "$nin": [req.user._id]
        }
    };
    if (req.body.skills != undefined)
        if (req.body.skills.length > 0) {
            searchFields.skills = {
                "$in": req.body.skills
            };
        }
    if (req.body.country != undefined && req.body.country != "") {
        searchFields.country = req.body.country;
    }
    if (req.body.city != undefined && req.body.city != "") {
        searchFields.city = {
            $regex: new RegExp('^' + req.body.city + '$', "i")
        };
    }
    if (req.body.state != undefined && req.body.state != "") {
        searchFields.state = {
            $regex: new RegExp('^' + req.body.state + '$', "i")
        };
    }
    if (req.body.type != undefined && req.body.type != "") {
        searchFields.type = new RegExp('^' + req.body.type + '$', "i");
    }
    Contact.find({
        contact_user: req.user._id,
        isShared: true,
        status: 0
    }).distinct("user_id", function(err, contact_users) {
        if (contact_users.length == 0) {
            common.sendData(res, []);
            return;
        }
        var ct = 0;
        var result = new Array();
        contact_users.forEach(function(current, index, array) {
            searchFields.share_users = {
                $in: [current]
            };
            Job.find(searchFields).lean()
                .populate("referrer")
                .populate("proposed_users.profile")
                .populate("accepted_user")
                .populate("favorite_users").exec(function(err, resultJobs) {
                    if (resultJobs.length > 0) {
                        resultJobs.sort(function(a, b) {
                            var share_dates1 = a.share_dates
                            var share_dates2 = b.share_dates
                            var share_users1 = a.share_users
                            var share_users2 = b.share_users
                            var date1 = null, date2 = null;
                            share_users1.forEach(function(share_user, sindex, sarray) {
                                if (share_user == current) date1 = share_dates1[sindex];
                            });
                            share_users2.forEach(function(share_user, sindex, sarray) {
                                if (share_user == current) date2 = share_dates2[sindex];
                            });
                            return date2.getTime() - date1.getTime();
                        });
                        Job.populate(resultJobs, "share_users", function(err) {
                            result.push({
                                user_id: current,
                                jobs: filterPostedDateJobs(resultJobs)
                            });
                            if ((++ct) == contact_users.length) {
                                common.sendData(res, result);
                            }
                        });
                    } else {
                        if ((++ct) == contact_users.length) {
                            common.sendData(res, result);
                        }
                    }
                });
        })
    });
}
exports.getProposed = function(req, res) {

    Job.find({
            "proposed_users.profile": req.user._id
        }).lean()
        .populate("referrer")
        .populate("share_users")
        .populate("proposed_users.profile")
        .populate("accepted_user")
        .populate("favorite_users")
        .sort({
            posted_date: -1
        }).limit(100).exec(function(err, resultJobs) {
            if (err) {
                common.sendMessage(res, 1, err);
            } else {
                common.sendData(res, filterPostedDateJobs(resultJobs));
            }
        });
}
exports.getShared = function(req, res) {

    Job.find({
            referrer: {
                "$ne": req.user._id
            },
            share_users: req.user._id
        }).lean()
        .populate("referrer")
        .populate("proposed_users.profile")
        .populate("accepted_user")
        .populate("favorite_users")
        .limit(100).exec(function(err, resultJobs) {
            resultJobs.sort(function(a, b) {
                var share_dates1 = a.share_dates
                var share_dates2 = b.share_dates
                var share_users1 = a.share_users
                var share_users2 = b.share_users
                var date1, date2;
                share_users1.forEach(function(share_user, sindex, sarray) {
                    if (share_user == req.user._id) date1 = share_dates1[sindex];
                });
                share_users2.forEach(function(share_user, sindex, sarray) {
                    if (share_user == req.user._id) date2 = share_dates2[sindex];
                });
                return date2.getTime() - date1.getTime();
            });
            Job.populate(resultJobs, "share_users", function(err) {
                if (err) {
                    common.sendMessage(res, 1, "Error while get proposed.");
                } else {
                    common.sendData(res, filterPostedDateJobs(resultJobs));
                }
            });
        });
}
exports.getCurrent = function(req, res) {

    Job.find({
            accepted_user: req.user._id
        }).lean()
        .populate("referrer")
        .populate("share_users")
        .populate("proposed_users.profile")
        .populate("accepted_user")
        .populate("favorite_users")
        .sort([
            ['_id', 'descending']
        ]).limit(100).exec(function(err, resultJobs) {
            if (err) {
                common.sendMessage(res, 1, "Error while get current.");
            } else {
                common.sendData(res, filterPostedDateJobs(resultJobs));
            }
        });
}
exports.getPassed = function(req, res) {

    Job.find({
            accepted_user: req.user._id,
            status: 3
        }).lean()
        .populate("referrer")
        .populate("share_users")
        .populate("proposed_users.profile")
        .populate("accepted_user")
        .populate("favorite_users")
        .sort({
            posted_date: -1
        }).limit(100).exec(function(err, resultJobs) {
            if (err) {
                common.sendMessage(res, 1, "Error while get passed.");
            } else {
                common.sendData(res, filterPostedDateJobs(resultJobs));
            }
        });
}

exports.getFavorite = function(req, res) {

    Job.find({
            favorite_users: req.user._id
        }).lean()
        .populate("referrer")
        .populate("share_users")
        .populate("proposed_users.profile")
        .populate("accepted_user")
        .populate("favorite_users")
        .sort([
            ['_id', 'descending']
        ]).limit(100).exec(function(err, resultJobs) {
            if (err) {
                common.sendMessage(res, 1, "Error while get current.");
            } else {
                common.sendData(res, filterPostedDateJobs(resultJobs));
            }
        });
}

var multer = require('multer');
var profileUpload = multer({
    storage: multer.memoryStorage(),
    limits: {
        fileSize: 5 * 1024 * 1024 // no larger than 5mb, you can change as needed.
    }
}).single("resume");



exports.addProposeResume = function(req, res) {
    profileUpload(req, res, (err) => {


        let job_id = req.body.job_id;
        if (job_id == undefined) {
            res.status(400)
            common.sendMessage(res, 1, "job_id is undefined.");
            return
        }
        console.log(job_id)
        Job.findById(job_id, function(err, jobData) {
            if (err) {
                res.status(400)
                common.sendMessage(res, 4, "Error while update Job Data.");
            } else {

                // console.log(jobData)
                for (i = 0; i < jobData.proposed_users.length; i++) {
                    if (jobData.proposed_users[i].profile == req.user._id) {
                        res.status(401)
                        common.sendMessage(res, 5, "You have already proposed on this job.");
                        return;
                    }
                }


                User.findById(req.user._id, (err, profile) => {

                    jobData.proposed_users.push({
                        profile: req.user._id,
                        contact_email: (profile.email !== undefined) ? profile.email : '',
                        contact_phone: (profile.phone !== undefined) ? profile.phone : ''
                    });

                    Job.update({
                        _id: jobData
                    }, jobData, {
                        upsert: true
                    }, function(err, updatedData) {
                        if (err) {
                            common.sendMessage(res, 5, "Error while update Job Data.");
                        } else {
                            common.sendMessage(res, 200, "Successfully proposed.");
                            User.findById(jobData.referrer, (err, jobOwner) => {
                                //  console.log(jobData)
                                // console.log(jobOwner)

                                //User.findById(req.user._id, (err, profile)=>{
                                // console.log(profile)

                                var name = (profile.first_name !== undefined) ? profile.first_name : '' + " " + (profile.last_name !== undefined) ? profile.last_name : ''


                                if (!req.file) {
                                    console.log('nofile')


                                } else {
                                    console.log(req.file.originalname)
                                }

                                req.app.mailer.send({
                                        template: 'jobpropose'
                                    }, {
                                        to: jobOwner.email,
                                        subject: jobData.title + ' | ' + name + ' | Resume from Jolt Mate',
                                        profile: profile,
                                        email: (profile.email !== undefined) ? profile.email : '',
                                        phone: (profile.phone !== undefined) ? profile.phone : '',
                                        attachments: (!req.file) ? [] : [{ // binary buffer as an attachment
                                            fileName: req.file.originalname,
                                            contents: req.file.buffer
                                        }]
                                    },
                                    function(err) {
                                        if (err) {
                                            common.sendMessage(res, 1, err);
                                            return;
                                        } else {
                                            common.sendMessage(res, 200, "Propose mail sent successfully.");
                                        }
                                    }
                                );

                                //})


                            })
                        }
                    });

                })
            }
        });




    })
}

exports.addPropose = function(req, res) {

    let job_id = req.body.job_id;
    if (job_id == undefined) {
        res.status(400)
        common.sendMessage(res, 1, "job_id is undefined.");
        return
    }
    Job.findById(job_id, function(err, jobData) {
        if (err) {
            res.status(400)
            common.sendMessage(res, 4, "Error while update Job Data.");
        } else {


            //console.log(jobData)
            for (i = 0; i < jobData.proposed_users.length; i++) {
                if (jobData.proposed_users[i].profile == req.user._id) {
                    res.status(401)
                    common.sendMessage(res, 5, "You have already proposed on this job.");
                    return;
                }
            }
            jobData.proposed_users.push({
                profile: req.user._id,
                contact_email: req.body.contact_email,
                contact_phone: req.body.contact_phone
            });
            Job.update({
                _id: jobData
            }, jobData, {
                upsert: true
            }, function(err, updatedData) {
                if (err) {
                    common.sendMessage(res, 5, "Error while update Job Data.");
                } else {
                    common.sendMessage(res, 200, "Successfully proposed.");
                    User.findById(jobData.referrer, (err, jobOwner) => {
                        console.log(jobData)
                        console.log(jobOwner)

                        User.findById(req.user._id, (err, profile) => {
                            console.log(profile)

                            var name = (profile.first_name !== undefined) ? profile.first_name : '' + " " + (profile.last_name !== undefined) ? profile.last_name : ''
                            req.app.mailer.send({
                                    template: 'jobpropose'
                                }, {
                                    to: jobOwner.email,
                                    subject: jobData.title + ' | ' + name + ' | Resume from Jolt Mate',
                                    profile: profile,
                                    email: req.body.contact_email,
                                    phone: req.body.contact_phone
                                },
                                function(err) {
                                    if (err) {
                                        common.sendMessage(res, 1, err);
                                        return;
                                    } else {
                                        common.sendMessage(res, 200, "Propose mail sent successfully.");
                                    }
                                }
                            );

                        })


                    })
                }
            });
        }
    });
}

exports.removePropose = function(req, res) {

    let job_id = req.body.job_id;
    if (job_id == undefined) {
        common.sendMessage(res, 1, "job_id is undefined.");
        return
    }
    Job.findById(job_id, function(err, jobData) {
        if (err) {
            common.sendMessage(res, 4, "Error while update Job Data.");
        } else {
            jobData.proposed_users.remove(req.user._id);
            Job.update({
                _id: jobData
            }, jobData, {
                upsert: true
            }, function(err, updatedData) {
                if (err) {
                    common.sendMessage(res, 5, "Error while update Job Data.");
                } else {
                    common.sendMessage(res, 200, "Successfully proposed.");
                }
            });
        }
    });
}

exports.addFavorite = function(req, res) {

    let job_id = req.body.job_id;
    if (job_id == undefined) {
        common.sendMessage(res, 1, "job_id is undefined.");
        return
    }
    Job.findById(job_id, function(err, jobData) {
        if (err) {
            common.sendMessage(res, 4, "Error while update Job Data.");
        } else {
            jobData.favorite_users.push(req.user._id);
            Job.update({
                _id: jobData
            }, jobData, {
                upsert: true
            }, function(err, updatedData) {
                if (err) {
                    common.sendMessage(res, 5, "Error while update Job Data.");
                } else {
                    common.sendMessage(res, 200, "Successfully favorited.");
                }
            });
        }
    });
}

exports.removeFavorite = function(req, res) {

    let job_id = req.body.job_id;
    if (job_id == undefined) {
        common.sendMessage(res, 1, "job_id is undefined.");
        return
    }
    Job.findById(job_id, function(err, jobData) {
        if (err) {
            common.sendMessage(res, 4, "Error while update Job Data.");
        } else {
            jobData.favorite_users.remove(req.user._id);
            Job.update({
                _id: jobData
            }, jobData, {
                upsert: true
            }, function(err, updatedData) {
                if (err) {
                    common.sendMessage(res, 5, "Error while update Job Data.");
                } else {
                    common.sendMessage(res, 200, "Successfully unfavorited.");
                }
            });
        }
    });
}
exports.addShare = function(req, res) {

    let job_id = req.body.job_id;
    if (job_id == undefined) {
        common.sendMessage(res, 1, "job_id is undefined.");
        return
    }
    Job.findById(job_id, function(err, jobData) {
        if (err) {
            common.sendMessage(res, 4, "Error while update Job Data.");
        } else {
            if (jobData.share_users.indexOf(req.user._id) > -1) {
                common.sendMessage(res, 6, "This job have already shared.");
                return;
            }
            jobData.share_users.push(req.user._id);
            jobData.share_dates.push(new Date());
            Job.update({
                _id: jobData
            }, jobData, {
                upsert: true
            }, function(err, updatedData) {
                if (err) {
                    common.sendMessage(res, 5, "Error while update Job Data.");
                } else {
                    common.sendMessage(res, 200, "Successfully added.");
                    Contact.find({
                        user_id: req.user._id,
                        isShared: true
                    }).distinct("contact_user", function(err, contact_users) {
                        mqtt_client = mqtt.connect("mqtt://localhost:" + constants.mqtt_notification_server);
                        contact_users.forEach(function(current, index, array) {
                            let topic = constants.mqtt_notification_prefix + current;
                            let message = {
                                type: constants.notification_type.job_posted,
                                content: JSON.stringify({
                                    referrer: req.user._id,
                                    job_id: jobData._id
                                })
                            }
                            mqtt_client.publish(topic, JSON.stringify(message));
                        });
                        mqtt_client.end();
                    });
                }
            });
        }
    });
}

exports.removeShare = function(req, res) {

    let job_id = req.body.job_id;
    if (job_id == undefined) {
        common.sendMessage(res, 1, "job_id is undefined.");
        return
    }
    Job.findById(job_id, function(err, jobData) {
        if (err) {
            common.sendMessage(res, 4, "Error while update Job Data.");
        } else {
            let index = jobData.share_users.indexOf(req.user._id);
            jobData.share_users.splice(index, 1);
            jobData.share_dates.splice(index, 1);
            Job.update({
                _id: job_id
            }, jobData, {
                upsert: true
            }, function(err, updatedData) {
                if (err) {
                    common.sendMessage(res, 5, "Error while update Job Data.");
                } else {
                    common.sendMessage(res, 200, "Successfully unshared.");
                }
            });
        }
    });
}

exports.addAward = function(req, res) {

    let job_id = req.body.job_id;
    let user_id = req.body.user_id;
    if (job_id == undefined) {
        common.sendMessage(res, 1, "job_id is empty.");
        return
    }
    if (user_id == undefined) {
        common.sendMessage(res, 2, "user_id is empty.");
        return
    }
    Job.findById(job_id, function(err, jobData) {
        if (err) {
            common.sendMessage(res, 3, "Error while update Job Data.");
        } else {
            jobData.accepted_user = user_id;
            jobData.proposed_users.remove(user_id);
            Job.findOneAndUpdate({
                _id: job_id
            }, jobData, {
                upsert: true
            }, function(err, doc) {
                if (err) {
                    common.sendMessage(res, 4, "Error while update Job Data.");
                } else {
                    let topic = constants.mqtt_notification_prefix + user_id;
                    let message = {
                        type: constants.notification_type.job_award,
                        content: "You have awarded to " + jobData.title
                    }
                    mqtt_client.publish(topic, JSON.stringify(message));
                    common.sendMessage(res, 200, "Successfully awarded.");
                }
            });
        }
    });
}

exports.removeAward = function(req, res) {

    let job_id = req.body.job_id;
    if (job_id == undefined) {
        common.sendMessage(res, 1, "job_id is undefined.");
        return
    }
    Job.findById(job_id, function(err, jobData) {
        if (err) {
            common.sendMessage(res, 4, "Error while update Job Data.");
        } else {
            if (jobData.status == 1) {
                common.sendMessage(res, 4, "Error while update Job Data.");
            }
            jobData.accepted_user = undefined;
            Job.update({
                _id: jobData
            }, jobData, {
                upsert: true
            }, function(err, updatedData) {
                if (err) {
                    common.sendMessage(res, 5, "Error while update Job Data.");
                } else {
                    common.sendMessage(res, 200, "Successfully awarded.");
                }
            });
        }
    });
}