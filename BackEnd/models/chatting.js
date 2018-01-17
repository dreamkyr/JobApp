var mongoose = require('mongoose');

var chatingSchema = mongoose.Schema({
    _id:{ type: Number, default: 0 },
    sender: { type: Number, ref: "tbl_user" },
	reciever: { type: Number, ref: "tbl_user" },
    type: { type: String, default: "text" },
	content: String,
    send_date: Date,
	isRead: {type: Boolean, default: false}
});

module.exports = mongoose.model('tbl_chatting', chatingSchema);
