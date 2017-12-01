function weight = arm(FT, thrustForceLoc, weight, airshipRad, material)
%ARM Thruster arm optimization.
%   [R, D] = ARM(force, loc, rad, W, M) returns the reaction forces at 
%   the worst pitch for the connector and the optimized dimensions of 
%   the arm. 
%
%   FT - thrust force
%   loc [ locX locY locZ ] - location of the thrust force
%   W [ weight locX locY locZ ] - weight of the thruster assy
%   radius - the radius of the airship
%   M [ density Sut Suc Sy E brittle ] - information of the material

safetyFactor = 5; % hard coded value for the safety factor

thrustForce = [thrustForceLoc FT 0 0 0 0 0 ];

% find the pitch to do analysis of the arm
aPitch = 90; %armWorstCase(thrustForce, weight, material);

% dimensions of the arm [ri thickness width]
dimensions = [ airshipRad 0.005 0.01 ];

% expand the weight array to allow the arm weight to be added and changed
weight(end+1, :) = zeros(1, 4);

% looping variables
maxIterations = 100; iterations = 0; loop = 1;

while loop && iterations < maxIterations
    iterations = iterations + 1;
    
    % analysis of the arm
    weight(end, :) = armWeight(dimensions, material(1));
    [~, halfReactions] = armForces(weight, thrustForce, aPitch);
    stressTensor = armTensor(halfReactions, dimensions);
    n = cauchy(stressTensor, material);
    
    % safety factor check and iteration    
    if n < safetyFactor
        dimensions(2) = dimensions(2) + 0.001;
        dimensions(3) = dimensions(3) + 0.001;
    else
        loop = 0;
    end
end
%---OUTPUT
weight = centreMass(weight);
weight(3) = 0;
weight(1) = weight(1)*2;
end

function [ weight ] = armWeight( dimensions, rho )
%ARMWEIGHT Weight and centre of mass of arm.
%   W = ARMWEIGHT(D, p) returns a vector with the weight and the
%   location that the point mass is acting. The coordinate system is
%   relative to the centre of volume of the airship.
% 
%   D [ innerRadius thickness width ] - dimensions of the arm
%   p [ density ] - the density of the arm material

% give readable names for equations from dimension array
ri  = dimensions(1);
h   = dimensions(2);
k   = dimensions(3);

% set other variables to be used
ro = ri + h;
g = 9.81;

% solve for the weight of the arm and centre of mass
mag = k*pi()*(ro^2 - ri^2)/4*rho*g;
locX = 0;
locY = 4*(ro^3 - ri^3)/(3*pi()*(ro^2 - ri^2));
locZ = -locY;

% build the array to return
weight = [ mag, locX, locY, locZ ];
end