function [ n ] = keelConnector( inForces, weights, material )
%KEELCONNECTOR Safety factor of the bottom part of the connector
%   n = KEELCONNECTOR(F, W, M) returns a safety factor of the bottom
%   section of the conenctor. This can't be optimized since the size is
%   fixed.
%
%   F [ locX locY locZ Fx Fy Fz Mx My Mz ] - thrust force
%   W [ weight locX locY locZ ] - weight of all components above connector
%   M [ density Sut Suc Sy E brittle ] - information of the material

% dimensions of the base connector
l  = 0.06;
a1 = 0.01;
w1 = a1*cos(pi()/4);
h1 = w1/2;
a2 = 0.008;

% l a (main) a (smaller)
dimensions = [ l a1 w1 h1 a2 ];

reactions = [ -l/2 0 -h1 0 0 1 0 0 0;
               l/2 0  h1 0 0 1 0 0 0];
           
% checking at different pitch angles
minAngle = -60; maxAngle = 90;
data = zeros(maxAngle-minAngle+1, 2);
i = 0;

% checking for worst case scenario of the base of connector
for aPitch = minAngle:1:maxAngle
    i = i + 1;
    % change the reaction assumptions based on the pitch angle
    if aPitch < 0
        reactions(:, 4) = [1; 0];
        force = armForces(weights, inForces, aPitch);
        force = [0 0 0.04 -force(4:end)]; % change the coordinates
        bottomForces = forceSolver(force, reactions);
        analysisForces = bottomForces(1, :);
    else
        reactions(:, 4) = [0; 1];
        force = armForces(weights, inForces, aPitch);
        force = [0 0 0.04 -force(4:end)]; % change the coordinates
        bottomForces = forceSolver(force, reactions);
        analysisForces = bottomForces(2, :);
    end
    % build a stress tensor and use cauchy to solve for safety factor
    stressTensor = keelTensor(analysisForces, dimensions);
    data(i, :) = [aPitch cauchy(stressTensor, material)];
end
n = min(data(:, 2));
end

function [ tensor ] = keelTensor(forces, dimensions)
%KEELTENSOR Cauchy stress tensor of the keel section of the connector
%   tensor = connectorTensor(F, D) returns a 3x3 matrix which is used by
%   the cauchy function to find a safety factor for the connector

% split dimensions array for use in equations
a   = dimensions(2);
w   = dimensions(3);
h   = dimensions(4);

% split the forces array for use in equations
Fx  = forces(4);
Fz  = forces(6);

% area of the z-y cross-section
A  = a^2;
I  = a^4/12;

% for shear stress
V = Fz;
Q = (w*h/2)*(h/3);
b = w;

% assume that max occurs in middle
%        ^
%   /\  z|-->
%   \/     y
Sx  = Fx/A;
Sy  = 0;
Sz  = 0;
txy = 0;
txz = -V*Q/(I*b);
tyz = 0;

% layout of the cauchy stress tensor
tensor = [ Sx  txy txz;
           txy Sy  tyz;
           txz tyz Sz ];
end