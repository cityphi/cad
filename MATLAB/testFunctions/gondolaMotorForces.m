function [ result ] = gondolaForces( )

%Forces is [ locX locY locZ Fx Fy Fz Mx My Mz ] 
% Test for forces acting on gondola driving motor
Tw = 4; %motor torque
Ls = 5; %distance between screws
Lhs = 3; %length from motor hinge axle to motor mount screws
Lsw = 6; %length from motor mount screw to friction wheel contact point
Hsw = 4; %height of friction wheel contact point off hinge
rFw = 3; %friction wheel radius 
Mu = 0.5; %frictionwheel to keel coefficient of friction

Tspring = 1.5 * (Tw * (Lhs+Lsw))/(rFw * Mu); %spring torque

Fspring =  Tspring /(Lhs+Lsw); %force of spring acting on friction wheel
Fnfric =  -Fspring; % normal force of frction wheel equal to spring for
Fw = Tw/rFw;

% position with reference to center of hinge axle 
motorForces = [
    0 Lhs+Lsw Hsw Fw 0 Fnfric 0 0 0; %friction owheel contact point forces
    -0.5*Ls Lhs 0 0 0 0.5*Fspring 0 0 0; %spring forces acting on screw 1
    0.5*Ls Lhs 0 0 0 0.5*Fspring 0 0 0; %spring forces acting on screw 2 
    ];

screwReactions = [ -0.5*Ls Lhs 0 1 1 0 0 0 0;
                    0.5*Ls Lhs 0 1 1 0 0 0 0; ];

output = forceSolver(motorForces, screwReactions)
end