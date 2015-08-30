var express = require('express');
var user = express.Router();
var db = require('../lib/db_connection.js');
var debug = require('debug')('chat_application: router:user');

/* GET users listing. */
user.get('/', function(req, res, next) {
    res.send('respond with a resource');
});

user.get('/login', function(req, res) {
    db.query('SELECT userID from users', function(req, res) {
        console.log(req);
        console.log(res);
    });
    res.render('users/login');
});

user.post('/login', function(req, res) {
    db.query('SELECT * from users where userID="'+ req.body.username +'" and password="'+req.body.password+'"', function(err, result) {
        var isValidLogin = true;
        if (result.length == 0) {
            isValidLogin = false;
        }
        // res.redirect('./home', {isValidLogin: isValidLogin});
        res.render('users/home', {isValidLogin: isValidLogin});
    });
    
});

user.get('/home', function(req, res) {
    res.render('users/home');
})
module.exports = user;
