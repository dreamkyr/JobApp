var express = require('express');
var router = express.Router();
var common = require('../app/common');
var User = require('../models/user');

/* GET home page. */
router.get('/', function(req, res) {
  res.render('index', { title: 'Express' });
});
router.get('/forgetpassword/:user_id/:key', function(req, res) {
    let user_id = req.params.user_id;
    let key = req.params.key;
    User.findById(user_id, function(err, user){
        if(err){
            common.sendMessage(res, 0, "Bad Request.");
        }else if(!user){
            common.sendMessage(res, 1, "Bad Request.");
        }else if(user.password.replaceAll("/" , "_") != key){
            common.sendMessage(res, 2, "Bad Request.");
        }else{
            res.render('forgetpassword');
        }
    });
});

module.exports = router;
