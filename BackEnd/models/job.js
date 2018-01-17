var mongoose = require('mongoose');

var jobSchema = mongoose.Schema({
    _id:{ type: Number, default: 0 },
    title:String,
    referrer: {type: Number, ref: "tbl_user"},
    type: String,
    skills: [String],
    description: String,
    status: {type: Number, default: 0},
    price: Number,
    posted_date: Date,
    country: String,
    state: String,
    city: String,
    salary: String,
    hrphone_email:String,
    employer_name:String,
    proposed_users: [
        {
            profile: { type: Number, ref: "tbl_user"},
            contact_phone: String,
            contact_email: String,
        }
    ],
    accepted_user: {type: Number, ref: "tbl_user"},
    invited_users: [{type: Number, ref: "tbl_user"}],
    favorite_users: [{type: Number, ref: "tbl_user"}],
    hidden_users: [{type: Number, ref: "tbl_user"}],
    share_users: [{type: Number, ref: "tbl_user"}],
    share_dates: [Date]
});

module.exports = mongoose.model('tbl_job', jobSchema);
