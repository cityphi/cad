function [weight, dimensions] = thrusterShaft(forces, weights, ...
    material, distances)
%THRUSTERSHAFT Thruster arm optimization.
%   [W, D] = ARM(F, W, M) returns the reaction forces at the worst
%   pitch for the connector and the optimized dimensions of the arm. 
%
%   F [ locX locY locZ Fx Fy Fz Mx My Mz ] - thrust force
%   W [ weight locX locY locZ ] -  weight of components held by the arm
%   M [ density Sut Suc Sy E brittle ] - information of the material
%   D [ LT mountDist] - distance to thrust and offset from shaft

% hard-coded values
safetyFactor = 5;
a = 0;

% set the names to be readable
LT        = distances(1);
mountDist = distances(2);

bore  = 0.0038; % radius needed for screw needed for the screw

% standard thread sizes and pitch (mm)
% https://en.wikipedia.org/wiki/ISO_metric_screw_thread
thread = [ 8 1.25 1; 10 1.5 1.25; 12 1.75 1.5; 14 2 1.5; 16 2 1.5;
    18 2.5 2; 20 2.5 2; 22 2.5 2; 24 3 2];
type = 2; % 2 = coarse, 3 = fine

% reference point and locaiton of reactions
bearing = [ 0 0 0 1 1 1 1 1 1];

% expand the arrays to allow for the end value to be modified
forces(end+1, :) = zeros(1, 9);
weights(end+1, :) = [0 0 (LT-mountDist)/2 0];

for i = 1:size(thread, 1)
    % values for dimensions
    major = thread(i, 1)/1000; % major diameter (m)
    pitch = thread(i, type)/1000; % pitch of threads (mm)
    minor = major - 1.082532*pitch; % minor diameter (m)

    % D [ boreRadius minorRadius majorRadius thread(M)]
    dimensions = [bore minor/2 major/2];
    
    % change the weight of the shaft and find new forces each iteration
    weights(end, 1) = pi * dimensions(3)^2 * (LT - mountDist) * ...
        material(1) * 9.81;
    forces(end, :) = centreMass(weights, a);

    % steps to get the safety factor
    reaction = forceSolver(forces, bearing);
    tensor = shaftTensor(reaction, dimensions);
    n = cauchy(tensor, material);
    
    % end when safety factor is reached
    if n > safetyFactor
        break
    end
end
% display a message if the safety factor couldn't be acheived
if n < safetyFactor
    disp(strcat('Max thruster shaft safety factor reached:', int2str(n)))
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