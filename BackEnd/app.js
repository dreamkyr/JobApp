var express = require('express');
var expressJwt = require('express-jwt');
var jwt = require('jsonwebtoken');

var path = require('path');
var favicon = require('static-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var mongoose = require('mongoose');
var constants = require('./app/constants');
var session = require('express-session');
var common = require('./app/common');
var User = require('./models/user');

var app = express();

mongoose.connect(constants.dburl);
// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');

app.use(favicon());
app.use(logger('dev'));
app.use(bodyParser.json({limit: '5mb'}));
app.use(bodyParser.urlencoded({extended: false}));
app.use(cookieParser());
//app.use(session({ secret: 'secret', resave: true, saveUninitialized: true }));
app.use('/job_admin/api', 
        expressJwt({secret: constants.jwtsecret})
        .unless({path: ['/job_admin/api/user/login',
                        '/job_admin/api/user/signup',
                        '/job_admin/api/user/forgotten',
                        '/job_admin/api/user/auth/facebook',
                        '/job_admin/api/user/resetpassword']}) 
        
        );



app.use(express.static(path.join(__dirname, 'public')));

var routes = require('./routes/index');
var api = require('./routes/api');

app.use('/', routes);
app.use('/job_admin/api', api);
var mailer = require('express-mailer');

mailer.extend(app, {
    from: 'noreply@joltmate.com',
    host: 'smtp.mailgun.org', // hostname
    secureConnection: true, // use SSL
    port: 465, // port for secure SMTP
    transportMethod: 'SMTP', // default is SMTP. Accepts anything that nodemailer accepts
    auth: {
        user: 'postmaster@mg.joltmate.com',
        pass: '9d24a609f9dee746711b5d14992431ab'
    }
});

app.post("/job_admin/api/verification", function(req, res, next){
    var code = parseInt(getRandom(12345, 98765));

    User.update (
    { _id : req.user._id },
    { $set : { code:code } },
    function( err, result ) {
        if ( err ) throw err;
    }
    );

    app.mailer.send(
        { template: 'verificationmail' },
        {
            to: req.user.email,
            subject: 'Verification Email For JobMobileApp',
            code: code
        },
        function (err) {
            if (err) {
                common.sendMessage(res, 1, err);
                return;
            }else{
                common.sendMessage(res, 200, "Verification mail sent successfully.");
            }
        }
    );
});
app.post("/job_admin/api/user/forgotten", function(req, res, next){
    var code = parseInt(getRandom(12345, 98765));
    if(!req.body.email){
        common.sendMessage(res, 0, "Bad Request.");
        return;
    }
    User.findOne({email: req.body.email}, function(err, user){
        if(err){
            common.sendMessage(res, 1, "Bad Request.");
        }else if(!user){
            common.sendMessage(res, 1, "The use is not exists.");
        }else{          
            User.update (
            { _id : user._id },
            { $set : { code:code } },
            function( err, result ) {
                if ( err ) throw err;
            }
            );
            app.mailer.send(
                { template: 'forgetmail' },
                {
                    to: user.email,
                    subject: 'Reset Password For JobMobileApp',
                    code: code
                },
                function (err) {
                    if (err) {
                        common.sendMessage(res, 1, err);
                        return;
                    }else{
                        common.sendMessage(res, 200, {user_id: user._id});
                    }
                }
            );
        }
    });
});

function getRandom(min, max) {
  return Math.random() * (max - min) + min;
}
/// catch 404 and forwarding to error handler
app.use(function(req, res, next) {
    var err = new Error('Not Found');
    err.status = 404;
    next(err);
});

// development error handler
// will print stacktrace
if (app.get('env') === 'development') {
    app.use(function(err, req, res, next) {
        res.status(err.status || 500);
        res.render('error', {
            message: err.message,
            error: err
        });
    });
}


// no stacktraces leaked to user
app.use(function(err, req, res, next) {
    res.status(err.status || 500);
    res.render('error', {
        message: err.message,
        error: {}
    });
});

module.exports = app;
