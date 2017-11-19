function [ dimensions ] = connector(inForces, weights, material)
%CONNECTOR Connecter optimization 
%   D = CONNECTOR(F, W, m) returns the optimized dimensions of the
%   square piece of the connector. The height and length are fixed and the
%   value changing will be the width. 
%
%   F [ locX locY locZ Fx Fy Fz Mx My Mz ] - thrust force
%   W [ weight locX locY locZ ] - weight of all components above connector
%   M [ density Sut Suc Sy E brittle ] - information of the material

safetyFactor = 5; % hard coded value for the safety factor

% [ length width height ] - starting
dimensions = [ 0.04 0.0005 0.033 ];
change = 0.0001;

% location of analysis
reaction = [ 0 0 0 1 1 1 1 1 1];

% loop to find the worst angle for each failure case
minAngle = -60;
maxAngle = 90;
data = zeros(maxAngle-minAngle + 1, 3);
i = 1;

for aPitch = minAngle:1:maxAngle
    force = armForces(weights, inForces, aPitch);
    force(1:3) = [0 0 dimensions(3)]; % change the coordinates
    bottomForces = forceSolver(force, reaction);
    
    % safety factor for stresses
    stressTensor = connectorTensor(bottomForces, dimensions);
    SF(1) = cauchy(stressTensor, material);
    
    % safety factor for buckling
    Pcr = (1.2)*pi()^2*material(5)* dimensions(2)^3/(12*dimensions(3));
    SF(2) = abs(Pcr/force(6));

    % store data
    data(i, :) = [aPitch SF];
    i = i + 1;
end

[worst, row] = min(data(:, 2:3));
[~, col] = min(worst);

pitches = data(row, 1);

force = armForces(weights, inForces, pitches(1));
force(1:3) = [0 0 dimensions(3)]; % change the coordinates
bottomForces = forceSolver(force, reaction);

% loop to find a dimension that gives the desire safety factor
maxIterations = 100; iterations = 0; loop = 1;

while loop && iterations < maxIterations;
    iterations = iterations + 1;  
    
    if col == 1
        % safety factor for stresses
        stressTensor = connectorTensor(bottomForces, dimensions);
        n = cauchy(stressTensor, material);
        
    elseif col == 2
        % safety factor for buckling
        Pcr = (1.2)*pi()^2*material(5)* dimensions(2)^3/(12*dimensions(3));
        n = Pcr/force(6);
    end
    
    if n < safetyFactor
        if dimensions(2) > 0.0029
            disp(strcat('Max connector safety factor: ', int2str(n)))
            loop = 0;
        else
            dimensions(2) = dimensions(2) + change;
        end
    else
        loop = 0;    
    end
end
end

function [ tensor ] = connectorTensor(forces, dimensions)
%CONNECTORTENSOR Cauchy stress tensor of the connector
%   tensor = connectorTensor(F, D) returns a 3x3 matrix which is used by
%   the cauchy function to find a safety factor for the connector

% split dimensions array for use in equations
l   = dimensions(1);
w   = dimensions(2);
h   = dimensions(3);

% split the forces array for use in equations
Fx  = forces(4);
Fy  = forces(5);
Fz  = forces(6);
Mx  = forces(7);
My  = forces(8);
Mz  = forces(9);

% area of the x-z cross-section
A   = l*w;
Ix  = l*w^3/12;
Iy  = l^3*w/12;

% for the stress calculations
y = w/2; x = l/2;

% for the torsion calculations
b = l; c = w;

% assume that max occurs at top right corner
%         l          ^
% -->.--------      y|-->
%    |        |w       x
%     --------
Sx  = 0;
Sy  = 0;
Sz  = Mx*y/Ix + My*x/Iy - Fy/A; % two plane stress
txy = Mz/(b*c^2)*(3+1.8*c/b); % torsional sheer
txz = 0;
tyz = 0;

% layout of the cauchy stress tensor
tensor = [ Sx  txy txz;
           txy Sy  tyz;
           txz tyz Sz ];
end