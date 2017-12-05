function gondolaAnalysis (aThrust, payLoadMass)
%This function gives safty factors and dimension for the bearing arms,
%torsion hinge to gondola washers, the required motor torque, the required
%motor force, the required braking force, the required acceleration, 
%More specifically it calculates the worst case reaction forces on the
%screws holding the motor hinge to the gonodla. It computes a safety factor
%for the compresive stresses from the screws on the 3D printed gonodla.
%it calculated the forces acting on the gondola bearing arms.
%it computes the acceleration of the gondola in the specified conditions 
%Format for forces/reactions arrays:[locX locY locZ Fx Fy Fz Mx My Mz]
%M [ density Sut Suc Sy E brittle ] - information of the material
%All lengths/distances are in [m] other units are specified

%%%%%%%%%%%%%%%%%%%%%%%% SET VARIABLES %%%%%%%%%%%%
Ls = 0.08;          %distance from screw to center of torsion hinge 
Lhd = 0.02185;      %distance in y from torsion hingle to friction wheel contact point 
hingeAngle = pi/4;  %angle of torsion hinge [rads] yx 
Hdrive = 0.021125;  %height of friction wheel contact point above face of gond
rFw = 0.0127;       %friction wheel radius
rMs = 0.00147;      %motor shaft radius
Lrx = 0.00925;      %motor shaft length

La = 0.005;         %length in y from torsion hinge to gondola screw a 
Lb = 0.021;         %length in y from torsion hinge to gondola screw b
Dwashero = 0.004;   %outer gondola/hinge screw washer diameter
Dwasheri = 0.003;   %inner gondola/hinge screw washer diameter

Mu = 0.65;          %frictionwheel to keel coefficient of friction
Muwasher = 0.2;     %washer to gondola coefficent of friction

Larm = 0.03597;      %length of straigt section of bearing arm 
Lcurvez = 0.00919;   %length of cruved section of bearing arm in z
Lcurvey = 0.00816;  %length of cruved section of bearing arm in y

%available motor torques in Ozin
motorTorques = [2 4 9 15 22 30 40 50 60 70 125];

%available linear actuator holding force [N]
holdingForces = [12 22 45 80];

for i = 1:length(motorTorques) %convert torques to Nm
motorTorques(i) = motorTorques(i)*0.0070615518333333;
end

Tw = motorTorques(1);

gondSpecs = [
0.066    %1length in x of one gondola car
0.046        %2width in y of gondola 
0.038        %3height in z of gondola
-0.0405    %4center of gravity in x of gondola 1
0.0001      %5center of gravity in y of gondola 1
-0.01997    %6center of gravity in z of gondola 1
0.03524     %7center of gravity in x of gondola 2
-0.0003     %8center of gravity in y of gondola 2
-0.01566     %9center of gravity in z of gondola 2
0.09777      %10mass of gondola 1 in kg
0.208      %11mass of gondola 2 in kg
-0.07946    %12position of brake in x  
0.03259];     %13height of brake in z   

gondSpecs(10) = gondSpecs(10) + payLoadMass/2;
gondSpecs(11) = gondSpecs(11) + payLoadMass/2;

%[ density Sut Suc Sy E brittle ] - information of the material
nylon12 = [1130 38.5*10^6 6*10^6 28*10^6 1.138*10^9 1]; % matweb unrenforced
steel = [8000 420*10^6 250*10^6 320*10^6 200*10^9 0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%slip prevention and required motor torque 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

worstCaseAcceleration = 0;
i = 0;
while worstCaseAcceleration >= 0;
    Tspring = 1.5 * (Tw * sqrt(Lhd^2+Hdrive^2))/(rFw * Mu); %motor torsion spring torque
    Fspring =  Tspring /(sqrt(Lhd^2+Hdrive^2)); %force of spring acting on friction wheel
    Fnfric =  -Fspring; % normal force of frction wheel equal to spring for
    worstCaseAcceleration = gondolaForces(gondSpecs, -pi/2, 0, 0, aThrust, -Tw, Fnfric, 0,0);
    if worstCaseAcceleration >= 0;
        i=i+1;
    end
    Tw = motorTorques(i);
end

Fw = Tw/rFw; %driving force of motor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Gondola motor shaft analysis 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

shaftTensor = zeros(3,3);
shaftTensor(1,1) = (4*Fspring*Lrx)/(pi*rMs^3);
shaftTensor(3,3) = (4*Fw*Lrx)/(pi*rMs^3);
shaftTensor(1,3) = (-2*Tw)/(pi*rMs^3);
shaftTensor(3,1) = shaftTensor(1,3);
nMotorShaft = cauchy(shaftTensor,steel);

if nMotorShaft < 3
    disp('we goin need a beefier motor shaft');
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculating screw forces and compressive safety factor for screw
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%friction wheel contact point force, forces are acting in x,y',z' must be
%rotated to y and z
motorForces = [0 Lhd Hdrive Fw 0 Fnfric 0 0 0;];
motorForces = rotate(motorForces, 0, hingeAngle, 2, 1);

%worst reaction forces of hinge/gondola screws, almost all reaction from screw a    
gondScrewReactionsWorst = [ -Ls La 0 1 1 1 2 3 0; 
                             Ls Lb 0 0 1 0 2 3 0;];

gondScrewReactionsWorstSolved = forceSolver(motorForces, gondScrewReactionsWorst);

Fbolt = sqrt(gondScrewReactionsWorstSolved(1,4)^2+gondScrewReactionsWorstSolved(1,5)^2)... 
    /Muwasher + gondScrewReactionsWorstSolved(1,6);

Ncompressive = 0;
while Ncompressive < 3
    Ncompressive = nylon12(3)/ (Fbolt/(pi*(0.5*(Dwashero-Dwasheri))^2));
    if Ncompressive < 3
        Dwashero = Dwashero + 0.0005;
    end
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Required braking force from linear actuator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[reqAc,~,~] = gondolaForces(gondSpecs, -pi/2, 0, 0, aThrust, 0, Fnfric, 0,0);

[~,~,brakeForce] = gondolaForces(gondSpecs, -pi/2, 0, 0, aThrust, 0, Fnfric, -reqAc,0);
reqActuatorForce = abs(brakeForce(6));

maxBrakeForce = 0;
i = 1;

while maxBrakeForce < reqActuatorForce 
    maxBrakeForce = holdingForces(i);
    if maxBrakeForce > reqActuatorForce || i == 4
        break;
    else
        i = i+1;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Gondola Bearing Arm stress Analysis 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~, minArmForce, ~] = gondolaForces(gondSpecs, -pi/2, 0, 0, aThrust, 0, Fnfric, 0,0);
[~, maxArmForce, ~] = gondolaForces(gondSpecs, 0, -pi/2, 0, aThrust, 0, Fnfric, 0,-maxBrakeForce);

armRadius = 0.0015;
E = nylon12(1,5); 

%%%%%%%%%finding force moment couple %%%%%%%%%

maxArmForces = [0 Lcurvey Larm+Lcurvez 0 maxArmForce -maxArmForce 0 0 0];
maxCouple = forceSolver(maxArmForces, [0 0 Larm 0 1 1 1 0 0]);

minArmForces = [0 Lcurvey Larm+Lcurvez 0 minArmForce -minArmForce 0 0 0];
minCouple = forceSolver(minArmForces, [0 0 Larm 0 1 1 1 0 0]);

%%%%%%%%% arm deflection %%%%%%%%%%%%%%%

armDeflection = 1;
while armDeflection > 0.0025
    A = pi*armRadius^2;
    I = (pi/4) * armRadius^2;
    armDeflection = sqrt(((maxCouple(1,6)*Larm)/(A*E))^2 + ((maxCouple(1,5)*Larm^3)/...
                    (3*E*I) + (maxCouple(1,7)*Larm^2)/(2*E*I))^2);
    if armDeflection > 0.0025
        armRadius = armRadius + 0.0005;
    end
end

%%%%%%%%% arm inner corner stress %%%%%%%%%%%%%%%
nArmMax = 0;
while nArmMax < 5
    A = pi*armRadius^2;
    I = (pi/4) * armRadius^2;
    tensorMax = zeros(3,3);
    tensorMax(2,2) = maxCouple(1,5)/A;
    tensorMax(3,3) = (maxCouple(1,5)*Larm*armRadius)/I + (maxCouple(1,7)*armRadius)/I;
    nArmMax = cauchy(tensorMax,nylon12);
    if nArmMax < 5
        armRadius = armRadius + 0.0005;
    end
end

%%%%%%%%% arm fatigue analysis %%%%%%%%%%%%%%%
stressMin = 0;
stressMax = 10^10;

while abs(stressMax-stressMin) > 17*10^6
    A = pi*armRadius^2;
    I = (pi/4) * armRadius^2;
    
    tensorMax = zeros(3,3);
    tensorMax(2,2) = maxCouple(1,5)/A;
    tensorMax(3,3) = (maxCouple(1,5)*Larm*armRadius)/I + (maxCouple(1,7)*armRadius)/I;
    stressMax = nylon12(2)/(cauchy(tensorMax,nylon12));
    
    tensorMin = zeros(3,3);
    tensorMin(2,2) = minCouple(1,5)/A;
    tensorMin(3,3) = (minCouple(1,5)*Larm*armRadius)/I + (minCouple(1,7)*armRadius)/I;
    stressMin = nylon12(2)/(cauchy(tensorMin,nylon12));
    
    if abs(stressMax-stressMin) > 17*10^6
        armRadius = armRadius + 0.0005;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Snap fit analysis and required cut depth and angle 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rSnap =     0.003175;
snapCut =   0.001;
snapDef=    0.001;
Lsnap =     0.01;
theta =     acos((rSnap-snapCut)/rSnap);
Isnap =     (rSnap^4)/8*(theta-sin(theta)+2*sin(theta)*(sin(theta/2))^2);
c =         rSnap - 4/3 * rSnap * ((sin(theta/2))^3)/(theta-sin(theta))...
            +snapCut;  
nSnap = 0;

while nSnap <= 1.5
Freq = (3*snapDef*nylon12(5)*Isnap)/Lsnap^3;
stressSnap = (Freq*Lsnap*c)/Isnap;
nSnap = nylon12(2)/stressSnap;
    if nSnap <= 1.5
        Lsnap = Lsnap+0.0001;
    end
end

snapAngle = (Freq*Lsnap^2)/(2*nylon12(5)*Isnap);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Outputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Dwashero = 1000*Dwashero;
bearingArmDiameter = 2000*armRadius;
Lsnap = 1000*Lsnap;
snapAngle = (180/pi)* snapAngle;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LOG Outputs useful data to the log file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

logFile = 'groupRE3_LOG.txt';
logFolder = ('../Log');
MATLABFolder = ('../MATLAB');
swEqnFolder = ('../Solidworks/Equations');

% append to the file
cd(logFolder)
fid = fopen(logFile, 'a+');
fprintf(fid, '\n***Gondola Analysis Outputs***\r\n');
fprintf(fid, ['Washer outter diamter: ' , num2str(Dwashero) 'mm\r\n' ]);
fprintf(fid, ['Bearing arm diameter: ' , num2str(bearingArmDiameter) 'mm\r\n']);
fprintf(fid, ['Snapfit cut depth: ' , num2str(Lsnap) 'mm\r\n']);
fprintf(fid, ['Snapfit edge bevel angle: ', num2str(snapAngle) '�\r\n']);
fprintf(fid, ['The required spring torque of the torsion spring is: ', num2str(Tspring) 'Nm\r\n']);
fprintf(fid, ['Linear actuator force: ', num2str(maxBrakeForce) 'N\r\n']);
if maxBrakeForce == 80
    fprintf(fid, 'Linear actuator force of 80N must be constantly supplied power while holding position\r\n');
elseif maxBrakeForce < reqActuatorForce 
    fprintf(fid, 'Linear actuator force may not be sufficient\r\n');
    fprintf(fid, ['Consider choosing linear actuator with force greater than ', num2str(reqActuatorForce) 'N\r\n']);
end

fclose(fid);
cd(MATLABFolder);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Write to text files for sw
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd(swEqnFolder)
fid = fopen('3001-GONDOLA1-EQUATIONS.txt', 'w+t');
fprintf(fid, ['"BArmDia"= ',num2str(bearingArmDiameter) '[mm]''Bearing arm diameter\n']);
fprintf(fid, ['"bearingcutdepth"= ',num2str(Lsnap) '[mm]''depth of the bearing snap fit cut\n']);
fprintf(fid, ['"cutangle"= ',num2str(snapAngle) '[mm]''cut angle of the snapfit\n']);
fclose(fid);

fid = fopen('3007-WASHER-EQUATIONS.txt', 'w+t');
fprintf(fid, ['"doWasher"= ',num2str(Dwashero) '[mm]''The outside diameter of the washer\n']);
fclose(fid);
cd('../../MATLAB');
end 