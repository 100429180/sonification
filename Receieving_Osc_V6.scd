
/* Recibimos un mensaje de 86 elementos, siendo el primero el identificador del mensaje (/mensaje), seguido de distintos valores
correspondiendo cada cinco valores (siguiendo el orden desplazamiento, velocidad, aceleración, jerk y smoothness)
a una parte del cuerpo que sigue el siguiente orden
nose, leftEye, rightEye, leftEar, rightEar, leftShoulder, rightShoulder, leftElbow, rightElbow, leftWrist, rightWrist, leftHip, rightHip, leftKnee, rightKnee, leftAnkle, rightAnkle*/
//////////////////////////////////


//El Responder
(
 ~mocapResp={ OSCdef(\manejarMensaje, { |msg| //Recibimos los mensajes a través del puerto 57120, el puerto por defecto de Supercollider
var parameter, args;


parameter= msg[0];
args = msg[1..];
//args.postcs;

~funcionMensaje[parameter.asSymbol].value(args[0..]);
}, '/message',nil, 57120);}
)


// Función principal
(
var joints=(0..16), senseWorldDisp = joints.size.collect{SensorData.new}, senseWorldAcc = joints.size.collect{SensorData.new},
senseWorldPosy = joints.size.collect{SensorData.new}, senseWorldSnap = joints.size.collect{SensorData.new},synths, reverb, silence ;

~sintetizador = \Sine1;

synths=joints.size.collect{Synth(~sintetizador, [\amp, 0.01, \out, 30])};


~minFreq= 100; ~maxFreq= 500; ~minAmp= 0!17; ~maxAmp= 0.4!17; ~ampCurve= 0!17 ;~reverbTime= 1.0; ~damping= 0.1; ~dryLevel= -2; ~minVibDepth=0; ~maxVibDepth=1;~vibDepthCurve=0;

~dataMeanLengthAcc  =10 ;
~dataMeanLengthPosy= 10;
~dataMeanLengthDisp = 10;
~dataMeanLengthSnap = 10;
~umbralSilencio= 0;

// Valores máximo y mínimo de cada parámetro para normalizar
~norMaxDisp = 300;
~norMinDisp = 0;

~norMaxVel = 8000.0;
~norMinVel = 0;

~norMaxAcc = 496412.0;
~norMinAcc = 0;

~norMaxJerk = 1200000.0;
~norMinJerk = 0;

~norMaxSnap = 870681600.0;
~norMinSnap = 0;

~norMaxPosX = 640;
~norMinPosX = 0;

~norMaxPosY = 480;
~norMinPosY = 0;

reverb=2.collect{|x|Synth( \itin_Verb3mono, [\out, x, \in,30 +x,\taillevel,-12, \revtime,~reverbTime, \roomsize,143, \damping,~damping, \spread,30.0, \drylevel, ~dryLevel,  \addAction, 1, \dur, 1], addAction: \addToTail)};


~mocapResp.value;   //prendemos el responder
~funcionMensaje=('/message': {|args| var parameter, values, disp, vel, acc, jerk, snap, posx, posy, dispShaped, accShaped,posyShaped,snapShaped;


//args.postln;
//Funciones utilizadas para dividir en arrays distintos los valores del desplazamiento, la velocidad, la aceleración, el jerk y el smoothness
disp=args[(0,7..args.size-1)];

vel=args[(1,8..args.size-1)];
//vel.postcs;
acc=args[(2,9..args.size-1)];
//acc.postcs;
jerk=args[(3,10..args.size-1)];
//jerk.postcs;
snap=args[(4,11..args.size-1)];
//snap.postcs;
posx=args[(5,12..args.size-1)]; // x=0 en la esquina arriba a la izquierda de la pantalla, arriba a la derecha en persona. Rango de 0-640
//posx.postcs;
posy=args[(6,13..args.size-1)]; // y=0 arriba de la pantalla. Rango de 0-480
//posy.postcs;

//normalización acceleración
//acc= acc.collect{|x| x.linlin(1000,6000,0,1)}; //Situamos como mínimo el valor de 1000 (que corresponderá al 0 al normalizar) y como máximo 6000 (que corresponderá al 1 al normalizar). Los valores de 1000 y 6000 son los valores entre los que, a ojo, se encuentra la aceleración.
disp= disp.collect{|x| x.linlin(~norMinDisp,~norMaxDisp,0,1)};
vel= vel.collect{|x| x.linlin(~norMinVel,~norMaxVel,0,1)};
acc= acc.collect{|x| x.linlin(~norMinAcc,~norMaxAcc,0,1)};
posx= posx.collect{|x| x.linlin(~norMinPosX,~norMaxPosX,-1,1)}; //
posy= posy.collect{|x| x.linlin(~norMinPosY,~norMaxPosY, 0,1)}; //
jerk= jerk.collect{|x| x.linlin(~norMinJerk,~norMaxJerk,0,1)};
snap= snap.collect{|x| x.linlin(~norMinSnap,~norMaxSnap,0,1)};


// Función de silencio. Usada para que solo suene cuando supere un determinado umbral.
silence = joints.collect{|x,y| if(acc[x]<~umbralSilencio) {0}{1}};


// Hacemos la curva de desplazamiento más fluida para obtener un glissando y eliminar el jitter
joints.collect{|x,y| senseWorldDisp[y].addValue(disp[x])};
joints.collect{|x,y|senseWorldDisp[y].stlen_(~dataMeanLengthDisp)};// Hace la media de los últimos 10 valores, utilizado para eliminar el jitter
dispShaped=joints.collect{|x,y| senseWorldDisp[y].shortMean};

// Hacemos la curva de aceleración más fluida para obtener un glissando y eliminar el jitter
joints.collect{|x,y|senseWorldAcc[y].addValue(acc[x])};
joints.collect{|x,y|senseWorldAcc[y].stlen_(~dataMeanLengthAcc)};// Hace la media de los últimos 10 valores, utilizado para eliminar el jitter
accShaped=joints.collect{|x,y| senseWorldAcc[y].shortMean};


// Hacemos la curva de posición más fluida para obtener un glissando y eliminar el jitter
joints.collect{|x,y|senseWorldPosy[y].addValue(posy[x])};
joints.collect{|x,y|senseWorldPosy[y].stlen_(~dataMeanLengthPosy)};// Hace la media de los últimos 10 valores, utilizado para eliminar el jitter
posyShaped=joints.collect{|x,y| senseWorldPosy[y].shortMean};


	// Hacemos la curva de posición más fluida para obtener un glissando y eliminar el jitter
joints.collect{|x,y|senseWorldSnap[y].addValue(snap[x])};
joints.collect{|x,y|senseWorldSnap[y].stlen_(~dataMeanLengthSnap)};// Hace la media de los últimos 10 valores, utilizado para eliminar el jitter
snapShaped=joints.collect{|x,y| senseWorldSnap[y].shortMean};


joints.collect{|x,y| synths[y].set(
		\freq, ControlSpec(~minFreq, ~maxFreq,'exp').map(posyShaped[y]),
		\amp, ControlSpec(~minAmp[x],~maxAmp[x],~ampCurve[x]).map(accShaped[y]) *silence[y],
         \pos,posx[y],
		\vibDepth,ControlSpec(~minVibDepth.midiratio, ~maxVibDepth.midiratio,~vibDepthCurve).map(snap[y]),


)};

}
);
)


// CONTROLES GENERALES
~dataMeanLengthAcc  =  5 ; // Número de muestras cogidas para realizar la sonificación. A menor valor, más responsiva. A mayor valor, más tarda en sonar, pero más eficaz.
~dataMeanLengthPosy= 5;
~dataMeanLengthDisp =5;

~minFreq= 100; ~maxFreq= 2000; // Frecuencias entre las que va a oscilar el sintetizador, controlado por la altura (posy. La parte superior de la pantalla corresponde a maxFreq y la inferior a  minFreq.
~minAmp= 0!17; ~maxAmp= 0!17; // Amplitud entre las que va a oscilar el sintetizador, controlado por la aceleración (acc)
~minVibDepth=0; ~maxVibDepth=1; // Vibración entre las que va a oscilar el sintetizador, controlado por el snap (snap)


// Valores máximo y mínimo de cada parámetro para normalizar
~norMaxDisp = 300;
~norMinDisp = 0;

~norMaxVel = 8000.0;
~norMinVel = 0;

~norMaxAcc = 496412.0;
~norMinAcc = 0;

~norMaxJerk = 1200000.0;
~norMinJerk = 0;

~norMaxSnap = 870681600.0;
~norMinSnap = 0;

~norMaxPosX = 640;
~norMinPosX = 0;

~norMaxPosY = 480;
~norMinPosY = 0;







// Configuración 1: Solo la nariz
~minAmp= 0!17; ~maxAmp= 0!17; // Silenciamos todas las articulaciones
~minFreq= 100; ~maxFreq= 500; // Frecuencias
~minVibDepth=0; ~maxVibDepth=1; // Vibración entre las que va a oscilar el sintetizador, controlado por el snap

~norMaxDisp = 300;
~norMinDisp = 0;

~norMaxVel = 8000.0;
~norMinVel = 0;

~norMaxAcc = 496412.0;
~norMinAcc = 0;

~norMaxJerk = 1200000.0;
~norMinJerk = 0;

~norMaxSnap = 870681600.0;
~norMinSnap = 0;

~norMaxPosX = 640;
~norMinPosX = 0;

~norMaxPosY = 480;
~norMinPosY = 0;






//Config 1: solo las dos manos
~minFreq= 100; ~maxFreq= 500; // Frecuencias
~minAmp= 0!17; ~maxAmp= 0!17; // Silenciamos todas las articulaciones
~maxAmp[9..10]=1; // Encendemos las dos manos
~minVibDepth=0; ~maxVibDepth=1; // Vibración entre las que va a oscilar el sintetizador, controlado por el snap (snap)






//Config 2: solo la nariz
~minFreq= 100; ~maxFreq= 20000; // Frecuencias
~minAmp= 0!17; ~maxAmp= 0!17; // Silenciamos todas las articulaciones
~maxAmp[0]=1; // Encendemos la nariz
~minVibDepth=0; ~maxVibDepth=1; // Vibración entre las que va a oscilar el sintetizador, controlado por el snap (snap)




//~maxAmp.put(6, 0); //Silenciamos una articulación
//~maxAmp.put(13, 0); //Silenciamos una articulación
//~minAmp= 0!2; ~maxAmp= 0.1!1;
//~maxAmp[0..2]=0.8
~maxAmp[9..10]=0.5; // Encendemos las dos manos
~umbralSilencio=0;
//~maxAmp= 0.0!17;  ~maxAmp[9]=0.5; //silenciams todo y activamos una parte del cuerpo
~reverbTime= 11; ~damping= 0.5; ~dryLevel= -2;

~minVibDepth=0;
~maxVibDepth=1;
~vibDepthCurve=0;

~umbralSilencio=0.4;
~maxAmp.put(9, 0.6); //Silenciamos una articulación
~maxAmp.put(10, 0.60); //Silenciamos una articulación