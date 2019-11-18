var express  = require('express');
var router = express.Router();

const Storage = require('@google-cloud/storage');
var VerifyToken = require('./VerifyToken');

const CLOUD_BUCKET_PRODUCTION = "bodyshaping-fc85e.appspot.com"
const storageProduction = Storage({
  projectId: 'bodyshaping-fc85e',
  keyFilename: '/usr/local/bin/package/BodyShaping/BodyShaping-9b3b28644cdd.json'
});
const bucketProduction = storageProduction.bucket(CLOUD_BUCKET_PRODUCTION);



//var cuentaDeServicioSecundaria = "./Socios-ad230fae1024.json";


const CLOUD_BUCKET_DEVELOPMENT = "core-gym.appspot.com"
const storageDevelopment = Storage({
  projectId: 'core-gym',
  keyFilename: '/usr/local/bin/package/BodyShaping/core-gym-d3f0052fab3d.json'
});
const bucketDevelopment = storageDevelopment.bucket(CLOUD_BUCKET_DEVELOPMENT);



/* POST socios/v1/write/... */
router.get('/delete/:ruta', function(req, res) {
  //primero selecciono la base de dato con la que voy a trabajar
  var bucketSeleccionado = "";
  if (req.params.target == "production") {
    bucketSeleccionado = bucketProduction;
  }  else if (req.params.target == "development") {
    bucketSeleccionado = bucketDevelopment;
  }
//fin de seleccion de base de dato

  var rutaAcondicionada = req.params.ruta.replace(/:/gi, "/");
  console.log("borrando archivo...");
  console.log(rutaAcondicionada);
  const file = bucketSeleccionado.file(rutaAcondicionada);
  const stream = file.delete().then((result) => {

    console.log("archivo borrado.");
    res.send({ status: 'archivo borrado' });
  }).catch((err) => {
    //console.log(err);
    console.log("El archivo no existe");
    res.send({ status: 'el archivo no existe' });


  });
});



// Returns the public, anonymously accessable URL to a given Cloud Storage
// object.
// The object's ACL has to be set to public read.
// [START public_url]
function getPublicUrl (filename) {

  return `https://storage.googleapis.com/${CLOUD_BUCKET_PRODUCTION}/${filename}`;
}
// [END public_url]

// Express middleware that will automatically pass uploads to Cloud Storage.
// req.file is processed and will have two new properties:
// * ``cloudStorageObject`` the object name in cloud storage.
// * ``cloudStoragePublicUrl`` the public url to the object.
// [START process]
function sendUploadToGCS (req, res, next) {
  if (!req.file) {
    return next();
  }
  //primero selecciono la base de dato con la que voy a trabajar
  var bucketSeleccionado = "";
  if (req.params.target == "production") {
    bucketSeleccionado = bucketProduction;
  }  else if (req.params.target == "development") {
    bucketSeleccionado = bucketDevelopment;
  }
//fin de seleccion de base de dato

  const gcsname = req.file.originalname;
  var rutaAcondicionada = req.params.ruta.replace(/:/gi, "/");

  console.log("Subiendo archivo...");
  const file = bucketSeleccionado.file(rutaAcondicionada + "/" + req.file.originalname);

  const stream = file.createWriteStream({
    metadata: {
      contentType: req.file.mimetype,

    }
  });


  stream.on('error', (err) => {
    req.file.cloudStorageError = err;
    next(err);
  });

  stream.on('finish', () => {
    req.file.cloudStorageObject = gcsname;
    file.makePublic().then(() => {
      req.file.cloudStoragePublicUrl = getPublicUrl(gcsname);
      next();
    });
  });

  stream.end(req.file.buffer);
}
// [END process]

// Multer handles parsing multipart/form-data requests.
// This instance is configured to store images in memory.
// This makes it straightforward to upload to Cloud Storage.
// [START multer]
const Multer = require('multer');
const multer = Multer({
  storage: Multer.MemoryStorage,
  limits: {
    fileSize: 500 * 1024 * 1024 // no larger than 500mb
  }
});
// [END multer]


module.exports = {
  getPublicUrl,
  sendUploadToGCS,
  multer
};

router.post('/:target/uploadFile/:ruta', VerifyToken,
    multer.single('image'),
    sendUploadToGCS,
    (req, res, next) => {

    let data = req.body;

    // Was an image uploaded? If so, we'll use its public URL
    // in cloud storage.
    if (req.file && req.file.cloudStoragePublicUrl) {
      data.imageUrl = req.file.cloudStoragePublicUrl;

      res.send(JSON.stringify({ "filename" : req.file.originalname,
                                "size" : req.file.size,
                              "url":req.file.cloudStoragePublicUrl}));
                                //si el valor es null, la fila se elimina.

    }

  }
);


//function to return the contents of the google file
var returnGcloudFileContents = (req) => {
  return new Promise((resolve, reject) => {
    //primero selecciono la base de dato con la que voy a trabajar
    var bucketSeleccionado = "";
    if (req.params.target == "production") {
      bucketSeleccionado = bucketProduction;
    }  else if (req.params.target == "development") {
      bucketSeleccionado = bucketDevelopment;
    }
  //fin de seleccion de base de dato

    var rutaAcondicionada = req.params.ruta.replace(/:/gi, "/");
    console.log("Bajando archivo " + rutaAcondicionada);
    var file = bucketSeleccionado.file(rutaAcondicionada);
    file.download().then((fileData) => {
        resolve(fileData[0]);
      }).catch((err) => {
        reject(`Attempt to access file returned error: ${err.code} - ${err.message}`);
      });
  });
};

//turn path into param, and pass it to the returnGcloudFileContents function
//ejemplo:
// http://127.0.0.1:3000/storage/v1/downloadFile/socios:0DxraVqcRosMfA8tdD6c.jpeg
router.get('/:target/downloadFile/:ruta', (req, res) => {


  returnGcloudFileContents(req).then((gcloudFile) => {
    //console.log(`Returned letsencrypt key: ${gcloudFile.toString()}`);
    //res.send(gcloudFile.toString());
    res.send(gcloudFile)
  }).catch((err) => {
    //  res.render('index', { title: 'el archivo no se encuentra' });
    //console.log(err);
    res.sendStatus(err);
  });
});




module.exports = router;
