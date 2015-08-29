var express = require('express');
var router = express.Router();
var debug = require('debug')('kums:router:bhavalan');


var mySql = require('mysql');
var con = mySql.createConnection({
	host: 'localhost',
	user: 'root',
	password: 'subash123$',
	database: 'kums'
})
con.connect();




router.get('/register', function(req, res) {
	debug('inside registrartion');
	console.log(req.username);
	console.log(req.password);
	

	con.query('select * from users', function(err, rows, fields) {
	// con.query('insert into users(userID, firstName, password) values(d, f , g)', function(err, rows, fields) {
	  console.log(err);
	  console.log(rows);
	  // console.log(fields);
	  if (err) throw err;
	  // console.log('The solution is: ', rows[0].solution);
	  res.render('bhavalan/register', {result: rows});
	});

});

router.post('/register', function(req, res) {
	debug('inside registrartion submittttt ');
	// debug(req);
	debug(req.body.userName);
	debug(req.body.password);
	debug(req.body.firstName);


	con.query('insert into users(userID, firstName, password) values("'+ req.body.userName +'", "'+ req.body.firstName +'","'+ req.body.password +'")', function(err, rows, fields) {
	// con.query('insert into users(userID, firstName, password) values(d, f , g)', function(err, rows, fields) {
	  console.log(err);
	  console.log(rows);
	  // console.log(fields);
	  if (err) {
	  	console.log('-------------------------------------------');
	  	console.log('-------------------------------------------');
	  	console.log('-------------------------------------------');
	  	console.log('-------------------------------------------');
	  	console.log('-------------------------------------------');
	  	console.log('-------------------------------------------');
	  	
	  }
	  res.redirect('/b/register');
	  // console.log('The solution is: ', rows[0].solution);
	});


	// con.query('insert into users(userID, firstName, password) values(?, ?, ?)' [req.body.userName, req.body.firstName, req.body.password]), function(err, rows, fields) {
	//   console.log(err);
	//   console.log(rows);
	//   // console.log(fields);
	//   if (err) throw err;
	//   // console.log('The solution is: ', rows[0].solution);
	// });

	// con.end();
	// res.render('bhavalan/register');
	
});

module.exports = router;
 

// var express = require('express');
// var router = express.Router();

/* GET home page. */
// router.get('/', function(req, res, next) {
//   res.render('index', { title: 'Express' });
// });

// module.exports = router;
