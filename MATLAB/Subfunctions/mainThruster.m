% Main script to test the thruster functions
clear; clc;

% M [ density Sut Suc Sy E brittle ] - information of the material
carbon       = [1550 600*10^6 570*10^6 0        109*10^9   1]; % need Sy
aluminum6061 = [2700 310*10^6 0        276*10^6 68.9*10^9  0]; % matweb
nylon6       = [1130 69*10^6  44*10^6  63*10^6  2.33*10^9  1]; % matweb unrenforced

%---INPUTS - TEMP
CD = 0.0227;
rho = 1.225;
vol = 3.453;
reqSpeed = 5; %m/s
reqTime = 30/60; %h
airshipRad = 0.637;

%---SCRIPT
inputs = [reqSpeed reqTime 0];
dragValues = [CD rho vol];

% pick battery, motor, and propeller
[thrusterMass, battMass, FTmax, propRadius] = batMotProp(inputs, dragValues);

% optimize the shaft
[thrusterWeight, thrusterDist] = thrusterShaft(FTmax, thrusterMass, propRadius, nylon6);
thrusterDist = thrusterDist + 0.04572 + airshipRad; % relate to CV

% get the total weight of one thruster assy relative to CV
thrustAssyWeight = thrusterAssy(thrusterWeight, battMass, airshipRad);