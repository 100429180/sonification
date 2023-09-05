

a = [SensorData.new,SensorData.new];

//adjunsting the number of values over which calculate the mean , etc.
a[0].ltlen_( 200 ); // long term window length
a[0].stlen_( 5 ); // short term window length
//número de items para sacar la media
m=10
//que articulación

(

r=OSCdef('/message',{|msg, time, addr, port|
	var disp, vel, acc, jerk, snap,posx, posy, args, values, parameter;
	parameter= msg[0];
	args = msg[1..];
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
	~viewData= 1;
	~viewData2= 1;

	//m=[x,y,z].abs.mean.linlin(0,8,0,1) -0.03; //acceleration mean absolute
	a[0].addValue(acc[10]);
	a[0].stlen_( m );
	~viewData=a[0].shortMean ;

	a[1].addValue(disp[15]);
	a[1].stlen_( m );
	~viewData2= a[1].shortMean ;
	[~viewData,~viewData2].postln;

},'/message', nil, 57120
).enable

)


m=1
r.disable
r.enable



(
~viewData=1;
~plotter= SWPlotterMonitor.new( {[~viewData]  //what to plot
},
500, //nr of points to plot
2, // channels
0.0025, // plot dtime
1// write every n data points
).start;

)





