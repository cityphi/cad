function [weight, dimensions] = thrusterShaft(forces, weights, ...
    material, distances)
%THRUSTERSHAFT Thruster arm optimization.
%   [W, D] = ARM(F, W, M) returns the reaction forces at the worst
%   pitch for the connector and the optimized dimensions of the arm. 
%
%   F [ locX locY locZ Fx Fy Fz Mx My Mz ] - thrust force
%   W [ weight locX locY locZ ] -  weight of components held by the arm
%   M [ density Sut Suc Sy E brittle ] - information of the material

safetyFactor = 5;
a = 0;
LT = distances(1);
mountDist = distances(2);

% D [ bore minor major ] https://en.wikipedia.org/wiki/ISO_metric_screw_thread
bore  = 0.0038; % size needed for the screw
major = 0.006; % top of thread
P = 0.00175; %pitch
minor = major - 1.082532*P/2; % bottom of thread

dimensions = [ bore, minor, major];

% reference point and locaiton of reactions
bearing = [ 0 0 0 1 1 1 1 1 1];

% expand the arrays to allow for the end value to be modified
forces(end+1, :) = zeros(1, 9);
weights(end+1, :) = [0 0 (LT-mountDist)/2 0];

% looping variables
maxIterations = 100; iterations = 0; loop = 1;

while loop && iterations < maxIterations
    % change the weight of the shaft and find new forces each iteration
    weights(end, 1) = pi * dimensions(3)^2 * (LT - mountDist) * ...
        material(1) * 9.81;
    forces(end, :) = centreMass(weights, a);

    % steps to get the safety factor
    reaction = forceSolver(forces, bearing);
    tensor = shaftTensor(reaction, dimensions);
    n = cauchy(tensor, material);
    
    % optimization
    if n < safetyFactor
        dimensions(2) = dimensions(2) + 0.0001;
        dimensions(3) = dimensions(3) + 0.0001;
    else
        loop = 0;
    end
end
weight = weights(end, :);
end

function [tensor] = shaftTensor(forces, dimensions)
%SHAFTTENSOR Cauchy stress tensor of the arm.
%   tensor = SHAFTTENSOR(F, D) returns a 3x3 matrix which is used by
%   the cauchy function to find a safety factor for the shaft.
%
%   F [ locX locY locZ Fx Fy Fz Mx My Mz ] - thrust force
%   D [ bore minor major ] - dimensions of the shaft

bore  = dimensions(1); % size needed for the screw
minor = dimensions(2); % bottom of thread

% split the forces array for use in equations
Mx  = forces(7);

% moment of inertia of a hollow circle
Ix = pi/4 * (minor^4 - bore^4);

% assume that max occurs on top surface
Sx  = 0;
Sy  = Mx * minor/Ix; % bending of the shaft
Sz  = 0;
txy = 0;
txz = 0;
tyz = 0;

% cauchy stress tensor
tensor = [ Sx  txy txz;
           txy Sy  tyz;
           txz tyz Sz ];
end