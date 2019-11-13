//tranajo con dos proyectos: Principal y Secundario
//Principal: es la base de dato que usa el sistema de gestion del gimnasio.
//Segcundario: es la base de dato que se usa para los socios.

var express  = require('express');
var router = express.Router()

var VerifyToken = require('./VerifyToken');

var admin = require("firebase-admin");

var cuentaDeServicioProduction = "/usr/local/bin/package/BodyShaping/BodyShaping-9b3b28644cdd.json";
var cuentaDeServicioDevelopment = "/usr/local/bin/package/BodyShaping/core-gym-d3f0052fab3d.json";

var productionAppConfig = {
  credential: admin.credential.cert(cuentaDeServicioProduction),
  databaseURL: "https://bodyshaping-fc85e.firebaseio.com/"
};

var developmentAppConfig = {
  credential: admin.credential.cert(cuentaDeServicioDevelopment),
  databaseURL: "https://core-gym.firebaseio.com/"
};

// Initialize another app with a different config
var production = admin.initializeApp(productionAppConfig, "production");

// Initialize another app with a different config
var development = admin.initializeApp(developmentAppConfig, "development");

//FIN DE LA INICIALIZACION

//MODULO PARA CHEQUEAR CONEXION
router.get('/comprobarConexion', VerifyToken, function(req, res){
  res.send({ connection: 'ok' });
});

router.get('/:target/comprobarConexionFirebase/:ruta', function(req, res, next) {
  //primero selecciono la base de dato con la que voy a trabajar
  var baseDeDato = "";
  if (req.params.target == "production") {
    baseDeDato = production;
  }  else if (req.params.target == "development") {
    baseDeDato = development;
  }
//fin de seleccion de base de dato


 var rutaAcondicionada = req.params.ruta.replace(/:/gi, "/");
 let read_ref = baseDeDato.database().ref(rutaAcondicionada);

  var firebaseData = {};

  read_ref.once("value", function(snapshot) {
    firebaseData = snapshot.val();
    res.send(firebaseData);

  }, function(errorObject) {
    console.log("Error en la lectura." + errorObject.code);
    res.send({ status: 'error', error: error });

  });
});


//OTROS MODULOS
//devuelve un json, de la direccion requerida.
/* GET socios/v1/read/... */
router.get('/:target/read/:ruta', VerifyToken, function(req, res, next) {
  //primero selecciono la base de dato con la que voy a trabajar
  var baseDeDato = "";
  if (req.params.target == "production") {
    baseDeDato = production;
  }  else if (req.params.target == "development") {
    baseDeDato = development;
  }
//fin de seleccion de base de dato



 //fin de seleccion de base de dato

  var rutaAcondicionada = req.params.ruta.replace(/:/gi, "/");
  let read_ref = baseDeDato.database().ref(rutaAcondicionada);

  var firebaseData = {};

  read_ref.once("value", function(snapshot) {
    firebaseData = snapshot.val();
    res.status(200).send(firebaseData);

  }, function(errorObject) {
    console.log("Error en la lectura." + errorObject.code);
    res.status(errorObject.code).send(errorObject);

  });
});



/* POST socios/v1/write/... */
router.post('/:target/write/:ruta',VerifyToken, function(req, res) {
  //primero selecciono la base de dato con la que voy a trabajar
  var baseDeDato = "";
  if (req.params.target == "production") {
    baseDeDato = production;
  }  else if (req.params.target == "development") {
    baseDeDato = development;
  }
//fin de seleccion de base de dato

  var rutaAcondicionada = req.params.ruta.replace(/:/gi, "/");
  var db = baseDeDato.database();
  var ref = db.ref(rutaAcondicionada);

  if (!req.body) return res.sendStatus(400);
  ref.set(req.body, function(error) {
    if (error) {
      res.status(501).send(error);

    } else {
      res.status(200).send(req.decoded);
    }

  })
});


//Transaction
router.post('/:target/transaction/:ruta',VerifyToken, function(req, res) {
  //primero selecciono la base de dato con la que voy a trabajar
  var baseDeDato = "";
  if (req.params.target == "production") {
    baseDeDato = production;
  }  else if (req.params.target == "development") {
    baseDeDato = development;
  }
//fin de seleccion de base de dato


  var rutaAcondicionada = req.params.ruta.replace(/:/gi, "/");
  var db = baseDeDato.database();
  var ref = db.ref(rutaAcondicionada);

  //este bloque es para la transaccion y la fecha de modificacion
  ref.transaction(function(currentValue) {

    res.send();
    //ref.child("fechaModificacion").set(req.body["fechaModificacion"]) //actualizo la fecha
    return (currentValue || 0.0) + req.body["valor"]; // el valor puede ser positivo o negativo
  });

});


/* POST socios/v1/write/... */
router.post('/:target/remove/:ruta',VerifyToken, function(req, res) {
  //primero selecciono la base de dato con la que voy a trabajar
  var baseDeDato = "";
  if (req.params.target == "production") {
    baseDeDato = production;
  }  else if (req.params.target == "development") {
    baseDeDato = development;
  }
//fin de seleccion de base de dato

  var rutaAcondicionada = req.params.ruta.replace(/:/gi, "/");
  var db = baseDeDato.database();
  var ref = db.ref(rutaAcondicionada);

  if (!req.body) return res.sendStatus(400);
  ref.update(req.body, function(error) {
    if (error) {
      res.status(501).send(error);

    } else {
      res.status(200).send(req.body);
    }

  })
});




/* POST socios/v1/write/... */
router.post('/:target/update/:ruta', VerifyToken, function(req, res) {
  //primero selecciono la base de dato con la que voy a trabajar
  var baseDeDato = "";
  if (req.params.target == "production") {
    baseDeDato = production;
  }  else if (req.params.target == "development") {
    baseDeDato = development;
  }
//fin de seleccion de base de dato

  var rutaAcondicionada = req.params.ruta.replace(/:/gi, "/");
  var db = baseDeDato.database();
  var ref = db.ref(rutaAcondicionada);

  if (!req.body) return res.sendStatus(400);
  ref.update(req.body, function(error) {
    if (error) {
      res.status(501).send(error);

    } else {
      res.status(200).send(req.body);
    }

  })
});

module.exports = router;
