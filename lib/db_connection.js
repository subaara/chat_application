/*var mySql = require('mysql');
var con = mySql.createConnection({
	host: 'localhost',
	user: 'root',
	password: 'subash123$',
	database: 'kums'
})
con.connect();

con.query('select * from db;', function(err, rows, fields) {
  console.log(err);
  console.log(rows);
  // console.log(fields);
  if (err) throw err;
  // console.log('The solution is: ', rows[0].solution);
});

con.end();*/



var mySql = require('mysql');
var database = {};

database.query = function(query, callback) {
    var db = mySql.createConnection({
      host: 'localhost',
      user: 'root',
      password: 'subash123$',
      database: 'kums'
    });
    db.connect();
    db.query(query, function(err, result) {
        db.end();
        callback(err, result);
    });
}


module.exports = database;