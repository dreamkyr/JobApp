var mongoose = require(mongoose);
var shareJobSchema = mongoose.Schema({
    _id: {type: Number, default: 0},
    user_id: {type: Number, ref: "tbl_user"},
    job_id: {type: Number, ref: "tbl_job"}
});

module.exports = mongoose.model("tbl_sharejob", shareJobSchema);
