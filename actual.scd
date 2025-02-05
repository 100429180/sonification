
/* Recibimos un mensaje de 86 elementos, siendo el primero el identificador del mensaje (/mensaje), seguido de distintos valores
correspondiendo cada cinco valores (siguiendo el orden desplazamiento, velocidad, aceleración, jerk y smoothness)
a una parte del cuerpo que sigue el siguiente orden
nose, leftEye, rightEye, leftEar, rightEar, leftShoulder, rightShoulder, leftElbow, rightElbow, leftWrist, rightWrist, leftHip, rightHip, leftKnee, rightKnee, leftAnkle, rightAnkle*/

(
SynthDef(\Saw1,
{| freq=500, amp = 0.1, attack=1.5, release=0.5, gate=1, pos= -1.0 |
 var env, modDuty, modTime, signal;
     env=EnvGen.ar(Env.asr(attack, 1,release),gate:gate, doneAction:2);

signal = Mix(Saw.ar(freq *[ 1, 0.001.midiratio ] , 1.0 ));
 OffsetOut.ar(0, Pan2.ar(signal, pos, amp)* env)
}
).send(s);
)






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



~mocapResp.value // Ejecutar esta línea para lanzar el responder

//
(
var joints=(0..10), senseWorldDisp = joints.size.collect{SensorData.new}, senseWorldAcc = joints.size.collect{SensorData.new},
senseWorldPosy = joints.size.collect{SensorData.new}, synths, silenceFunction;

synths=joints.size.collect{Synth(\Saw1, [\amp, 0.1])};

~stopThreshold = 0;

/*FUNCION PARA CORREGIR RUIDO DE FONDO
silence=if(relevantValue<~stopThreshold) {0}{1};
silence = joints.collect{|x,y| if(x<~stopThreshold) {0}{1}};

\amp, ControlSpec(~minAmp,~maxAmp,'lin').map(accShaped[y])* silence[y],*/

~minFreq= 100; ~maxFreq= 500; ~minAmp= 0; ~maxAmp= 1; ~ampCurve=2;

~dataMeanLengthAcc  =10 ;
~dataMeanLengthPosy= 10;
~dataMeanLengthDisp = 10;

~mocapResp.value;   //prendemos el responder
~funcionMensaje=('/message': {|args| var parameter, values, disp, vel, acc, jerk, snap, posx, posy, dispShaped, accShaped,posyShaped;


//args.postln;
//Funciones utilizadas para dividir en arrays distintos los valores del desplazamiento, la velocidad, la aceleración, el jerk y el smoothness
disp=args[(0,5..args.size-1)];

vel=args[(1,6..args.size-1)];
//vel.postcs;
acc=args[(2,7..args.size-1)];
//acc.postcs;
jerk=args[(3,8..args.size-1)];
//jerk.postcs;
snap=args[(4,9..args.size-1)];
//snap.postcs;
posx=args[(5,12..args.size-1)]; // x=0 en la esquina arriba a la izquierda de la pantalla, arriba a la derecha en persona. Rango de 0-640
//posx.postcs;
posy=args[(6,13..args.size-1)]; // y=0 arriba de la pantalla. Rango de 0-480
//posy.postcs;
//posy[0..].postln;

//normalización acceleración
//acc= acc.collect{|x| x.linlin(1000,6000,0,1)}; //Situamos como mínimo el valor de 1000 (que corresponderá al 0 al normalizar) y como máximo 6000 (que corresponderá al 1 al normalizar). Los valores de 1000 y 6000 son los valores entre los que, a ojo, se encuentra la aceleración.
disp= disp.collect{|x| x.linlin(0,100,0,1)};
vel= vel.collect{|x| x.linlin(0,1000,0,1)};
acc= acc.collect{|x| x.linlin(0,5453933,0,1)};
posx= posx.collect{|x| x.linlin(0,640,-1,1)}; //
posy= posy.collect{|x| x.linlin(0,480, 1,0)}; //
//jerk= jerk.collect{|x| x.linlin(0,100,0,1)};
//snap= snap.collect{|x| x.linlin(0,100,0,1)};
acc[0..10].postln;

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


joints.collect{|x,y| synths[y].set(\freq, ControlSpec(~minFreq, ~maxFreq,'exp').map(posyShaped[y]),
                                        \amp, ControlSpec(~minAmp,~maxAmp,~ampCurve).map(accShaped[y]),
                                          \pos,posx[y],


)};



}
);
)



~dataMeanLengthAcc  =  100 ;
~dataMeanLengthPosy= 1000;
~dataMeanLengthDisp =100;
//Config 1
~minFreq= 100; ~maxFreq= 2000; ~minAmp= 0; ~maxAmp= 0.94; ~ampCurve=2;




~simRoutine.play
