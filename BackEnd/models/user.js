var mongoose = require('mongoose');
var bcrypt   = require('bcrypt-nodejs');

var userSchema = mongoose.Schema({
	_id:{ type: Number, default: 0 },
	email: String,
	password: String,
	verified: Boolean,
	job_title: String,
	created_date: Date,
	updated_date: Date,
	first_name: String,
	last_name: String,
	full_name: String,
	phone: String,
	birthday: Date,
	country: String,
	language: String,
	group: Number,
	photo: String,

	share: {type: Boolean, default: true},
	gender: String,
	state: String,
	city: String,
	code: String,
	courses: [
		{
			start: String,
			end: String,
			name: String,
			major: String
		}
	],
	orgnizations: [
		{
			start: String,
			end: String,
			name: String,
			major: String
		}
	],
	skills: [String],
	social_id: String,
	role_id: { type: Number, default: 2 }
});

userSchema.methods.generateHash = function(password) {
	return bcrypt.hashSync(password, bcrypt.genSaltSync(8), null);
};

userSchema.methods.validPassword = function(password) {
	return bcrypt.compareSync(password, this.password);
};

module.exports = mongoose.model('tbl_user', userSchema);
