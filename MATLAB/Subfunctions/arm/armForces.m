function [reactions, halfReactions] = armForces(weight, inForces, aPitch)
%ARMFORCES Reaction forces of the arm.
%   [R, hR] = ARMFORCES(W, F, a) returns the total reactions and half 
%   reactions at the connector. Half reactions is used to optimize
%   the arm and the full reactions are used to solve for stress on the
%   connector. The output are of format [ FRx FRy FRz MRx MRy MRz ].
%	
% 	**Used by multiple functions
%	
%   W [ weigth locX locY locZ ] - weight of all the components
%   F [ locX locY locZ Fx Fy Fz Mx My Mz ] - thrust force
%   a [ aPitch ] - pitch angle of the airship

% converts the angle to rads
a = aPitch*pi()/180;

% reaction force location
connectorReact = [ 0 0 -0.637 1 1 1 1 1 1 ];

% build forces array for weight
forces = centreMass(weight, a);

forces(end+1, :) = inForces(:);

% solve for reactions 
halfReactions = forceSolver(forces, connectorReact);

% add the other side of the airship forces
numForces = size(forces, 1);
forces = [forces; forces];
forces(numForces+1:end, 2) = -forces(numForces+1, 2);
reactions = forceSolver(forces, connectorReact);
end