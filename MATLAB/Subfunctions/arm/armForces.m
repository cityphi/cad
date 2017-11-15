function [reactions, halfReactions] = armForces(weights, inForces, aPitch)
%ARMFORCES Reaction forces of the arm.
%   [R, hR] = ARMFORCES(W, F, a) returns the total reactions and half 
%   reactions at the connector. Half reactions is used to optimize
%   the arm and the full reactions are used to solve for stress on the
%   connector. The output are of format [ FRx FRy FRz MRx MRy MRz ].
% 
%   W [ weigth locX locY locZ ] - weight of all the components
%   F [ locX locY locZ Fx Fy Fz Mx My Mz ] - thrust force
%   a [ aPitch ] - pitch angle of the airship

% converts the angle to rads
a = aPitch*pi()/180;

% reaction force location
connector = [ 0 0 -0.637 1 1 1 1 1 1 ];

% forces on arm
numForces = size(weights, 1) + size(inForces, 1);
forces = zeros(numForces*2, 9);

% build forces array for weights
for i = 1:size(weights, 1)
    forces(i, :) = [weights(i, 2) weights(i,3) weights(i, 4) ...
        weights(i, 1)*sin(a) 0 -weights(i, 1)*cos(a) 0 0 0];
end

forces(size(weights, 1) + 1:numForces, :) = inForces(:);

% solve for reactions 
halfForces = forces(1:numForces, :);
halfReactions = forceSolver(halfForces, connector);

% mirror the forces for the other half of the airship
forces(numForces + 1:numForces*2, :) = [forces(1:numForces, 1) ...
    -forces(1:numForces, 2) forces(1:numForces, 3:9)];
reactions = forceSolver(forces, connector);
end