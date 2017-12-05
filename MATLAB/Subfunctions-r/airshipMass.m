function [ totalMass, fixedMass, gondolaMass ] = airshipMass( thrusterMass, envMass, radius )
%AIRSHIPMASS Summary of this function goes here
%   Detailed explanation goes here

% get the mass from the file of the fixed masses (ref = 5)
fixedData = csvread('weightData.csv', 1);
references = fixedData(:, 5) == 5;
fixedData(~references, :) = [];
fixedData(:) = fixedData(:)/1000;
fixedData(:, 4) = fixedData(:, 4) + radius;
fixedMass = fixedData(:, 1:4);
fixedMass = [fixedMass; thrusterMass; envMass];


% get the mass from the file of the gondola masses (ref = 10)
gondolaMass = csvread('weightData.csv', 1);
references = gondolaMass(:, 5) == 10;
gondolaMass(~references, :) = [];
gondolaMass(:) = gondolaMass(:)/1000;

%---OUPUTS
fixedMass = centreMass(fixedMass);
gondolaMass = centreMass(gondolaMass);
totalMass = fixedMass(1) + gondolaMass(1);
end