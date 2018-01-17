module.exports = {
    dburl : 'mongodb://127.0.0.1/jobappDB',
    jwtsecret: 'dragonjobapp',
    mqtt_chatting_server : 1883,
    mqtt_notification_server : 1884,
    mqtt_options : {
        username: 'eswara/jobapp/mqtt',
        password: 'sOuBQvsIveEIi2dnhpRi'
    },
    mqtt_notification_prefix: "jobapp/notification/client/",
    mqtt_chatting_prefix: "jobapp/chatting/client/",
    notification_type: {
        contact : "contact",
        job_award: "job_award",
        job_posted: "job_posted",
        chatting: "chatting"
    }
};
