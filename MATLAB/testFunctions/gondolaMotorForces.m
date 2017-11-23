%%%%%%This code solves for forces and reactions on the gondola
%%%%%%More specifically it calculates the worst case reaction forces on the
%screws holding the motor hinge to the gonodla. It computes a safety factor
%for the compresive stresses from the screws on the 3D printed gonodla.
%it calculated the forces acting on the gondola bearing arms.
%it computes the acceleration of the gondola in the specified conditions 
%%%%%%Format for forces/reactions arrays:[locX locY locZ Fx Fy Fz Mx My Mz] 
%%%%%%All lengths/distances are in [m] other units are specified
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tw = 0.1;           %motor torque [Nm]

Ls = 0.08;          %distance from screw to center of torsion hinge 
Lhd = 0.02185;      %distance in y from torsion hingle to friction wheel contact point 
hingeangle = pi/8;  %angle of torsion hinge [rads] yx 
Hdrive = 0.021125;  %height of friction wheel contact point above face of gond
Ldrivex = 0.05;     %distance in x from drive to gondola axle
Ldrivey = 0.00362;  %distance in y from drive to center of gondola
rFw = 0.0127;       %friction wheel radius

La = 0.005;         %length in y from torsion hinge to gondola screw a 
Lb = 0.021;         %length in y from torsion hinge to gondola screw b
Dscrew = 0.003;     %gondola/hinge screw diameter 
Dwashero = 0.005;   %outer gondola/hinge screw washer diameter
Dwasheri = 0.003;   %inner gondola/hinge screw washer diameter

Mu = 0.65;          %frictionwheel to keel coefficient of friction
Muwasher = 0.2;     %washer to gondola coefficent of friction

Scompressive = 55;  %The compressive yield strength of Nylon 6 [Mpa]
g = 9.81;           %acceleration due to gravity [m/s^2]

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

Tspring = 1.5 * (Tw * sqrt(Lhd^2+Hdrive^2))/(rFw * Mu); %motor torsion spring torque
Fspring =  Tspring /(sqrt(Lhd^2+Hdrive^2)); %force of spring acting on friction wheel
Fnfric =  -Fspring; % normal force of frction wheel equal to spring for
Fw = Tw/rFw; %driving force of motor 

%friction wheel contact point force, forces are acting in x,y',z' must be
%rotated to y and z
motorForcesUnrot = [0 Lhd Hdrive Fw 0 Fnfric 0 0 0;];
    
%rotates forces acting on friction wheel into coordinate system 
    motorForces = motorForcesUnrot;
    motorForces(1,5) = ((sqrt(2)/2)*(motorForcesUnrot(1,5)+motorForcesUnrot(1,6)));
    motorForces(1,6) = ((sqrt(2)/2)*(motorForcesUnrot(1,5)+motorForcesUnrot(1,6)));

%reaction forces/moments acting at torsion spring hinge
hingeReactions = [0 0 0 1 1 1 1 1 1;];

%forces acting on hinge therefor negative
hingeForceUnrot = -forceSolver(motorForces, hingeReactions)

%rotating hinge force to gondola coordinate system
    hingeForce = hingeForceUnrot;
    hingeForce(1,5) = ((sqrt(2)/2)*(hingeForceUnrot(1,5)+hingeForceUnrot(1,6)));
    hingeForce(1,6) = ((sqrt(2)/2)*(hingeForceUnrot(1,5)+hingeForceUnrot(1,6)));
    hingeForce(1,8) = ((sqrt(2)/2)*(hingeForceUnrot(1,8)+hingeForceUnrot(1,9)));
    hingeForce(1,9) = ((sqrt(2)/2)*(hingeForceUnrot(1,8)+hingeForceUnrot(1,9)));

%worst reaction forces of hinge/gondola screws, almost all reaction from screw a    
gondScrewReactionsWorst = [ -Ls La 0 1 1 1 2 3 0; 
                             Ls Lb 0 0 1 0 2 3 0;];

gondScrewReactionsWorstSolved = forceSolver(hingeForce, gondScrewReactionsWorst)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculating compressive safety factor for screw
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Fbolt = sqrt(gondScrewReactionsWorstSolved(1,4)^2+gondScrewReactionsWorstSolved(1,5)^2)... 
    /Muwasher + gondScrewReactionsWorstSolved(1,6);

Ncompressive = Scompressive*10^6/ (Fbolt/(pi*(0.5*(Dwashero-Dwasheri))^2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculating Gondola Bearing Arm Reactions and Acceleration 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pitchAngle = 0;  %pitch of airship xz [rads]
thrustAngle = 0;    %angle of thrusters for acceration, 0 is straight forward xz[rads]
gondAngle = 0;      %angle between gondolas xz [rads]
m1 = 0.1;           %mass of gondola 1 in kg
m2 = 0.1;           %mass of gondola 2 in kg
aThrust = 1;        %magnitude of acceleration due to thrust [m/s^2]

%%%%%%%%%%%%%% Forces %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gondMotorForcesUnrot = [-Ldrivex -Ldrivey Hdrive Fw 0 Fnfric 0 0 0; %acting on gond 1
                        Ldrivex Ldrivey Hdrive Fw 0 -Fnfric 0 0 0;];%acting on gond 2
               
%%%%rotating motorForces to account for coordinate system change and gondAngle    
    gondMotorForces = gondMotorForcesUnrot;
    gondMotorForces(1,5) = (sqrt(2)/2)*gondMotorForcesUnrot(1,6);
    gondMotorForces(1,6) = (sqrt(2)/2)*gondMotorForcesUnrot(1,6);
    gondMotorForces(2,5) = (sqrt(2)/2)*gondMotorForcesUnrot(2,6);
    gondMotorForces(2,6) = (sqrt(2)/2)*gondMotorForcesUnrot(2,6);
    gondMotorForces(2,4) = cos(gondAngle)*gondMotorForcesUnrot(2,4) + sin(gondAngle)*gondMotorForcesUnrot(2,6);
    gondMotorForces(2,6) = cos(gondAngle)*gondMotorForcesUnrot(2,6) + sin(gondAngle)*gondMotorForcesUnrot(2,4);

weight = [Lcm1x Lcm1y Lcm1z 0 0 m1*g 0 0 0;      %acting on gond 1 
          Lcm2x Lcm2y Lcm2z 0 0 m2*g 0 0 0;];    %acting on gond 2 
     
%%%%rotating weights to account for pitch angle
    weight(2,6) = cos(pitchAngle)*weight(2,6); 
    weight(2,4) = sin(pitchAngle)*weight(2,6);
    
accelerationForce = [Lcm1x Lcm1y Lcm1z m1*aThrust 0 0 0 0 0;    %acting on gond 1 
                     Lcm2x Lcm2y Lcm2z m2*aThrust 0 0 0 0 0;];  %acting on gond 2
               
%%%%rotating accelerationForce to account for thrust angle
    accelerationForce(2,4) = cos(thrustAngle)*accelerationForce(2,4);
    accelerationForce(2,6) = sin(thrustAngle)*accelerationForce(2,4);

gondForcesUnrot =  [gondMotorForces ;  weight ; accelerationForce]        

%%%%rotation for gondola angle changing postion of gond 2 forces 
gondForces = gondForcesUnrot;

for i = 1:6
    if mod(i,2) == 0
    gondForces(i,1) = cos(gondAngle)*gondForcesUnrot(i,1) + sin(gondAngle)*gondForcesUnrot(i,3);
    gondForces(i,3) = cos(gondAngle)*gondForcesUnrot(i,3) + sin(gondAngle)*gondForcesUnrot(i,1);
    end
end

gondForces

%%%%%%%%%%%%%% reactions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gondReactions = [
    Lbearingx Lbearingy Hbearing 1 1 1 0 0 0;    %Reactions at bearing 4
    Lbearingx -Lbearingy Hbearing 1 1 1 0 0 0;   %Reactions at bearing 3
    -Lbearingx Lbearingy Hbearing 0 2 2 0 0 0;   %Reactions at bearing 2
    -Lbearingx -Lbearingy Hbearing 0 -3 3 0 0 0; %Reactions at bearing 1
    0 0 0 1 0 1 0 0 0;                           %acceleration of gondolas 
    0 0 0 0 0 0 1 0 0;];          

%0 angle scenario test
% gondReactions = [
%     Lbearingx Lbearingy Hbearing 0 2 2 0 0 0;    %Reactions at bearing 4
%     Lbearingx -Lbearingy Hbearing 0 -3 3 0 0 0;   %Reactions at bearing 3
%     -Lbearingx Lbearingy Hbearing 0 4 4 0 0 0;   %Reactions at bearing 2
%     -Lbearingx -Lbearingy Hbearing 0 -5 5 0 0 0; %Reactions at bearing 1
%     0 0 0 1 0 0 0 0 0;                           %acceleration of gondolas 
%     0 0 0 0 0 0 1 0 0;];   




gondReactionsSolved = forceSolver(gondForces, gondReactions, [1 0])

gondAcceleration = sqrt((gondReactionsSolved(5,4)^2)+ ...
                   (gondReactionsSolved(5,6)^2))/(m1+m2)

% function [rotated] = rotate(in, xz, yz, cases, which)
% %rotate will rotate positions and forces from one coordinate systemn to
% %another based on the angles provided between current and disired
% %coordnates systems in xz and yz planes
% temp = in;
% rotated(
% rotated(i,1) = cos(xz)*temp(i,1) + sin(xz)*temp(i,3);
% rotated(i,2) = cos(yz)*temp(i,2) + sin(yz)*temp(i,3);
% rotated(i,3) = cos(xz)*temp(i,3) + sin(xz)*temp(i,1)+ cos(yz)*temp(i,3) + sin(yz)*temp(i,2);
% rotated(i,4) = cos(xz)*temp(i,4) + sin(xz)*temp(i,5);
% rotated(i,5) = cos(yz)*temp(i,5) + sin(yz)*temp(i,6);
% rotated(i,6) = cos(xz)*temp(i,6) + sin(xz)*temp(i,4)+ cos(yz)*temp(i,6) + sin(yz)*temp(i,2);
% end
               
               
               