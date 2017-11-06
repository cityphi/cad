function [reactions, halfReactions] = armForces(weights, inForces, aPitch)
%ARMFORCES builds the forces and halfForces arrays of the arm
%   weights is [ weigth locX locY locZ ] since it changes based on pitch
%   inForces is [ locX locY locZ Fx Fy Fz Mx My Mz ] (thrust force)
%   aPitch is the pitch angle of the airship in deg

% converts the angle to rads
a = aPitch*pi()/180;

% reaction force location %%%% MAYBE CHANGE THIS TO AN INPUT?
connector = [ 0 0 -0.637 1 1 1 1 1 1 ];

% forces on arm [ locX locY locZ Fx Fy Fz Mx My Mz ] 
numForces = size(weights, 1) + size(inForces, 1);
forces = zeros(numForces*2, 9);

% BUILD Forces array for weights
for i = 1:size(weights, 1)
    forces(i, :) = [weights(i, 2) weights(i,3) weights(i, 4) ...
        weights(i, 1)*sin(a) 0 -weights(i, 1)*cos(a) 0 0 0];
end

forces(size(weights, 1) + 1:numForces, :) = inForces(:);

% store the one half side of the arm
halfForces = forces(1:numForces, :);
halfReactions = forceSolver(halfForces, connector);

% BUILD other side of the arm
% same as first side but the y values is negative
forces(numForces + 1:numForces*2, :) = [forces(1:numForces, 1) ...
    -forces(1:numForces, 2) forces(1:numForces, 3:9)];
                                    
% Reaction Forces [ FRx FRy FRz MRx MRy MRz ]
reactions = forceSolver(forces, connector);
end