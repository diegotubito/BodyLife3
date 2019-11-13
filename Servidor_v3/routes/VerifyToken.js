var express  = require('express');
var router = express.Router()
var admin = require('firebase-admin');
var jwt = require('jsonwebtoken')

var cuentaDeServicioProduction = "/usr/local/bin/package/BodyShaping/BodyShaping-9b3b28644cdd.json";
var cuentaDeServicioDevelopment = "/usr/local/bin/package/BodyShaping/core-gym-d3f0052fab3d.json";


//START FIREBASE INIT
var productionAppConfig = {
  credential: admin.credential.cert(cuentaDeServicioProduction)
};
var developmentAppConfig = {
  credential: admin.credential.cert(cuentaDeServicioDevelopment)
};
// Initialize another app with a different config
var production = admin.initializeApp(productionAppConfig, "production admin for verify token");
// Initialize another app with a different config
var development = admin.initializeApp(developmentAppConfig, "development admin for verify token");
//END FIREBASE INIT



function verifyToken(req, res, next) {
// idToken comes from the client app
  var token = req.headers['x-access-token'];

  if (!token)
    return res.status(403).send({ auth: false, message: 'No token provided.' });

    jwt.verify(token, 'Secret Password', function(err, user) {

         if (err) {
           return res.status(401).send(err);
         }
          let uid = user.uid;
           req.userId = uid;
           req.decoded = user;
           next();

       });
}

module.exports = verifyToken;
