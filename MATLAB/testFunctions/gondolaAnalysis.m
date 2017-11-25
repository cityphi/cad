%%%%%%This code solves for forces and reactions on the gondola
%%%%%%More specifically it calculates the worst case reaction forces on the
%screws holding the motor hinge to the gonodla. It computes a safety factor
%for the compresive stresses from the screws on the 3D printed gonodla.
%it calculated the forces acting on the gondola bearing arms.
%it computes the acceleration of the gondola in the specified conditions 
%%%%%%Format for forces/reactions arrays:[locX locY locZ Fx Fy Fz Mx My Mz]
%%%%%%%%% M [ density Sut Suc Sy E brittle ] - information of the material
%%%%%%All lengths/distances are in [m] other units are specified
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%% SET VARIABLES %%%%%%%%%%%%
Tw = 0.01;          %motor torque [Nm]
Ls = 0.08;          %distance from screw to center of torsion hinge 
Lhd = 0.02185;      %distance in y from torsion hingle to friction wheel contact point 
hingeAngle = pi/4;  %angle of torsion hinge [rads] yx 
Hdrive = 0.021125;  %height of friction wheel contact point above face of gond
Ldrivex = 0.05;     %distance in x from drive to gondola axle
Ldrivey = 0.00362;  %distance in y from drive to center of gondola
rFw = 0.0127;       %friction wheel radius

La = 0.005;         %length in y from torsion hinge to gondola screw a 
Lb = 0.021;         %length in y from torsion hinge to gondola screw b
Dscrew = 0.003;     %gondola/hinge screw diameter 
Dwashero = 0.004;   %outer gondola/hinge screw washer diameter
Dwasheri = 0.003;   %inner gondola/hinge screw washer diameter

Mu = 0.65;          %frictionwheel to keel coefficient of friction
Muwasher = 0.2;     %washer to gondola coefficent of friction

Scompressive = 55;  %The compressive yield strength of Nylon 6 [Mpa]
g = -9.81;          %acceleration due to gravity [m/s^2]

Lbearingx = 0.03682;%distance in x from bearing contact to gondola axle
Lbearingy = 0.00328;%distance in y from bearing contact to center of gondola
Hbearing = 0.03954; %height in z from bearing contact to surface of gondola
nylon6 = [1130 69*10^6 44*10^6 63*10^6 2.33*10^9 1]; % matweb unrenforced
muBrake = 0.65;     %makesure this is chill

%%%%%%%%%%%%%%%%%%%%%INPUTS%%%%%%%%%%%%%%%%%%%
gondSpecs = [
0.113515    %length in x of one gondola car
0.06        %width in y of gondola 
0.06        %height in z of gondola
-0.055      %center of gravity in x or gondola 1
0           %center of gravity in x or gondola 1
-0.030      %center of gravity in x or gondola 1
0.055       %center of gravity in x or gondola 2
0           %center of gravity in x or gondola 2
-0.03       %center of gravity in x or gondola 2
0.5         %mass of gondola 1 in kg
0.5         %mass of gondola 2 in kg
-0.115      %position of brake in x 
0.02];      %height of brake in z
maxThrust = 1;

gondSpecs(1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%slip prevention
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Tspring = 1.5 * (Tw * sqrt(Lhd^2+Hdrive^2))/(rFw * Mu); %motor torsion spring torque
Fspring =  Tspring /(sqrt(Lhd^2+Hdrive^2)); %force of spring acting on friction wheel
Fnfric =  -Fspring; % normal force of frction wheel equal to spring for

worstCaseAcceleration = 0;

while worstCaseAcceleration >= 0;
    worstCaseAcceleration = gondolaForces(gondSpecs, -pi/2, 0, 0, maxThrust, -Tw, Fnfric, 0,0);
    if worstCaseAcceleration >= 0;
        Tw = Tw + 0.01;
    end
end
Tw

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculating screw forces and compressive safety factor for screw
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Fw = Tw/rFw %driving force of motor

%friction wheel contact point force, forces are acting in x,y',z' must be
%rotated to y and z
motorForces = [0 Lhd Hdrive Fw 0 Fnfric 0 0 0;]; 
motorForces = rotate(motorForces, 0, hingeAngle, 2, 1);

%reaction forces/moments acting at torsion spring hinge
hingeReactions = [0 0 0 1 1 1 1 1 1;];

%forces acting on hinge therefor negative
hingeForces = -forceSolver(motorForces, hingeReactions);

%rotating hinge force to gondola coordinate system
hingeForces = rotate(hingeForces, 0, hingeAngle, 2, 1);

%worst reaction forces of hinge/gondola screws, almost all reaction from screw a    
gondScrewReactionsWorst = [ -Ls La 0 1 1 1 2 3 0; 
                             Ls Lb 0 0 1 0 2 3 0;];

gondScrewReactionsWorstSolved = forceSolver(hingeForces, gondScrewReactionsWorst);

Fbolt = sqrt(gondScrewReactionsWorstSolved(1,4)^2+gondScrewReactionsWorstSolved(1,5)^2)... 
    /Muwasher + gondScrewReactionsWorstSolved(1,6);

Ncompressive = 0;
while Ncompressive < 3
    Ncompressive = Scompressive*10^6/ (Fbolt/(pi*(0.5*(Dwashero-Dwasheri))^2));
    Dwashero = Dwashero + 0.001;
end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Required braking force 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[reqAc,~,~] = gondolaForces(gondSpecs, -pi/2, 0, 0, maxThrust, 0, Fnfric, 0,0)

[~,~,brakeForce] = gondolaForces(gondSpecs, -pi/2, 0, 0, maxThrust, 0, Fnfric, -reqAc,0)
reqActuatorForce = abs(brakeForce(6))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Gondola Bearing Arm stress Analysis 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[~, minArmForce, ~] = gondolaForces(gondSpecs, 0, 0, 0, 0, 0, Fnfric, 0, 0)
[~, maxArmForce, ~] = gondolaForces(gondSpecs, 0, 0, 0, maxThrust, 0, Fnfric, 0,-40)
% [~, maxArmForce, ~] = gondolaForces(gondSpecs, 0, 0, 0, maxThrust, 0, Fnfric, 0,0)
% [~, maxArmForce, ~] = gondolaForces(gondSpecs, -pi/2, 0, 0, maxThrust, 0, Fnfric, -reqAc,0)

Lcurvez = 0.01;
Lcurvey = 0.01;
Larm = 0.03;
armRadius = 0.001;
E = nylon6(1,5); 

%%%%%%%%%finding force moment couple %%%%%%%%%

armForce = [0 Lcurvey Larm+Lcurvez 0 -maxArmForce -maxArmForce 0 0 0];
couple = forceSolver(armForce, [0 0 Larm 0 1 1 1 0 0]);

%%%%%%%%% arm deflection %%%%%%%%%%%%%%%
armDeflection = 1;
while armDeflection > 0.0025
    A = pi*armRadius^2;
    I = (pi/4) * armRadius^2;
    armDeflection = sqrt(((couple(1,6)*Larm)/(A*E))^2 + ((couple(1,5)*Larm^3)/...
                    (3*E*I) + (couple(1,7)*Larm^2)/(2*E*I))^2);
    if armDeflection > 0.0025
        armRadius = armRadius + 0.0005;
    end
end

%%%%%%%%% arm inner corner stress %%%%%%%%%%%%%%%
Narm = 0;
while Narm < 1.5
    A = pi*armRadius^2;
    I = (pi/4) * armRadius^2;
    tensor = zeros(3,3);
    tensor(2,2) = couple(1,5)/A;
    tensor(3,3) = (couple(1,5)*Larm*armRadius)/I + (couple(1,7)*armRadius)/I;
    Narm = cauchy(tensor,nylon6);
    if Narm < 1.5
        armRadius = armRadius + 0.0005;
    end
end

%%%%%%%%% arm fatigue analysis %%%%%%%%%%%%%%%