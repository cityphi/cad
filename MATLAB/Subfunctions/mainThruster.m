% Main script to test the thruster functions
clear;

%---INPUTS
% prop [ diameter pitch mass] - propeller properties (m, g)
prop = [ 0.1778 0.127 14];
mountDist = 0.01;

% rpm of the propellers
rpm = 11000;

% pitch of the airship
aPitch = 0;

% M [ density Sut Suc Sy E brittle ] - information of the material
carbon       = [1550 600*10^6 570*10^6 0        109*10^9   1]; % need Sy
aluminum6061 = [2700 310*10^6 0        276*10^6 68.9*10^9  0]; % matweb

% m [ mass ] - mass of motor, mount, and casing (g)
mass = [ 25 28.33 15 ];

%---SCRIPT
% max occurs at 0 velocity
FTmax = thrust(prop(1), prop(2), rpm, 0);

% distance from bearing end to thruster ---unsure how this will work
LT = prop(1)/2 + 0.003; % add a little bit for the casing

% W [ weight locX locY locZ ] - weight of components held by the bearing
weights = zeros(4);
weights(:, 3) = LT;
weights(:, 1) = [ prop(3) * 9.81/1000; mass(:) * 9.81/1000 ];

% F [ locX locY locZ Fx Fy Fz Mx My Mz ] - thrust force
force = [ 0 LT 0 0 0 -FTmax 0 0 0 ];

%---Shaft optimize
safetyFactor = 5;

material = aluminum6061;

% r
a = aPitch;
dimensions = [ 0.001 0.0005 ];
r = dimensions(1);
threadHeight = dimensions(2);

% expand the arrays to allow for the end value to be modified
weights(end+1, :) = [0 0 (LT-mountDist)/2 0];
force(end+1, :) = zeros(1, 9);

% looping variables
maxIterations = 100; iterations = 0; loop = 1;

while loop && iterations < maxIterations  
    weights(end, 1) = pi * r^2 * (LT - mountDist) * material(1) * 9.81;
    M = sum(weights(:, 1));
    Cm = [ M transp(weights(:, 1)) * weights(:, 2:4)/M];
    force(end, 1:6) = [ Cm(2:4) Cm(1)*sin(a) 0 -Cm(1)*cos(a)];

    bearing = [ 0 0 0 1 1 1 1 1 1];

    reaction = forceSolver(force, bearing);
    MB = reaction(7);

    Ix = pi/4 * (r-threadHeight)^4;
    tensor = zeros(3);
    tensor(2, 2) = MB * r/Ix;

    n = cauchy(tensor, material);
    
    if n < safetyFactor
        r = r + 0.0001;
    else
        loop = 0;
    end
end

disp(r)
