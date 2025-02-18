/* Código Javascript desarrollado por Gabriel Franco Ferrería como parte de su Trabajo de Fin de Grado del grado 
Ingeniería de Sonido e Imagen de la Universidad Carlos III de Madrid
Sonidificación en tiempo real a través de tecnologías web*/

// Creamos el mensaje declarado en el HTML que aparecerá hasta que cargue el vídeo
const div = document.querySelector("#message"); // Mensaje: Por favor, conceda los permisos necesarios para poder acceder a la webcam de su dispositivo
// Creamos el vídeo recibido por la webcam
const video = document.getElementById("video");
// Creamos el canvas donde asociaremos el vídeo y el esqueleto de POSENET
const canvas = document.getElementById("canvas");
const ctx = canvas.getContext("2d");

// Definimos el color de las líneas del esqueleto
//ctx.strokeStyle = "blue";
// Definimos el color de los círculos de posición del esqueleto
ctx.fillStyle = "rgb(255,255,0)";
// Definimos el ancho de las líneas de posición del esqueleto
//ctx.lineWidth = 3;

// Variable donde almacenaremos las poses actuales y las cuatro anteriores, utilizada para dar robustez al modelo y calcular las distintas métricas
// /desplazamiento, velocidad, aceleración, jerk y snap)
let poseHistory = [];
let poseActual = [];

// Creamos un nuevo método de POSENET donde vamos almacenando los datos recibidos en la variable 'poseHistory'
const poseNet = ml5.poseNet(video, {
  architecture: 'MobileNetV1',
  imageScaleFactor: 1,
  outputStride: 16, //Puede ser 8, 16 o 32. Cuanto menor es el valor, mejor detecta, pero provoca un mayor retardo. 
  flipHorizontal: false,
  minConfidence: 0.9,
  maxPoseDetections: 1,
  scoreThreshold: 0.9,
  nmsRadius: 20,
  detectionType: 'single',
  inputResolution: 513, //161, 193, 257, 289, 321, 353, 385, 417, 449, 481, 513, and 801. Cuanto mayor, más preciso pero más lento
  multiplier: 0.75, //1.0, 0.75, or 0.50. Cuanto mayor, más preciso pero más lento
  quantBytes: 2,
}, modelLoaded); // "single" para que solo detecte una pose ("multiple" en caso contrario)
let counter = 0; // Contador que detecta el número de poses, mostrado en la pantalla
const counterElement = document.getElementById("counter");

// Cargamos el modelo de PoseNet
poseNet.on('pose', (results) => {
  if (results.length > 0) { // Condición para comprobar si ha detectado alguna pose
    //console.log(results);
    poseHistory.unshift(results[0]);
    poseActual.unshift(results[0]); // Agregar la pose actual al inicio del array, results[0] porque poseNet detecta varias poses simultáneas, y solo queremos coger la primera
    counter++; // Incrementar el contador que refleja el número de poses que detecta en directo

    // Limitar el tamaño del array a 5 poses (actual y cuatro anteriores). Son necesarias para poder calcular las métricas. 
    if (poseHistory.length > 5) {
      poseHistory.pop(); // Eliminar la pose más antigua del array, de cara a quedarnos únicamente con las tres últimas y liberar espacio
    }

    if (poseActual.length > 1) {
      poseActual.pop(); // Eliminar la pose más antigua del array, de cara a quedarnos únicamente con las tres últimas y liberar espacio
    }

    //console.log(poseHistory); // Mostrar las poses en la consola. Contiene 5 poses, con las 17 partes del cuerpo

    // Actualizar el contador de poses detectadas en la página
    counterElement.textContent = counter.toString();
  }
});


// Función que se activa cuando el modelo de POSENET se carga. En este caso, refleja en la pantalla que el modelo ha cargado
function modelLoaded() {
  console.log("¡Modelo PoseNet cargado!");
  div.innerHTML = "¡Ya puedes ver tu esqueleto a través de PoseNet!";
}

// Una vez se carga el modelo POSENET, se carga la imagen recibida por la webcam

///----------PRUEBA--17/02/2025------------------------------------
// Configurar getUserMedia con una resolución específica
navigator.mediaDevices.getUserMedia({
  video: { width: 640, height: 480 }
}).then(function (stream) {
  video.srcObject = stream;
  video.play();
});
///----------PRUEBA HASTA AQUI-----------------------------------------
 
if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
  navigator.mediaDevices.getUserMedia({ video: true }).then(function (stream) { // En el caso de que reciba imagen a través de la webcam, lo muestra en la pantalla
    video.srcObject = stream;
    video.play();

    // Comprobación de las dimensiones de la imagen de la webcam
    let stream_settings = stream.getVideoTracks()[0].getSettings();
    console.log("Width: " + stream_settings.width);
    console.log("Height: " + stream_settings.height);
  });
}

// Función que dibuja un círculo en las posiciones detectadas del esqueleto
function drawKeypoints(keypointsAverages) { // Recibe como parámetro keypointsAverages, siendo este un array de la media de las posiciones de cada parte del cuerpo
  // de las cinco últimas poses detectadas, utilizado para dar una mayor robustez al modelo y que no tiemblen tanto las posiciones
  for (let j = 0; j < keypointsAverages.length; j++) { // Recorremos el array parte a parte del cuerpo para ir representando las posiciones del cuerpo
    let keypoint = keypointsAverages[j];

    if (keypoint.score > 0.5) { // Solo se considerará la posición detectada si tiene una confidencia mayor a este valor
      const { x, y, score, part } = keypoint; // Extraemos los paráemtros deseados de la parte del cuerpo en concreto

      // Dibujamos los círculos en las partes del cuerpo detectadas dentro de la pose
      ctx.beginPath();
      ctx.arc(keypoint.position.x, keypoint.position.y + 50, 10, 0, 2 * Math.PI);
      ctx.fill();
    }
  }
}

// Función que ordena los keypoints según un orden predefinido, así podemos asegurarnos acceder al array de la misma forma siempre
function sortKeypoints(keypoints) {
  const order = [
    "nose",
    "leftEye",
    "rightEye",
    "leftEar",
    "rightEar",
    "leftShoulder",
    "rightShoulder",
    "leftElbow",
    "rightElbow",
    "leftWrist",
    "rightWrist",
    "leftHip",
    "rightHip",
    "leftKnee",
    "rightKnee",
    "leftAnkle",
    "rightAnkle",
  ];

  keypoints.sort((a, b) => {
    const indexA = order.indexOf(a.part);
    const indexB = order.indexOf(b.part);
    return indexA - indexB;
  });

  return keypoints;
}


// Función utilizada para acceder a las coordenadas de cada una de las partes del cuerpo de cada pose. Además, establece dichas coordenadas como 0 cuando la score no es lo suficientemente elevada
function getKeypointsCoordinates() {
  const keypointsCoordinates = poseHistory.map((pose) => { // Obtiene las coordenadas de cada parte del cuerpo, así como la score de cada una de ellas
    const keypoints = pose.pose.keypoints;
    console.log(keypoints);
  });

  return keypointsCoordinates; // Devuelve un array donde las coordenadas X e Y de cada parte del cuerpo corresponde con la media de las coordenadas de las últimas tres poses detectadas
}




// Define una variable para almacenar los resultados de las métricas
let metricsResults = [];

// Representa el vídeo dentro del canvas para poder dibujar encima de él el esqueleto
function drawCameraIntoCanvas() {
  // Asegurarse de que el tamaño del canvas coincida con el tamaño del video, por eso hemos comprobado antes las dimensiones del vídeo capturado por la webcam
  canvas.width = video.videoWidth;
  canvas.height = video.videoHeight;

  ctx.drawImage(video, 0, 0, canvas.width, canvas.height); // Dibuja el vídeo en el canvas
  //console.log(poseHistory);
  if (poseActual.length > 0) { // Si ha detectado al menos una posición, comienza a representar los puntos y a calcular las métricas
    const pose = poseActual[0].pose; // Para representar los puntos, solo cogemos la última pose detectada
    const keypoints = pose.keypoints; // Extraemos las partes del cuerpo de la pose actual

    const keypointsCoordinates = getKeypointsCoordinates(); // Obtenemos las coordenadas de todas las posiciones. así como la score
    drawKeypoints(keypoints); // Representamos cada una de las partes del cuerpo de la última pose detectada

    // Calculamos las métricas para cada una de las partes del cuerpo de cada pose, utilizando poseHistorty en el fichero calculateMetrics.js
    const bodyParts = ['nose', 'leftEye', 'rightEye', 'leftEar', 'rightEar', 'leftShoulder', 'rightShoulder', 'leftElbow', 'rightElbow', 'leftWrist', 'rightWrist', 'leftHip', 'rightHip', 'leftKnee', 'rightKnee', 'leftAnkle', 'rightAnkle'];

    metricsResults = bodyParts.map(partName => calculateMetrics(partName));
    //console.log(metricsResults);
    enviarMensaje(metricsResults); //Envíamos un mensaje con todas las métricas de todas las partes del cuerpo a supercollider a través del puente de python (web-python-supercollider)

    // Recorre todas las partes del cuerpo y muestra las coordenadas en los elementos correspondientes
    /*for (const part in keypointsCoordinates) {
      const coordinates = keypointsCoordinates[part];
      const elementId = `${part}Coordinates`;
      const element = document.getElementById(elementId);
      element.textContent = `${part}: (${coordinates.x}, ${coordinates.y})`;
    }*/
  }

  // Solicitar el siguiente cuadro de animación
  requestAnimationFrame(drawCameraIntoCanvas);
}


// ------------------------------------------------------------------ Conexión con SuperCollider -----------------------------------------------------------------------//
var port = new osc.WebSocketPort({
  url: "ws://localhost:8081"
});

port.on("message", function (oscMessage) {
  $("#message").text(JSON.stringify(oscMessage, undefined, 2));
  console.log("message", oscMessage);
});

port.open();


// Función para enviar mensajes OSC, mandando un mensaje por cada pose detectada, conteniendo el desplazamiento, la velocidad, la aceleración, el jerk y el smoothness de cada parte del cuerpo en esa pose
/*var enviarMensaje = function (args) {
  const address = "/message";

  port.send({
    address: address,
    args: [
      { type: 's', value: args }
    ]
  });
}*/

/*var enviarMensaje = function (args) {
  const address = "/message";

  var argsArray = args.map(value => {
    if (typeof value !== 'undefined') {
      return { type: 's', value: value.toString() };
    } else {
      return { type: 's', value: '' };
    }
  });

  port.send({
    address: address,
    args: argsArray
  });
}*/

var enviarMensaje = function (args) {
  const address = "/message";

  var argsArray = args.flatMap(value => {
    if (typeof value !== 'undefined') {
      return value.toString().split(",");
    } else {
      return [];
    }
  });

  port.send({
    address: address,
    args: argsArray.map(value => ({ type: 'i', value: value }))
  });
}



// ------------------------------------------------------------------ Main -----------------------------------------------------------------------//

// Función principal del código JavaScript, donde ejecutamos en orden las funciones necesarias
function main() {
  drawCameraIntoCanvas();

}

// Ejecutamos la función principal del sistema
main();
