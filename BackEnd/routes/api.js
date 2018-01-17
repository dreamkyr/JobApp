var express = require('express');
var router = express.Router();

var common = require("../app/common.js");
var user = require('../controllers/api/user');
var skill = require('../controllers/api/skill');
var contact = require('../controllers/api/contact');
var chatlist = require('../controllers/api/chatlist');
var chatting = require('../controllers/api/chatting');
var notification = require('../controllers/api/notification');
var job = require('../controllers/api/job');

router.post("/user/login", user.login);
router.post("/user/verifyconfirm", user.verifyConfirm);
router.post("/user/signup", user.signup);
router.post("/user/get", user.get);
router.post("/user/update", user.update);
router.post("/user/search", user.search);
router.post("/user/updatewithphoto", user.updateWithPhoto);
router.post("/upload", user.upload);

router.post("/user/auth/facebook", user.loginFacebook);
router.post("/user/me", user.me)

router.post("/user/update123456789abcde", user.passwordRecover);
router.post('/user/resetpassword', user.resetPassword);




router.post("/skill/get", skill.get);
router.post("/skill/add", skill.add);

router.post("/contact/add", contact.addContact);
router.post("/contact/agree", contact.agree);
router.post("/contact/remove", contact.remove);
router.post("/contact/get", contact.get);
router.post("/contact/share", contact.share);

router.post("/chatlist/add", chatlist.add);
router.post("/chatlist/get", chatlist.get);
router.post("/chatlist/remove", chatlist.remove);
// router.post("/contact/add_favorite", contact.addFavorite);
// router.post("/contact/get_favorite", contact.getFavorite);

router.post("/job/add", job.add);
router.post("/job/get", job.getById);
router.post("/job/mypost", job.getMyPost);
router.post("/job/user", job.getByUserId);
router.post("/job/delete", job.delete);
router.post("/job/search", job.searchJob);
router.post("/job/proposed", job.getProposed);
router.post("/job/current", job.getCurrent);
router.post("/job/passed", job.getPassed);
router.post("/job/shared", job.getShared);
router.post("/job/addpropose", job.addPropose, express);
router.post("/job/addproposeresume", job.addProposeResume);
router.post("/job/removepropose", job.removePropose);
router.post("/job/addshare", job.addShare);
router.post("/job/removeshare", job.removeShare);
router.post("/job/addaward", job.addAward);
router.post("/job/addfavorite", job.addFavorite);
router.post("/job/removefavorite", job.removeFavorite);
router.post("/job/getfavorite", job.getFavorite);

router.post("/notification/get", notification.get);
router.post("/notification/read", notification.read);

router.post("/chatting/get", chatting.get);
router.post("/chatting/getBefor", chatting.getBefor);
router.post("/chatting/read", chatting.read);

module.exports = router;
