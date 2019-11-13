var express  = require('express');
var router = express.Router()
var admin = require('firebase-admin');

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
var production = admin.initializeApp(productionAppConfig, "production admin");
// Initialize another app with a different config
var development = admin.initializeApp(developmentAppConfig, "development admin");
//END FIREBASE INIT

router.post('/:target/updateToken/:uid', function(req, res, next){
  //primero selecciono la base de dato con la que voy a trabajar
  if (req.params.target == "production") {
    admin = production;
  }  else if (req.params.target == "development") {
    admin = development;
  }
  //fin de seleccion de base de dato
  var uid = req.params.uid;

  admin.auth().revokeRefreshTokens(uid)
  //log error
  .catch(function (error) {
      console.log(error);
      res.send(error);
  })
  .then(() => {
    return admin.auth().getUser(uid);
  })
  .then((userRecord) => {
    res.send(userRecord);
    return new Date(userRecord.tokensValidAfterTime).getTime() / 1000;
  })
  .then((timestamp) => {
    console.log('Tokens revoked at: ', timestamp);
  });
})

router.post('/:target/registerNewUser', function(req, res, next)
{
  //primero selecciono la base de dato con la que voy a trabajar
  if (req.params.target == "production") {
    admin = production;
  }  else if (req.params.target == "development") {
    admin = development;
  }
//fin de seleccion de base de dato

  admin.auth().createUser({
   uid: req.body.uid,
   email: req.body.email,
   password: req.body.password,
   displayName: req.body.username,
   phoneNumber: req.body.phoneNumber,
   disabled: req.body.disabled,
  // photoURL: req.body.url,
   emailVerified: false
 })
 .then(function(userRecord) {
   // A UserRecord representation of the newly created user is returned
   console.log("Successfully created new user:", userRecord.uid);

  res.send(JSON.stringify({ "estado": "created",
                            "uid": userRecord.uid,
                            "displayName": userRecord.displayName,
                            "password": userRecord.password,
                            "email verificado": userRecord.emailVerified}));

 })
 .catch(function(error) {
   console.log("Error creating new user:", error);
   res.send(JSON.stringify({ "estado": "error",
                             "error": error}));

 });
});



router.post('/:target/updateUser', function(req, res, next)
{
  //primero selecciono la base de dato con la que voy a trabajar
  if (req.params.target == "production") {
    admin = production;
  }  else if (req.params.target == "development") {
    admin = development;
  }
//fin de seleccion de base de dato

  admin.auth().updateUser(req.body.uid, {
    email: req.body.email,
    password: req.body.password,
    displayName: req.body.username,
    phoneNumber: req.body.phoneNumber,
  //  photoURL: req.body.url,
    emailVerified: false,
    disabled: req.body.disabled
  })
    .then(function(userRecord) {
      // See the UserRecord reference doc for the contents of userRecord.
      console.log("Successfully updated user", userRecord.toJSON());
      res.send(JSON.stringify({ "estado": "updated"}));

    })
    .catch(function(error) {
      console.log("Error updating user:", error);
      res.send(JSON.stringify({ "estado": "error",
                                "error": error}));
    });
});

router.get('/:target/deleteUser/:uid', function(req, res, next)
{
  //primero selecciono la base de dato con la que voy a trabajar
  if (req.params.target == "production") {
    admin = production;
  }  else if (req.params.target == "development") {
    admin = development;
  }
//fin de seleccion de base de dato

  admin.auth().deleteUser(req.params.uid)
    .then(function() {
      console.log("Successfully deleted user");
      res.send(JSON.stringify({ "estado": "deleted"}));
    })
    .catch(function(error) {
      console.log("Error deleting user:", error);
      res.send(JSON.stringify({ "estado": "error",
                                "error": error}));
    });
});




  /* GET users by uid */
  router.get('/:target/getUserByUid/:uid', function(req, res, next) {

    //primero selecciono la base de dato con la que voy a trabajar
    if (req.params.target == "production") {
      admin = production;
    }  else if (req.params.target == "development") {
      admin = development;
    }
  //fin de seleccion de base de dato


    admin.auth().getUser(req.params.uid)
      .then(function(userRecord) {
        // See the UserRecord reference doc for the contents of userRecord.
        console.log("Successfully fetched user data:", userRecord.toJSON());
        res.send(JSON.stringify({ "datos": userRecord}));

        //res.send(userRecord.toJSON);
      })
      .catch(function(error) {
        console.log("Error fetching user data:", error);
        res.send(JSON.stringify({ "estado": "error",
                                  "error": error}));
      });
  });

  /* GET users by email */
  router.get('/:target/getUserByEmail/:email', function(req, res, next) {
    //primero selecciono la base de dato con la que voy a trabajar
    if (req.params.target == "production") {
      admin = production;
    }  else if (req.params.target == "development") {
      admin = development;
    }
  //fin de seleccion de base de dato


    admin.auth().getUserByEmail(req.params.email)
      .then(function(userRecord) {
        // See the UserRecord reference doc for the contents of userRecord.
        console.log("Successfully fetched user data:", userRecord.toJSON());
          res.send(JSON.stringify({ "datos": userRecord}));
      })
      .catch(function(error) {
        console.log("Error fetching user data:", error);
      });
  });

  /* GET all users */
  router.get('/:target/getAllUsers', function(req, res, next) {
    //primero selecciono la base de dato con la que voy a trabajar
    if (req.params.target == "production") {
      admin = production;
    }  else if (req.params.target == "development") {
      admin = development;
    }
  //fin de seleccion de base de dato

    function listAllUsers(nextPageToken) {
      // List batch of users, 1000 at a time.
      admin.auth().listUsers(1000, nextPageToken)
        .then(function(listUsersResult) {
            res.send(listUsersResult);
            listUsersResult.users.forEach(function(userRecord) {
            //console.log("user", userRecord.toJSON());



          });
          if (listUsersResult.pageToken) {
            // List next batch of users.
            listAllUsers(listUsersResult.pageToken)
          }
        })
        .catch(function(error) {
          console.log("Error listing users:", error);
        });
    }
    // Start listing users from the beginning, 1000 at a time.
    listAllUsers();

  });

module.exports = router;
