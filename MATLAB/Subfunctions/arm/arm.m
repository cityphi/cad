function [weight, thrusterMass] = arm(FT, thrustForceLoc, weight, airshipRad, material)
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
aPitch = 0; %armWorstCase(thrustForce, weight, material);

% dimensions of the arm [ri thickness width]
dimensions = [ airshipRad 0.001 0.03 ];

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
    else
        loop = 0;
    end
end
%---LOG file
armLog(round(weight(end, 1)*2000/9.81, 1), n)

%---OUTPUT
weight = centreMass(weight);
weight(3) = 0;
weight(1) = weight(1)*2;
thrusterMass = [weight(1)/9.81 weight(2:4)];

%---SolidWorks
armSW(dimensions(2), dimensions(3))
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

function [reactions, halfReactions] = armForces(weight, inForces, aPitch)
%ARMFORCES Reaction forces of the arm.
%   [R, hR] = ARMFORCES(W, F, a) returns the total reactions and half 
%   reactions at the connector. Half reactions is used to optimize
%   the arm and the full reactions are used to solve for stress on the
%   connector. The output are of format [ FRx FRy FRz MRx MRy MRz ].
%   
%   **Used by multiple functions
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

function [tensor] = armTensor(forces, dimensions)
%ARMTENSOR Cauchy stress tensor of the arm.
%   tensor = ARMTENSOR(F, D) returns a 3x3 matrix which is used by
%   the cauchy function to find a safety factor for the arm.
%
%   F [ locX locY locZ Fx Fy Fz Mx My Mz ] - thrust force
%   D [innerRadius thickness width] - dimensions of the arm

% split dimensions array for use in equations
ri  = dimensions(1);
h   = dimensions(2);
k   = dimensions(3);

% split the forces array for use in equations
Fx  = forces(4);
Fy  = forces(5);
Fz  = forces(6);
Mx  = forces(7);
My  = forces(8);
Mz  = forces(9);

% find outer radius (ro) centre radius (rbar) and neutral axis radius (r)
ro  = ri + h;
rbar= ri + h/2;
r   = h/log(ro/ri);

% distance from centre to neutral axis
e   = rbar - r; 

% area of the x-z cross-section
A   = h*k;
Iz  = k^3*h/12;

% for the stress calculations
z = h/2 - e; x = k/2;

% for the torsion calcualtions
b = k; c = h;

% assume that max occurs at top right corner
%         k          ^
% -->.--------      z|-->
%    |        |h       x
%     --------
Sx  = 0;
Sy  = Mx*z/(e*A*ri) + Mz*x/Iz + Fy/A; % two plane stress
Sz  = 0;
txy = 0;
txz = 0; 
tyz = My/(b*c^2)*(3+1.8*c/b); % torsional sheer

% cauchy stress tensor
tensor = [ Sx  txy txz;
           txy Sy  tyz;
           txz tyz Sz ];
end

function [ worstCase ] = armWorstCase( inForces, weights, material )
%ARMWORSTCASE Evaluates the worst pitch angle for the arm.
%   a = armWorstCase(F, W, M) returns the worst angle for the stress in the
%   arm. This is run before doing the optimization so optimization is done
%   for only one location.
%   
%   F [ locX locY locZ Fx Fy Fz Mx My Mz ] - thrust force
%   W [ weight locX locY locZ ] - weight of components held by the arm
%   M [ density Sut Suc E brittle ] - information of the material

% dimensions of the arm [ri thickness width]
h = 0.005;
k = 0.01;
dimensions = [ 0.637 h k ];

% add the weight of the arm based on dimensions
weights(end+1, :) = armWeight(dimensions, material(1));

% iterations to find the lowest safety factor
minAngle = -60;
maxAngle = 90;
data = zeros(maxAngle-minAngle, 2);
i = 1;

for aPitch = minAngle:1:maxAngle
    % find the safety factor at current conditions
    [~, halfReactions] = armForces(weights, inForces, aPitch);
    stressTensor = armTensor(halfReactions, dimensions);
    n = cauchy(stressTensor, material);

    % store data
    data(i, :) = [aPitch n];
    i = i + 1;
end
% find and return the worst case pitch
[~, ind] = min(data(:, 2));
worstCase = data(ind, 1:end-1);
end

function armLog(mass, n)
%THRUSTERASSYLOG Outputs useful data to the log file
%   THRUSTERASSYLOG(mass) returns nothing

logFile = 'groupRE3_LOG.txt';
logFolder = fullfile('../Log');
MATLABFolder = fullfile('../MATLAB');

% append to the file
cd(logFolder)
fid = fopen(logFile, 'a+');
fprintf(fid, '\r\n***Thruster Arms***\r\n');
fprintf(fid, ['Total Mass:    ' num2str(mass) ' g\r\n']);
fprintf(fid, ['Safety Factor: ' num2str(n) '\r\n']);
fclose(fid);
cd(MATLABFolder)
end

function armSW(thickness, width)
%ARMSW Outputs data to solidworks for the arm
%   ARMSW(thickness, width) returns nothing

SWArmFile = '2005-THRUSTER-ARMS-EQUATIONS.txt';
SWPlateFile = '2008-PLATE-FRONT-EQUATIONS.txt';
MATLABFolder = fullfile('../MATLAB');
SWFolder = fullfile('../Solidworks/Equations');

% write to the different solidworks files
cd(SWFolder)
fid = fopen(SWArmFile, 'w+t');
fprintf(fid, ['"h"= ' num2str(thickness*1000) 'mm\n']);
fprintf(fid, ['"k"= ' num2str(width*1000) 'mm\n']);
fclose(fid);
fid = fopen(SWPlateFile, 'w+t');
fprintf(fid, ['"k"= ' num2str(width*1000) 'mm\n']);
fprintf(fid, ['"h"= ' num2str(thickness*1000) 'mm\n']);
fclose(fid);
cd ..
cd(MATLABFolder)

disp('Arm Parameterized in Solidworks');
end