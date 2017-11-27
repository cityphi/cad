% Main script to test the thruster functions
clear; clc;

% M [ density Sut Suc Sy E brittle ] - information of the material
carbon       = [1550 600*10^6 570*10^6 0        109*10^9   1]; % need Sy
aluminum6061 = [2700 310*10^6 0        276*10^6 68.9*10^9  0]; % matweb
nylon6       = [1130 69*10^6  44*10^6  63*10^6  2.33*10^9  1]; % matweb unrenforced

%---INPUTS
reqSpeed = 10; %m/s
reqTime = 60/60; %h

%---INPUTS - TEMP
% prop [ diameter pitch mass] - propeller properties (m, g)
prop = [ 0.1778 0.127 14];
mountDist = 0.01;

% rpm of the propellers
rpm = 11000;

% pitch of the airship
aPitch = 0;

% m [ mass ] - mass of motor, mount, and casing (g)
mass = [ 25 28.33 15 ];

%---SCRIPT
batMotProp([reqSpeed, reqTime, 0]);

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

distances = [ LT mountDist ];
[weight, dimensions] = thrusterShaft(force, weights, nylon6, distances);