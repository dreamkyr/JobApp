var mongoose = require('mongoose');

var notificationSchema = mongoose.Schema({
    _id:{ type: Number, default: 0 },
	user_id: { type: Number, ref: "tbl_user" },
	type: String,
	content: String,
    send_date: Date,
    isRead: {type: Boolean, default: false}
});

module.exports = mongoose.model('tbl_notification', notificationSchema);
