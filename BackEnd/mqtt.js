var mosca = require('mosca');
var common = require('./app/common');
var constants = require('./app/constants');
var Notification = require('./models/notification');
var Chatting = require('./models/chatting');
var ChatList = require('./models/chatlist');

var chatting_server = new mosca.Server({
     port:constants.mqtt_chatting_server,
     username: constants.mqtt_options.username,
     password: constants.mqtt_options.password,
     rejectUnauthorized : true
 });
 var notification_server = new mosca.Server({
      port:constants.mqtt_notification_server,
      username: constants.mqtt_options.username,
      password: constants.mqtt_options.password,
      rejectUnauthorized : true
  });

var connectedUser = new Array();
var chatroomUser = new Array();

notification_server.on('clientConnected', function(client) {
    if(connectedUser.indexOf(client.id)<0){
        connectedUser.push(client.id);
    }
});
notification_server.on("clientDisconnected", function(client){
    connectedUser.remove(client.id);
});
notification_server.on('published', function(packet, client) {
    try{
        let keys = packet.topic.split("/");
        let type = keys[1];
        let user_id = keys[3];
        let data = JSON.parse(packet.payload.toString());
        console.log(JSON.stringify(data));
        if(type=="notification"){
            if(connectedUser.indexOf(user_id)>-1){
                data.isRead = true;
            }
            data.user_id = parseInt(user_id);
            saveNotification(data);
        }
    }catch(e){
        console.log("publish error.\n" + packet.payload.toString());
    }
});

chatting_server.on('clientConnected', function(client) {
    if(chatroomUser.indexOf(client.id)<0){
        chatroomUser.push(client.id);
    }
    console.log("chatting room connected : " + chatroomUser);
});
chatting_server.on("clientDisconnected", function(client){
    chatroomUser.remove(client.id);
    console.log("chatting room disconnected : " + client.id);
});
var mqtt = require('mqtt');

var mqtt_client = mqtt.connect("mqtt://localhost:" + constants.mqtt_notification_server);

chatting_server.on('published', function(packet, client) {
    try{
        let keys = packet.topic.split("/");
        let type = keys[1];
        let user_id = keys[3];
        let data = JSON.parse(packet.payload.toString());
        if(type=="chatting"){
            if(data.sender==undefined) data.sender = parseInt(client.id);
            data.reciever = parseInt(user_id);
            saveChatting(data);
            if(chatroomUser.indexOf(user_id)<0){
                let notification = {
                    type: constants.notification_type.chatting,
                    content: JSON.stringify({
                        chat_user: data.sender,
                        message: "A new message has arrived."
                    })
                }
                mqtt_client.publish(constants.mqtt_notification_prefix + user_id, JSON.stringify(notification));
            }
        }
    }catch(e){
        console.log("publish error.\n" + packet.payload.toString());
    }
});

function saveNotification(data){
    if(data.user_id!=undefined && data.type!=undefined && data.content!=undefined){
        if(data._id==undefined){
            Notification.find().sort([["_id", "descending"]]).limit(1).exec(function(err, notifications){
                data._id = notifications.length>0 ? notifications[0]._id + 1 : 0;
                saveNotification(data);
            });
        }else{
            let notification = new Notification(data);
            notification.send_date = new Date()
            notification.save(function(err){
                if(err){
                    data._id++;
                    console.log("Duplicate _id.");
                    saveNotification(data);
                }else{
                    console.log("Notification saved successfully.");
                }
            });
        }
    }
}
function saveChatting(data){
    if(data.sender!=undefined && data.reciever!=undefined && data.type!=undefined && data.content!=undefined){
        if(data._id==undefined){
            Chatting.find().sort([["_id", "descending"]]).limit(1).exec(function(err, chattings){
                data._id = chattings.length>0 ? chattings[0]._id + 1 : 0;
                saveChatting(data);
            });
        }else{
            let chatting = new Chatting(data);
            chatting.send_date = new Date();
            chatting.save(function(err){
                if(err){
                    data._id++;
                    console.log("Duplicate _id");
                    saveChatting(data);
                }else{
                    console.log("Chatting saved successfully.");
                    ChatList.update(
                        {$or: [{user_id: data.sender, linked_user: data.reciever}, {user_id: data.reciever, linked_user: data.sender}]},
                        {last_message: data.content, last_time: new Date()}, {multi: true}, function(err){
                        if(err){
                            console.log(err);
                        }else{
                            console.log("ChatList modified successfully.");
                        }
                    });
                }
            });
        }
    }
}
chatting_server.on('ready', setup);
notification_server.on('ready', setup);

function setup() {
    console.log('MQTT Server: Mosca server is up and running');
}
