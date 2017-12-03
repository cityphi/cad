function designCode( requirements, l, FR )
%DESIGNCODE Summary of this function goes here
%   Detailed explanation goes here

% M [ density Sut Suc Sy E brittle ] - information of the material
carbon       = [1550 600*10^6 570*10^6 0        109*10^9   1]; % need Sy
aluminum6061 = [2700 310*10^6 0        276*10^6 68.9*10^9  0]; % matweb
nylon6       = [1130 69*10^6  44*10^6  63*10^6  2.33*10^9  1]; % matweb unrenforced
rhoA = 1.225;

% split the inputs to be more readable
reqSpeed = requirements(1); %m/s
reqTime = requirements(2)/60; %h
reqWeight = requirements(3);

%---ENVELOPE
[vol, envMass, airshipRad, CD] = envelope(l, FR);

%---THRUSTER
inputs = [reqSpeed reqTime reqWeight];
dragValues = [CD rhoA vol*0.0283168466];

% pick battery, motor, and propeller
[thrusterMass, battMass, FTmax, propRadius, time, speed] = batMotProp(inputs, dragValues);

% optimize the shaft
[thrusterWeight, thrusterDist] = thrusterShaft(FTmax, thrusterMass, propRadius, nylon6);
thrustForceLoc = [ 0 thrusterDist+0.04572+airshipRad 0 ]; % relate to thrusters

% get the total weight of one thruster assy relative to thrusters
thrusterWeight = thrusterAssy(thrusterWeight, battMass, airshipRad);

%---ARM
[thrusterWeight, thrusterMass] = arm(FTmax, thrustForceLoc, thrusterWeight, airshipRad, carbon);
connector(FTmax, thrusterWeight, airshipRad, aluminum6061);

%---MASS
[totalMass, fixedMass, gondolaMass] = airshipMass(thrusterMass, envMass, airshipRad);
mass = vol*rhoA - totalMass;

%---GONDOLA
gondolaAnalysis(FTmax/totalMass);

%---LOG
finalLog(speed, time, mass)
end