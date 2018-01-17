var mongoose = require('mongoose');

var chatListSchema = mongoose.Schema({
    _id:{ type: Number, default: 0, ref: "tbl_user" },
    user_id: Number,
	linked_user: { type: Number, ref: "tbl_user" },
    last_message: {type: String, default: ""},
    last_time: {type: Date, default: new Date()}
});

module.exports = mongoose.model('tbl_chat_list', chatListSchema);
