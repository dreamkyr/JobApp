var mongoose = require("mongoose");
var ShareJob = require("../../models/sharejob");
var common = require("../../app/common.js");

exports.add = function(req, res){

    if(req.body.job_id==undefined){
        common.sendMessage(res, 1, "job_id is undefined.");
        return;
    }
    var sharejob = new ShareJob();
    ShareJob.find().lean.sort([['id', "descending"]]).limit(1).exec(function(err, sharejobs){
        if(err){
            common.sendMessage(res, 2, err);
            return;
        }
        sharejob._id = (sharejobs.length>0) ? sharejobs[0]._id+1 : 0
        sharejob.user_id = req.user._id;
        sharejob.job_id = req.body.job_id;
        sharejob.save(function(err){
            if(err){
                common.sendMessage(res, 3, err);
            }else{
                common.sendMessage(res, 200, "Successfully added.");
            }
        });
    });
}
exports.remove = function(req, res){

    if(req.body.job_id==undefined){
        common.sendMessage(res, 1, "job_id is undefined.");
        return;
    }
    ShareJob.findById(req.body.job_id, function(err, sharejob){
        if(err){
            common.sendMessage(res, 2, err);
        }else{
            if(sharejob==undefined){
                common.sendMessage(res, 3, "this job is not exists.");
                return;
            }
            sharejob.remove(function(err){
                if(err){
                    common.sendMessage(res, 4, err);
                }else{
                    common.sendMessage(res, 200, "Successfully removed.");
                }
            });
        }
    });
}
