%Forces is [locX locY locZ Fx Fy Fz Mx My Mz] 
%Test for forces acting on gondola driving motor
%all lengths/distances are in [m] other units are specified

Tw = 0.1;           %motor torque [Nm]

Ls = 0.08;          %distance from screw to center of torsion hinge 
Lhd = 0.02185;      %distance in y from torsion hingle to friction wheel contact point 
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
motorForces = [0 Lhd Hdrive Fw 0 Fnfric 0 0 0;];
    
%rotates forces acting on friction wheel into coordinate system 
    motorForces(1,5) = ((sqrt(2)/2)*(motorForces(1,5)+motorForces(1,6)));
    motorForces(1,6) = ((sqrt(2)/2)*(motorForces(1,5)+motorForces(1,6)));

%reaction forces/moments acting at torsion spring hinge
hingeReactions = [0 0 0 1 1 1 1 1 1;];

%forces acting on hinge therefor negative
hingeForce = -forceSolver(motorForces, hingeReactions)

%rotating hinge force to gondola coordinate system
    hingeForce(1,4) = hingeForce(1,4);
    hingeForce(1,5) = ((sqrt(2)/2)*(hingeForce(1,5)+hingeForce(1,6)));
    hingeForce(1,6) = ((sqrt(2)/2)*(hingeForce(1,5)+hingeForce(1,6)));
    hingeForce(1,7) = hingeForce(1,7);
    hingeForce(1,8) = ((sqrt(2)/2)*(hingeForce(1,8)+hingeForce(1,9)));
    hingeForce(1,9) = ((sqrt(2)/2)*(hingeForce(1,8)+hingeForce(1,9)));

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
%Calculating Gondola arm forces and acceration
%assumptions: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pitchAngle = 0;     %pitch of airship [rads]
thrustAngle = 0;    %angle of thrusters for acceration, 0 is straight forward [rads]
gondAngle = 0;      %angle between gondolas [rads]
m1 = 0.1;           %mass of gondola 1 in kg
m2 = 0.1;           %mass of gondola 2 in kg
aThrust = 1;        %magnitude of acceleration due to thrust [m/s^2]

%%%%%%%%%%%%%% Forces %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gondMotorForces = [-Ldrivex -Ldrivey Hdrive Fw 0 Fnfric 0 0 0; %acting on gond 1
                   Ldrivex Ldrivey Hdrive Fw 0 -Fnfric 0 0 0;];%acting on gond 2
               
%%%%rotating motorForces to account for coordinate system change and gondAngle     
    gondMotorForces(1,5) = ((sqrt(2)/2)*(gondMotorForces(1,5)+gondMotorForces(1,6)));
    gondMotorForces(1,6) = ((sqrt(2)/2)*(gondMotorForces(1,5)+gondMotorForces(1,6)));
    gondMotorForces(2,5) = ((sqrt(2)/2)*(gondMotorForces(2,5)+gondMotorForces(2,6)));
    gondMotorForces(2,6) = ((sqrt(2)/2)*(gondMotorForces(2,5)+gondMotorForces(2,6)));
    gondMotorForces(2,4) = cos(gondAngle)*gondMotorForces(2,4) + sin(gondAngle)*gondMotorForces(2,5);
    gondMotorForces(2,5) = cos(gondAngle)*gondMotorForces(2,5) + sin(gondAngle)*gondMotorForces(2,4);

weight = [Lcm1x Lcm1y Lcm1z 0 0 m1*g 0 0 0;      %acting on gond 1 
          Lcm2x Lcm2y Lcm2z 0 0 m2*g 0 0 0;];    %acting on gond 2 
     
%%%%rotating weights to account for pitch angle
    weight(1,4) = cos(pitchAngle)*weight(1,4) + sin(pitchAngle)*weight(1,6);
    weight(2,6) = cos(pitchAngle)*weight(2,4) + sin(pitchAngle)*weight(2,6);

accelerationForce = [Lcm1x Lcm1y Lcm1z m1*g 0 0 0 0 0;    %acting on gond 1 
                     Lcm2x Lcm2y Lcm2z m2*g 0 0 0 0 0;];  %acting on gond 2
               
%%%%rotating accelerationForce to account for thrust angle
    accelerationForce(1,4) = cos(thrustAngle)*accelerationForce(1,4) + sin(thrustAngle)*accelerationForce(1,6);
    accelerationForce(2,6) = cos(thrustAngle)*accelerationForce(2,4) + sin(thrustAngle)*accelerationForce(2,6);

gondForces =  [gondMotorForces ;  weight ; accelerationForce]        

%%%%rotation for gondola angle changing postion of gond 2 forces 
for i = 1:6
    if mod(i,2) == 0
    gondForces(i,1) = cos(gondAngle)*gondForces(i,1) + sin(gondAngle)*gondForces(i,3);
    gondForces(i,3) = cos(gondAngle)*gondForces(i,3) + sin(gondAngle)*gondForces(i,1);
    end
end

gondForces

%%%%%%%%%%%%%% reactions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%gondReactions = [
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculating Gondola acceleration 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% screwReactionsFixed(1,4) = 0.5*screwReactionsFixed(1,4);
% screwReactionsFixed(2,4) = screwReactionsFixed(1,4);
% screwReactionsFixed(1,7) = 0.5*screwReactionsFixed(1,7);
% screwReactionsFixed(2,7) = screwReactionsFixed(1,7);
% screwReactionsFixed(1,6) = screwReactionsFixed(1,6);
% screwReactionsFixed(2,6) = screwReactionsFixed(2,6);
% 
% fprintf ('displaying screwReactionsFixed\n');
% disp(screwReactionsFixed)
% 
% %rotating for hinge coordinate system 
% 
% screwForce = zeros(3,9);
% 
% for n = 1:2
%     screwForce(n,1) = screwReactionsFixed(n,1);
%     for i = 2:3
%         screwForce(n,i) = (sqrt(2)/2)*screwReactionsFixed(n,2);
%     end
%     screwForce(n,4) = -screwReactionsFixed(n,4);
%     screwForce(n,5) = -((sqrt(2)/2)*(screwReactionsFixed(n,5)+screwReactionsFixed(n,6)));
%     screwForce(n,6) = -((sqrt(2)/2)*(screwReactionsFixed(n,5)+screwReactionsFixed(n,6)));
%     screwForce(n,7) = -screwReactionsFixed(n,7);
%     screwForce(n,8) = -((sqrt(2)/2)*(screwReactionsFixed(n,8)+screwReactionsFixed(n,9)));
%     screwForce(n,9) = -((sqrt(2)/2)*(screwReactionsFixed(n,8)+screwReactionsFixed(n,9)));
% end
%     screwForce(3,7) = -screwReactionsFixed(3,7);
%     
% fprintf ('displaying screwForce\n');
% disp(screwForce)

%gondola screw reactions
% 
% gondScrewReactions = [ -0.5*Ls La 0 1 1 1 0 0 0; 
%                        0.5*Ls Lb 0 1 1 1 0 0 0;
%                        0 0 0 0 0 0 1 0 0 ];
% 
% gondScrewReactionsFixed = forceSolver(screwForce, gondScrewReactions)