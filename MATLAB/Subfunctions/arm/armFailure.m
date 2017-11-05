% Looking to calcualte the stress in the arm
%%%% ALL OF INPUT MUST BE JUST HALF THE ARM %%%%
clear; clc;

% ---INPUTS
aPitch = 0;
% Weights of components [ weigth locX locY locZ ]
weight = [7 0 50 0; 2 0 75 0];

% Input Forces [ mag dirX dirY dirZ locX locY locZ ]
inForce = [ 4.5 0 0 -1 0 0.8 0];

% ---FUNCTION 
a = aPitch*pi()/180;
fixed = [ 0 0 -0.637 1 1 1 1 1 1 ];
% Forces on arm [ locX locY locZ Fx Fy Fz Mx My Mz ] 
numForces = size(weight, 1) + size(inForce, 1);
forces = zeros((size(weight, 1) + size(inForce, 1))*2, 9);

% BUILD Forces array for weight
for i = 1:size(weight, 1)
    forces(i, :) = [weight(i, 2) weight(i,3) weight(i, 4) ...
                    weight(i, 1)*sin(a) 0 -weight(i, 1)*cos(a) 0 0 0];
end
for i = 1:size(inForce, 1)
    c = i + size(weight, 1);
    forces(c, :) = [inForce(i, 5) inForce(i, 6) inForce(i, 7) ...
                    inForce(i, 1)*inForce(i, 2) ...
                    inForce(i, 1)*inForce(i, 3) ...
                    inForce(i, 1)*inForce(i, 4) 0 0 0];
end
halfForces = [forces(1:numForces, :)];

% ONLY WORKS FOR SYMMETRY
forces(numForces + 1:numForces*2, :) = [forces(1:numForces, 1) ...
                                        -forces(1:numForces, 2) ...
                                        forces(1:numForces, 3:9)];
                                    
% Reaction Forces [ FRx FRy FRz MRx MRy MRz ]
reaction(forces, fixed)
