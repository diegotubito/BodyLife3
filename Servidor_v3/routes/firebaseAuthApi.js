var express  = require('express');
var router = express.Router()
var firebase = require('firebase');
var jwt = require('jsonwebtoken')
var bodyParser = require('body-parser')

router.use(bodyParser.urlencoded({extended: false}))
router.use(bodyParser.json({limit:'10mb'}))


var VerifyToken = require('./VerifyToken');

//START FIREBASE INIT
var productionAppConfig = {
  apiKey: "AIzaSyCPtNcb96j1QdEVtWe9gxf4-k3w0x0BjZg",
};
var developmentAppConfig = {
  apiKey: "AIzaSyD3hT5BLSqYRcybh_Hn5_ZzyKXFZUpuKxU",
};
// Initialize another app with a different config
var production = firebase.initializeApp(productionAppConfig, "production");
// Initialize another app with a different config
var development = firebase.initializeApp(developmentAppConfig, "development");
//END FIREBASE INIT


router.post('/:target/login', function (req, res, next) {
  //primero selecciono la base de dato con la que voy a trabajar
  if (req.params.target == "production") {
    firebase = production;
  }  else if (req.params.target == "development") {
    firebase = development;
  }
//fin de seleccion de base de dato
   var username = req.body.email
   var password = req.body.password

  //auth
    firebase.auth().signInWithEmailAndPassword(req.body.email, req.body.password)
        //get back promise, log user object's email address
        .then(function (user) {
            console.log("Successfully login")
          //  res.send(user);

          var tokenData = {
            username: username
            // ANY DATA
          }

          var token = jwt.sign(tokenData, 'Secret Password', {
             expiresIn: 60 * 60 * 24 // expires in 24 hours
          })

          var resultData = {
            username : user.username,
            uid : user.uid,
            displayName : user.displayName,
            email: user.email,
            email_verified : user.email_verified,
            phoneNumber: user.phoneNumber,
            photoURL : user.photoURL,
            lastLoginAt : user.lastLoginAt,
            createdAt : user.createdAt,
            token: token
            // ANY DATA
          }
          console.log("Successfully");
          res.send(resultData);


        })
        //log error
        .catch(function (error) {
            console.log(error);
            res.status(400).send(error);
        })


});

router.post('/:target/refreshToken', VerifyToken, function (req, res, next) {
  //primero selecciono la base de dato con la que voy a trabajar
  if (req.params.target == "production") {
    firebase = production;
  }  else if (req.params.target == "development") {
    firebase = development;
  }
//fin de seleccion de base de dato
   var username = req.body.email
   var password = req.body.password
  var tokenData = {
    username: username
    // ANY DATA
  }

  var token = jwt.sign(tokenData, 'Secret Password', {
     expiresIn: 60 * 60 * 24 // expires in 24 hours
  })

  var resultData = {
    token : token,
    // ANY DATA
  }
  res.send(resultData);


});

//MODULO PARA CHEQUEAR CONEXION
router.get('/currentUser', VerifyToken, function(req, res){
  var token = req.headers['x-access-token'];
  var resultData = {
    token : token,
    exp : req.decoded.exp,
    username : req.decoded.username
    // ANY DATA
  }
  res.send(resultData);
});


router.get('/:target/currentFirebaseUser',function(req,res, next){
  //primero selecciono la base de dato con la que voy a trabajar
  if (req.params.target == "production") {
    firebase = production;
  }  else if (req.params.target == "development") {
    firebase = development;
  }
//fin de seleccion de base de dato

    var user = firebase.auth().currentUser
    res.send(user);
})

router.get('/:target/getFirebaseToken',function(req,res, next){
  //primero selecciono la base de dato con la que voy a trabajar
  if (req.params.target == "production") {
    firebase = production;
  }  else if (req.params.target == "development") {
    firebase = development;
  }
  //fin de seleccion de base de dato

  firebase.auth().currentUser.getIdToken(/* forceRefresh */ true).then(function(idToken) {
    // Send token to your backend via HTTPS
    res.send(idToken);
    // ...
  }).catch(function(error) {
    // Handle error
    res.send(error);
  });
})

router.get('/:target/me', VerifyToken, function(req, res, next) {
  res.send(req.decoded);
});

module.exports = router;
