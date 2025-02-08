
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
senseWorldPosy = joints.size.collect{SensorData.new}, senseWorldSnap = joints.size.collect{SensorData.new},percSeq, reverb, silence ;


~minFreq= 100; ~maxFreq= 500; ~minAmp= 0!17; ~maxAmp= 0.4!joints.size; ~ampCurve= 0!joints.size ;~reverbTime= 1.0; ~damping= 0.1; ~dryLevel= -2;

~dataMeanLengthAcc  =100 ;
~dataMeanLengthPosy= 100;
~dataMeanLengthDisp = 100;
~umbralSilencio= 0;
~durMean= 1.0;
~durSdev= 0.1;
~amp= 1;
~tension=0.1;
~loss=0.5;

percSeq= Pbind(\instrument,\waveMembrane1, \noiseLevel, Pgauss(0.5,0.2),\tension, Pfunc{~tension}, \loss,Pfunc{~loss}, \attack2, 0.00,\release2, 2,\dur, Pfunc{~durMean.gauss(~durSdev)}.trace, \panPos, -1,\timeScale2,1, \timeScale1,0.1, \amp, Pfunc{~amp}, \out, 30 ).play;

Pmono( \itin_Verb3, \out, 0, \in,30,\taillevel,-15, \revtime,0.75, \roomsize,143, \damping,0.17, \spread,30.0, \drylevel, -2,  \addAction, 1, \dur, 1).play;

~mocapResp.value;   //prendemos el responder
~funcionMensaje=('/message': {|args| var parameter, values, disp, vel, acc, jerk, snap, posx, posy, dispShaped, accShaped,posyShaped;


//args.postln;
//Funciones utilizadas para dividir en arrays distintos los valores del desplazamiento, la velocidad, la aceleración, el jerk y el smoothness
disp=args[(0,7..args.size-1)];
//disp.postcs;
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
disp= disp.collect{|x| x.linlin(0,200,0,1)};
vel= vel.collect{|x| x.linlin(0,100,0,1)};
acc= acc.collect{|x| x.linlin(200,40000,0,1)};
posx= posx.collect{|x| x.linlin(0,480,-1,1)}; //
posy= posy.collect{|x| x.linlin(0,640, 0,1)}; //
jerk= jerk.collect{|x| x.linlin(0,4800000,0,1)};
snap= snap.collect{|x| x.linlin(300000,1000000000,0.05,0.3)};
	//acc[9..10].postln;
	//acc[0..10].postln;
	//silence = joints.collect{|x,y| if(acc[x]<~umbralSilencio) {0}{1}};
	~durMean= acc[10].linlin(0,1,0.5,0.015);
	~amp=acc[0];
	~tension=posy[0];
	~loss=posx[0];
	~durSdev=snap[0];

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



}
);
)


~dataMeanLengthAcc  =  5 ;
~dataMeanLengthPosy= 10;
~dataMeanLengthDisp =100;
//Config 1
~minFreq= 100; ~maxFreq= 2000;

~minAmp= 0!17; ~maxAmp= 0.2!17; //las silencio todMas
~maxAmp.put(6, 0); //Silenciamos una articulación
~maxAmp.put(13, 0); //Silenciamos una articulación
~minAmp= 0!2; ~maxAmp= 0.1!1;
~maxAmp[0..2]=0.8
~maxAmp[9..10]=0.5;
~maxAmp= 0.0!17;  ~maxAmp[9]=0.5; //silenciams todo y activamos la nariz
~reverbTime= 11; ~damping= 0.5; ~dryLevel= -2;

~umbralSilencio=0.01;
~maxAmp.put(9, 0.6); //Silenciamos una articulación
~maxAmp.put(10, 0.60); //Silenciamos una articulación