var mongoose = require('mongoose');

var contactSchema = mongoose.Schema({
    _id:{ type: Number, default: 0, ref: "tbl_user" },
    user_id: Number,
	contact_user: { type: Number, ref: "tbl_user" },
    isShared: {type: Boolean, default: true},
    status: Number,
    favorite: {type: Boolean, default: false}
});

module.exports = mongoose.model('tbl_contact', contactSchema);
