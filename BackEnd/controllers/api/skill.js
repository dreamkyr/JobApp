var mongoose = require("mongoose");
var Skill = require("../../models/skill.js");
var common = require("../../app/common.js");

exports.get = function(req, res){
    if(req.body.skill_id!=undefined){
        Skill.findOne({_id: req.body.skill_id}, function(err, skill){
            if(err){
                common.sendMessage(res, 0, "Error while get all categories.")
            }else{
                common.sendData(res, skill);
            }
        });
    }else{
        Skill.find({}, function(err, skills){
            if(err){
                common.sendMessage(res, 1, "Error while get all skills.")
            }else{
                common.sendData(res, skills);
            }
        });
    }
}
exports.add = function(req, res){
    var skills = req.body.skills;
    var ct=0;
    Skill.remove(function(err){
        skills.forEach(function(current, index, array){
            var skill = new Skill(current);
            skill._id = index;
            skill.save(function(err){
                if((++ct)==skills.length){
                    common.sendMessage(res, 200, "Successfully added.");
                }
            });
        });
    });
}
