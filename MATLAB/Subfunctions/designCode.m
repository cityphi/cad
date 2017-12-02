function designCode( requirements, l, FR )
%DESIGNCODE Summary of this function goes here
%   Detailed explanation goes here

% M [ density Sut Suc Sy E brittle ] - information of the material
carbon       = [1550 600*10^6 570*10^6 0        109*10^9   1]; % need Sy
aluminum6061 = [2700 310*10^6 0        276*10^6 68.9*10^9  0]; % matweb
nylon6       = [1130 69*10^6  44*10^6  63*10^6  2.33*10^9  1]; % matweb unrenforced

%---INPUTS - TEMP
rhoA = 1.225;
reqSpeed = requirements(1); %m/s
reqTime = requirements(2)/60; %h
reqWeight = requirements(3);

%---ENVELOPE
[ vol, envWeight, airshipRad, CD ] = airship( l, FR );

%---THRUSTER
inputs = [reqSpeed reqTime reqWeight];
dragValues = [CD rhoA vol*0.0283168466];

% pick battery, motor, and propeller
[thrusterMass, battMass, FTmax, propRadius] = batMotProp(inputs, dragValues);

% optimize the shaft
[thrusterWeight, thrusterDist] = thrusterShaft(FTmax, thrusterMass, propRadius, nylon6);
thrustForceLoc = [ 0 thrusterDist+0.04572+airshipRad 0 ]; % relate to thrusters

% get the total weight of one thruster assy relative to thrusters
weight = thrusterAssy(thrusterWeight, battMass, airshipRad);

%---ARM
weight = arm(FTmax, thrustForceLoc, weight, airshipRad, carbon);
connector(FTmax, weight, airshipRad, aluminum6061);

%---WEIGHT

end