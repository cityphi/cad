% Main script to test the thruster functions
clear; clc;

% M [ density Sut Suc Sy E brittle ] - information of the material
carbon       = [1550 600*10^6 570*10^6 0        109*10^9   1]; % need Sy
aluminum6061 = [2700 310*10^6 0        276*10^6 68.9*10^9  0]; % matweb
nylon6       = [1130 69*10^6  44*10^6  63*10^6  2.33*10^9  1]; % matweb unrenforced

%---INPUTS
reqSpeed = 5; %m/s
reqTime = 10/60; %h

%---INPUTS - TEMP
mountDist = 0.01;

% rpm of the propellers
rpm = 11000;

% pitch of the airship
aPitch = 0;

% m [ mass ] - mass of motor, mount, and casing (g)
mass = [ 25 28.33 15 ];

CD = 0.0227;
rho = 1.225;
vol = 3.453;

%---SCRIPT
[thrusterMass, FTmax, propRadius] = batMotProp([reqSpeed reqTime 0], ...
    [CD rho vol]);

% W [ weight locX locY locZ ] - weight of components held by the bearing
weights = zeros(4);
weights(:, 3) = LT;
weights(:, 1) = [ prop(3) * 9.81/1000; mass(:) * 9.81/1000 ];

% F [ locX locY locZ Fx Fy Fz Mx My Mz ] - thrust force
force = [ 0 LT 0 0 0 -FTmax 0 0 0 ];

distances = [ LT mountDist ];

[weight, dimensions] = thrusterShaft(FTmax, thrusterMass, propRadius, ...
    nylon6);