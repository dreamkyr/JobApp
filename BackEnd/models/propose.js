var mongoose = require('mongoose');

var proposeSchema = mongoose.Schema({
    _id:{ type: Number, default: 0 },
    user_id: {type: String, ref: "tbl_user"},
    job: {type: Number, ref: "tbl_job"},
    proposed_time: Date,
    cover_letter: String,
    price: Number,
    state: Number
});

module.exports = mongoose.model('tbl_propose', proposeSchema);
