//********************************************** Configuración 1*********************************************

// Solo la nariz

~minAmp= 0!17; ~maxAmp= 0!17; // Silenciamos todas las articulaciones
~minFreq= 100; ~maxFreq= 500; // Frecuencias
~minVibDepth=0; ~maxVibDepth=1; // Vibración entre las que va a oscilar el sintetizador, controlado por el snap

// Normalización de la nariz
~norMaxDisp = 74;
~norMinDisp = 0;

~norMaxVel = 2241;
~norMinVel = 10;

~norMaxAcc = 41090;
~norMinAcc = 24;

~norMaxJerk = 1897142;
~norMinJerk = 576;

~norMaxSnap = 118680304;
~norMinSnap = 50636;

~norMaxPosX = 640;
~norMinPosX = 0;

~norMaxPosY = 480;
~norMinPosY = 0;

~maxAmp[0]=1; // Encendemos la nariz



//********************************************** Configuración 2*********************************************

// Solo las dos manos

~minAmp= 0!17; ~maxAmp= 0!17; // Silenciamos todas las articulaciones
~minFreq= 100; ~maxFreq= 500; // Frecuencias
~minVibDepth=0; ~maxVibDepth=1; // Vibración entre las que va a oscilar el sintetizador, controlado por el snap

// Normalización de las manos
~norMaxDisp = 391;
~norMinDisp = 0;

~norMaxVel = 11747;
~norMinVel = 19;

~norMaxAcc = 225568;
~norMinAcc = 40;

~norMaxJerk = 543220;
~norMinJerk = 552;

~norMaxSnap = 1358181299;
~norMinSnap = 7444;

~norMaxPosX = 640;
~norMinPosX = 0;

~norMaxPosY = 480;
~norMinPosY = 0;

~maxAmp[9..10]=1; // Encendemos las dos manos

//********************************************** Configuración 3*********************************************

// Manos y pies

~minAmp= 0!17; ~maxAmp= 0!17; // Silenciamos todas las articulaciones
~minFreq= 100; ~maxFreq= 500; // Frecuencias
~minVibDepth=0; ~maxVibDepth=1; // Vibración entre las que va a oscilar el sintetizador, controlado por el snap

// Normalización de las manos
// Normalización de las manos
~norMaxDisp = 20;
~norMinDisp = 0;

~norMaxVel = 117;
~norMinVel = 19;

~norMaxAcc = 225568;
~norMinAcc = 40;

~norMaxJerk = 5432;
~norMinJerk = 552;

~norMaxSnap = 1358181299;
~norMinSnap = 7444;

~norMaxPosX = 640;
~norMinPosX = 0;

~norMaxPosY = 480;
~norMinPosY = 0;
~maxAmp[9..10]=0.5; // Encendemos las dos manos
~maxAmp[15..16]=0.5; // Encendemos los dos pies


//********************************************** Configuración 4*********************************************

// Caderas

~minAmp= 0!17; ~maxAmp= 0!17; // Silenciamos todas las articulaciones
~minFreq= 100; ~maxFreq= 500; // Frecuencias
~minVibDepth=0; ~maxVibDepth=1; // Vibración entre las que va a oscilar el sintetizador, controlado por el snap

// Normalización de las manos
// Normalización de las manos
~norMaxDisp = 89;
~norMinDisp = 0;

~norMaxVel = 2280;
~norMinVel = 1;

~norMaxAcc = 60719;
~norMinAcc = 15;

~norMaxJerk = 2496814;
~norMinJerk = 366;

~norMaxSnap = 113945195;
~norMinSnap = 12548;

~norMaxPosX = 640;
~norMinPosX = 0;

~norMaxPosY = 480;
~norMinPosY = 0;

~maxAmp[11..12]=0.5; // Encendemos las dos manos


~articulaciones.add(\nose -> 0); //disp: 0-180; acc: 0-400.000; snap: 300.000- 1.000.000.000
~articulaciones.add(\leftEye -> 1);
~articulaciones.add(\rightEye -> 2);
~articulaciones.add(\leftEar -> 3);
~articulaciones.add(\rightEar -> 4);
~articulaciones.add(\leftShoulder -> 5);
~articulaciones.add(\rightShoulder -> 6);
~articulaciones.add(\leftElbow -> 7);
~articulaciones.add(\rightElbow -> 8);
~articulaciones.add(\leftWrist -> 9);
~articulaciones.add(\rightWrist -> 10);
~articulaciones.add(\leftHip -> 11);
~articulaciones.add(\rightHip -> 12);
~articulaciones.add(\leftKnee -> 13);
~articulaciones.add(\rightKnee -> 14);
~articulaciones.add(\leftAnkle -> 15);
~articulaciones.add(\rightAnkle -> 16);

~maxAmp[2]=0.5; // rightEye
~maxAmp[4]=0.5; // rightEar
~maxAmp[6]=0.5; // rightShoulder
~maxAmp[8]=0.5; // rightElbow
~maxAmp[10]=0.5; // rightWrist
~maxAmp[12]=0.5; // rightHip
~maxAmp[14]=0.5; //rightKnee
~maxAmp[16]=0.5; // rightAnkle