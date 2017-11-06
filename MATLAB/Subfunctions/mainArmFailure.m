% Looking to calcualte the stress in the arm
%%%% ALL OF INPUT MUST BE JUST HALF THE ARM %%%%
clear; clc;

% ---INPUTS
% pitch angle of airship
aPitch = 0;

% Weights of components [ weigth locX locY locZ ]
weight = [7.66 0 0.409 -0.409; 1.33 0 0.642 0; 4.46 0 0.684 0];

% Input Forces [ locX locY locZ Fx Fy Fz Mx My Mz ] 
inForce = [ 0 0.802 0 0 0 -4.56 0 0 0 ];

% ---FUNCTION
addpath(genpath('../Subfunctions'));

a = aPitch*pi()/180;

% reaction force location
fixed = [ 0 0 -0.637 1 1 1 1 1 1 ];

% forces on arm [ locX locY locZ Fx Fy Fz Mx My Mz ] 
numForces = size(weight, 1) + size(inForce, 1);
forces = zeros(numForces*2, 9);

% BUILD Forces array for weight
for i = 1:size(weight, 1)
    forces(i, :) = [weight(i, 2) weight(i,3) weight(i, 4) ...
                    weight(i, 1)*sin(a) 0 -weight(i, 1)*cos(a) 0 0 0];
end

forces(size(weight, 1) + 1:numForces, :) = inForce(:);

% store the one half side of the arm
halfForces = forces(1:numForces, :);
halfReactions = reaction(halfForces, fixed);

% BUILD other side of the arm
% same as first side but the y values is negative
forces(numForces + 1:numForces*2, :) = [forces(1:numForces, 1) ...
    -forces(1:numForces, 2) forces(1:numForces, 3:9)];
                                    
% Reaction Forces [ FRx FRy FRz MRx MRy MRz ]
reactions = forceSolver(forces, fixed);

