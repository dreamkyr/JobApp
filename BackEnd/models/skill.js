var mongoose = require('mongoose');

var skillSchema = mongoose.Schema({
    _id:{ type: Number, default: 0 },
	category_name: String,
    skills:[String]
});

module.exports = mongoose.model('tbl_skill', skillSchema);
