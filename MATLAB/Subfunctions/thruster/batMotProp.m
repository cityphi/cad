function [ weights, force ] = batMotProp( required )
%BATMOTPROP Summary of this function goes here
%   Detailed explanation goes here

% split the inputs into redable values
reqSpeed  = required(1);
reqTime   = required(2);
reqWeight = required(3);

% setup for solving drag and thrust intersect
syms V
assume(V, 'real')

% data loading
propCSV = 'propMotors.csv';
propData = csvread(propCSV, 2);
batteryCSV = 'batteries.csv';
batData = csvread(batteryCSV, 2);

% hard-coded drag function
drag = -0.0003545*V^4 + 0.014182*V^3 - 0.053856*V^2 + 0.45054*V - 0.087259;

% setup data array unique combinations of pitch and diameter
pitchDiameters = unique(propData(:, 1:2), 'rows');
data = zeros(size(pitchDiameters, 1), 9);
data(:, 1:2) = sortrows(pitchDiameters,[1 2]);

% finding the required parameters for each pitch-diamter combination
Vmax = reqSpeed + 3;
for i = 1:size(data, 1)
    % since it is sorted reduce the speed by 3 to accelerate the process
    Vmax = Vmax - 3;
    
    % looping variables
    maxIterations = 100; iterations = 0; loop = 1;
    
    % increase the max velocity until it has enough force at desired speed
    while loop && iterations < maxIterations
        iterations = iterations + 1;
    
        % thrust equation uses m
        D = convlength(data(i, 1), 'in', 'm');
        P = convlength(data(i, 2), 'in', 'm');
        
        % the max rotations is when thrust is 0
        nm = Vmax/(0.2*D+0.74*P);
        
        % approximation of rotation at intersection
        n = (1-0.1*reqSpeed/Vmax)*nm;
        
        % thrust equation
        T = 0.20477*(pi*D^2)/4*(D/P)^1.5*((P * n)^2 - V*P * n)*2;
        
        % max speed based on the thrust line and drag curve
        Vtop = double(vpasolve(T == drag, V, [0, 20]));
    
        % check if attained a max speed
        if Vtop < reqSpeed
            Vmax = Vmax + 1;
        else
            data(i, 3) = Vtop;
            data(i, 4) = Vmax;
            data(i, 5) = nm;
            break
        end
    end
end

batVoltage = 11;

% setup values used in caculations to make it easier to read
pD = data(:, 2)./data(:, 1);
cto = -0.2179 * pD.^2 + 0.359 * pD - 0.0356;
cpo = -0.0116 + 0.0957 * pD;

% calculate torque, kv, RPM, power
data(:, 6) = cto .* data(:, 5).^2 .* (data(:, 1)/12).^4 * 0.00322;
data(:, 7) = data(:, 5) * 66/batVoltage;
data(:, 8) = data(:, 7) * batVoltage;
data(:, 9) = cpo .* (data(:, 5)*0.9).^3 .* (data(:, 1)/12).^5 * 0.0043;

% store the data for the lowest power required at this speed
data = sortrows(data, size(data, 2));
bestData = data(1, :);

% setup array for all the possible motor-propeller combinations
possibleData = zeros(size(propData, 1), size(propData, 2));

% check to see if any experimental data meets the calculated requirements
for i = 1:size(propData, 1)
    index = find(ismember(data(:, 1:2), propData(i, 1:2), 'rows'), 1);
    if data(index, end-1) < propData(i, 4) && ... 
            data(index, end) < propData(i, 3)
        possibleData(i, :) = propData(i, :);
    end
end

% remove any empty rows and sort the possible data
possibleData( ~any(possibleData,2), : ) = [];
possibleData = sortrows(possibleData, 3);

% store the data of the propeller and motor
propChoice = possibleData(1, 1:6);
motChoice = possibleData(1, 7:end);

%---BATTERY
ampsNeeded = propChoice(:, 3)/batVoltage;
possibleBat = zeros(size(batData, 1), size(batData, 2));

% check amps
for i = 1:size(batData, 1)
    if batData(i, 3) > ampsNeeded
        possibleBat(i, :) = batData(i, :);
    end
end

possibleBat = sortrows(possibleBat, -2);
batteryChoice = possibleBat(1, :);

possibleBat( ~any(possibleBat,2), : ) = [];

for i = 1:size(possibleBat, 1)
    if possibleBat(i, 2) > ampsNeeded * reqTime * 1000
        possibleBat(i, :) = [];
    end
end

if ~isempty(possibleBat)
    batteryChoice  = possibleBat(1, :);
end

weights = [];
force = [];
end