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

Tw = 0.1;           %motor torque [Nm]

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
g = -9.81;           %acceleration due to gravity [m/s^2]

Lbearingx = 0.03682;%distance in x from bearing contact to gondola axle
Lbearingy = 0.00328;%distance in y from bearing contact to center of gondola
Hbearing = 0.03954; %height in z from bearing contact to surface of gondola

Lgond = 0.113515;   %length in x of one gondola car
Wgond = 0.06;       %width in y of gondola 
Hgond = 0.06;       %height in z of gondola
Lcm1x = -0.055;     %center of gravity in x or gondola 1
Lcm1y = 0;          %center of gravity in x or gondola 1
Lcm1z = -0.030;     %center of gravity in x or gondola 1
Lcm2x = 0.055;      %center of gravity in x or gondola 2
Lcm2y = 0;          %center of gravity in x or gondola 2
Lcm2z = -0.03;      %center of gravity in x or gondola 2
m1 = 0.5;           %mass of gondola 1 in kg
m2 = 0.5;           %mass of gondola 2 in kg
muBrake = 0.65;
brakePosx = - 0.115;
brakeposz = 0.02;
nylon6 = [1130 69*10^6 44*10^6 63*10^6 2.33*10^9 1]; % matweb unrenforced

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%slip prevention
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tspring = 1.5 * (Tw * sqrt(Lhd^2+Hdrive^2))/(rFw * Mu); %motor torsion spring torque
Fspring =  Tspring /(sqrt(Lhd^2+Hdrive^2)); %force of spring acting on friction wheel
Fnfric =  -Fspring; % normal force of frction wheel equal to spring for
Fw = Tw/rFw; %driving force of motor 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculating screw forces and compressive safety factor for screw
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%friction wheel contact point force, forces are acting in x,y',z' must be
%rotated to y and z
motorForces = [0 Lhd Hdrive Fw 0 Fnfric 0 0 0;];
    
%rotates forces acting on friction wheel into coordinate system 
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

gondScrewReactionsWorstSolved = forceSolver(hingeForce, gondScrewReactionsWorst);

Fbolt = sqrt(gondScrewReactionsWorstSolved(1,4)^2+gondScrewReactionsWorstSolved(1,5)^2)... 
    /Muwasher + gondScrewReactionsWorstSolved(1,6);

Ncompressive = 0;
while Ncompressive < 3
    Ncompressive = Scompressive*10^6/ (Fbolt/(pi*(0.5*(Dwashero-Dwasheri))^2));
    Dwashero = Dwashero + 0.001;
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculating Gondola Bearing Arm Reactions and Acceleration 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pitchAngle = 0; %pitch of airship xz [rads]
thrustAngle = 0;    %angle of thrusters for acceration, 0 is straight forward xz[rads]
gondAngle = 0;      %angle between gondolas xz [rads]
m1 = 0.5;           %mass of gondola 1 in kg
m2 = 0.5;           %mass of gondola 2 in kg
aThrust = -1;       %magnitude of acceleration due to thrust [m/s^2]

%%%%%%%%%%%%%% Forces %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gondMotorForces = [-Ldrivex -Ldrivey Hdrive Fw 0 Fnfric 0 0 0; %acting on gond 1
                        Ldrivex Ldrivey Hdrive Fw 0 -Fnfric 0 0 0;];%acting on gond 2
               
%%%%rotating motorForces to account for coordinate system change and gondAngle
gondMotorForces(1,:) = rotate(gondMotorForces(1,:), 0, pi/4, 2, 1);
gondMotorForces = rotate(gondMotorForces, gondAngle, (pi)-hingeAngle, 5, 2);
    
weight = [Lcm1x Lcm1y Lcm1z 0 0 m1*g 0 0 0;      %acting on gond 1 
          Lcm2x Lcm2y Lcm2z 0 0 m2*g 0 0 0;];    %acting on gond 2 
     
%%%%rotating weights to account for pitch angle
weight = rotate(weight, pitchAngle, 0, 2, 2);
weight = rotate(weight, gondAngle, 0, 4, 2);
    
accelerationForce = [Lcm1x Lcm1y Lcm1z m1*aThrust 0 0 0 0 0;    %acting on gond 1 
                     Lcm2x Lcm2y Lcm2z m2*aThrust 0 0 0 0 0;];  %acting on gond 2
               
%%%%rotating accelerationForce to account for thrust angle
accelerationForce = rotate(accelerationForce, thrustAngle, 0, 2, 2);
accelerationForce = rotate(accelerationForce, gondAngle, 0, 4, 2);

gondForces =  [gondMotorForces ;  weight ; accelerationForce]        

%%%%%%%%%%%%%% reactions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gondReactions = [
    Lbearingx Lbearingy Hbearing 1 1 1 0 0 0;    %Reactions at bearing 4
    Lbearingx -Lbearingy Hbearing 1 1 1 0 0 0;   %Reactions at bearing 3
    -Lbearingx Lbearingy Hbearing 0 2 2 0 0 0;   %Reactions at bearing 2
    -Lbearingx -Lbearingy Hbearing 0 -3 3 0 0 0; %Reactions at bearing 1
    0 0 0 1 0 1 0 0 0;                           %acceleration of gondolas 
    0 0 0 0 0 0 1 0 0;];                        %moment

%rotate reaction position on front gondola
gondReactions(3:4,:) = rotate(gondReactions(3:4,:), gondAngle, 0, 1, 2);

%%%%%%%%%%%%%% Acceleration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gondReactionsSolved = forceSolver(gondForces, gondReactions, [1 0])

gondAcceleration = (-gondReactionsSolved(5,4))/(abs(gondReactionsSolved(5,4)))...
    *sqrt((gondReactionsSolved(5,4)^2)+(gondReactionsSolved(5,6)^2))/(m1+m2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Gondola Bearing Arm stress Analysis 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maxArmForce = 0;
Lcurvez = 0.01;
Lcurvey = 0.01;
Larm = 0.03;
armRadius = 0.001;
E = nylon6(1,5); 

%%%%%%%%%finding max arm force%%%%%%%%%
for i = 1:4   
    current = gondReactionsSolved(i,6);
    if current > maxArmForce
        maxArmForce = current;
    end 
end

if abs(gondReactionsSolved(1,6)-gondReactionsSolved(2,6)) >  maxArmForce
    maxArmForce = abs(gondReactionsSolved(1,6)-gondReactionsSolved(2,6))
end    
    
if abs(gondReactionsSolved(3,6)-gondReactionsSolved(4,6)) >  maxArmForce
    maxArmForce = abs(gondReactionsSolved(3,6)-gondReactionsSolved(4,6))
end 

%%%%%%%%%finding force moment couple %%%%%%%%%

armForce = [0 Lcurvey Larm+Lcurvez 0 -maxArmForce -maxArmForce 0 0 0];
couple = forceSolver(armForce, [0 0 Larm 0 1 1 1 0 0]);

%%%%%%%%% arm deflection %%%%%%%%%%%%%%%
armDeflection = 1;
while armDeflection > 0.0025
    A = pi*armRadius^2;
    I = (pi/4) * armRadius^2;
    armDeflection = sqrt(((couple(1,6)*Larm)/(A*E))^2 + ((couple(1,5)*Larm^3)/...
                    (3*E*I) + (couple(1,7)*Larm^2)/(2*E*I))^2)
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
    Narm = cauchy(tensor,nylon6)
    if Narm < 1.5
        armRadius = armRadius + 0.0005;
    end
end

%%%%%%%%% arm fatigue analysis %%%%%%%%%%%%%%%


function [gondAcceleration, maxArmForce] = gondola(pitchAngle, thrustAngle, gondAngle, aThrust, drive, brake)

%%%%%%%%%%%%%% Forces %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if drive = 0 %no driving force
    gondMotorForces = [-Ldrivex -Ldrivey Hdrive 0 0 Fnfric 0 0 0; %acting on gond 1
                       Ldrivex Ldrivey Hdrive 0 0 -Fnfric 0 0 0;];%acting on gond 2
end 

if drive = 1 %postive driving force
    gondMotorForces = [-Ldrivex -Ldrivey Hdrive Fw 0 Fnfric 0 0 0; %acting on gond 1
                       Ldrivex Ldrivey Hdrive Fw 0 -Fnfric 0 0 0;];%acting on gond 2    
end 

if drive = 2 %negative driving force
    gondMotorForces = [-Ldrivex -Ldrivey Hdrive -Fw 0 Fnfric 0 0 0; %acting on gond 1
                       Ldrivex Ldrivey Hdrive -Fw 0 -Fnfric 0 0 0;];%acting on gond 2
end 
               
%%%%rotating motorForces to account for coordinate system change and gondAngle
gondMotorForces(1,:) = rotate(gondMotorForces(1,:), 0, pi/4, 2, 1);
gondMotorForces = rotate(gondMotorForces, gondAngle, (pi)-hingeAngle, 5, 2);
    
weight = [Lcm1x Lcm1y Lcm1z 0 0 m1*g 0 0 0;      %acting on gond 1 
          Lcm2x Lcm2y Lcm2z 0 0 m2*g 0 0 0;];    %acting on gond 2 
     
%%%%rotating weights to account for pitch angle
weight = rotate(weight, pitchAngle, 0, 2, 2);
weight = rotate(weight, gondAngle, 0, 4, 2);
    
accelerationForce = [Lcm1x Lcm1y Lcm1z m1*aThrust 0 0 0 0 0;    %acting on gond 1 
                     Lcm2x Lcm2y Lcm2z m2*aThrust 0 0 0 0 0;];  %acting on gond 2
               
%%%%rotating accelerationForce to account for thrust angle
accelerationForce = rotate(accelerationForce, thrustAngle, 0, 2, 2);
accelerationForce = rotate(accelerationForce, gondAngle, 0, 4, 2);

if brake(1) = 1
    brakeForce = [brakePosx 0 brakePosz brake(2) 0 -abs(brake(2))/muBrake 0 0 0];
    gondForces =  [gondMotorForces ;  weight ; accelerationForce; brakeForce];  
else 
    gondForces =  [gondMotorForces ;  weight ; accelerationForce];
end 
    
%%%%%%%%%%%%%% reactions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gondReactions = [
    Lbearingx Lbearingy Hbearing 1 1 1 0 0 0;    %Reactions at bearing 4
    Lbearingx -Lbearingy Hbearing 1 1 1 0 0 0;   %Reactions at bearing 3
    -Lbearingx Lbearingy Hbearing 0 2 2 0 0 0;   %Reactions at bearing 2
    -Lbearingx -Lbearingy Hbearing 0 -3 3 0 0 0; %Reactions at bearing 1
    0 0 0 1 0 1 0 0 0;                           %acceleration of gondolas 
    0 0 0 0 0 0 1 0 0;];                         %moment

%rotate reaction position on front gondola
gondReactions(3:4,:) = rotate(gondReactions(3:4,:), gondAngle, 0, 1, 2);

%%%%%%%%%%%%%% Acceleration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gondReactionsSolved = forceSolver(gondForces, gondReactions, [1 0])

gondAcceleration = (-gondReactionsSolved(5,4))/(abs(gondReactionsSolved(5,4)))...
    *sqrt((gondReactionsSolved(5,4)^2)+(gondReactionsSolved(5,6)^2))/(m1+m2)

%%%%%%%%%finding max arm force%%%%%%%%%
for i = 1:4   
    current = gondReactionsSolved(i,6);
    if current > maxArmForce
        maxArmForce = current;
    end 
end

if abs(gondReactionsSolved(1,6)-gondReactionsSolved(2,6)) >  maxArmForce
    maxArmForce = abs(gondReactionsSolved(1,6)-gondReactionsSolved(2,6))
end    
    
if abs(gondReactionsSolved(3,6)-gondReactionsSolved(4,6)) >  maxArmForce
    maxArmForce = abs(gondReactionsSolved(3,6)-gondReactionsSolved(4,6))
end 

end