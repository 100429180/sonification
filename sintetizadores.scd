(
SynthDef(\Saw1,
{| freq=500, amp = 0.1, attack=1.5, release=0.5, gate=1, pos= -1.0,vibRate=8,vibDepth= 1,out=0|
 var env, modDuty, modTime, signal, vibrato;
     env=EnvGen.ar(Env.asr(attack, 1,release),gate:gate, doneAction:2);
vibrato=SinOsc.kr(vibRate, 0, vibDepth -1 ,1 );
		signal = Mix(Saw.ar((freq *vibrato)*[ 1, 0.001.midiratio ] , 1.0 ));
 OffsetOut.ar(out, Pan2.ar(signal, pos, amp)* env)
}
).send(s);


SynthDef(\Sine1,
{| freq=500, amp = 0.1, attack=1.5, release=0.5, gate=1, pos= -1.0,vibRate=8,vibDepth= 1,out=0|
 var env, modDuty, modTime, signal, vibrato;
     env=EnvGen.ar(Env.asr(attack, 1,release),gate:gate, doneAction:2);
vibrato=SinOsc.kr(vibRate, 0, vibDepth -1 ,1 );
		signal = Mix(SinOsc.ar((freq *vibrato)*[ 1, 0.001.midiratio ],0,1.0 ));
 OffsetOut.ar(out, Pan2.ar(signal, pos, amp)* env)
}
).send(s);

SynthDef(\itin_Verb3mono, {| in=30, revtime=0.50, roomSize=50, damping=0.62,inputbw=0.48,earlylevel= -11, taillevel= -13, out=0, drylevel= -3.0, spread=30,releaseVerb=0, attackVerb=0, gate=1|
	var reverb,input,signal, env;
	env = EnvGen.ar(Env.asr(attackVerb, 1,releaseVerb),gate:gate, doneAction:2);
	signal=In.ar(in,1);
	reverb=GVerb.ar(signal,roomSize, revtime, damping, inputbw, spread, drylevel.dbamp, earlylevel.dbamp, taillevel.dbamp);
	Out.ar(out,Mix(reverb));
}).add;

//formato synth. he de crear otro envolvente mayor que englova a la otra. Para qe no se corte el sonido
SynthDef(\waveMembrane1,{
|tension= 0.5, loss= 0.5, noiseLevel=0.4, attack1=0.001, release1=1  timeScale1=0.1, attack2=0.001, release2=3  timeScale2=0.1, gate=1,out=0,amp=1|
     var curve, excite, envelope, membrane, pan, gateDemand, globalEnvelope;
envelope= EnvGen.kr(Env.perc(attack1,release1),1,1,timeScale: timeScale1, doneAction: 0);
excite= PinkNoise.ar(noiseLevel)*envelope;
membrane=  MembraneCircle.ar(excite,tension.linlin(0,1,0.01,0.1),loss.linlin(0,1,0.999,0.999999));
globalEnvelope=EnvGen.kr(Env.perc(0,release2),gate, timeScale: timeScale2, doneAction: 2);
pan= Pan2.ar(membrane,0);
Out.ar(out,pan*amp*globalEnvelope)
}).add;


SynthDef(\itin_Verb3, {|in=30, revtime=0.50, roomSize=50, damping=0.62,inputbw=0.48,earlylevel= -11, taillevel= -13, out=0, drylevel= -3.0, spread=30,releaseVerb=0, attackVerb=0, gate=1|
var reverb,input,signal, env;
env = EnvGen.ar(Env.asr(attackVerb, 1,releaseVerb),gate:gate, doneAction:2);
signal=In.ar(in,1);
reverb=GVerb.ar(signal,roomSize, revtime, damping, inputbw, spread, drylevel.dbamp, earlylevel.dbamp, taillevel.dbamp);
Out.ar(out,reverb);
}).add;


)

Platform.userExtensionDir