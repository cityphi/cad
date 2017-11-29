function [ weights, force, choices ] = batMotProp( required, dragValues )
%BATMOTPROP Summary of this function goes here
%   Detailed explanation goes here

% split the inputs into redable values
reqSpeed  = required(1);
reqTime   = required(2);
reqWeight = required(3);
CD        = dragValues(1);
rho       = dragValues(2);
vol       = dragValues(3);

% setup for solving drag and thrust intersect
syms V
assume(V, 'real')

% file names
propCSV = 'propellerMotorData.csv';
battCSV = 'batteryData.csv';

% data loading
propData = csvread(propCSV, 1, 1);
battData = csvread(battCSV, 1, 1);

% hard-coded drag function
drag = 1.88 * CD * rho * vol^(2/3) * V^1.86;

% setup data array unique combinations of pitch and diameter
pitchDiameters = unique(propData(:, 2:3), 'rows');
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
    index = find(ismember(data(:, 1:2), propData(i, 2:3), 'rows'), 1);
    if data(index, end-1) < propData(i, 6) && ... 
            data(index, end) < propData(i, 5)
        possibleData(i, :) = propData(i, :);
    end
end

% remove any empty rows and sort the possible data
possibleData( ~any(possibleData,2), : ) = [];
possibleData = sortrows(possibleData, 4);

% store the data of the propeller and motor
propChoice = possibleData(1, 2:3);
motChoice = possibleData(1, :);

%---BATTERY
ampsNeeded = motChoice(:, 5)/motChoice(:, 4);
battLife = ampsNeeded * reqTime * 1000;
possibleBatt = zeros(size(battData, 1), size(battData, 2));

% get a list of batteries with a high enough discharge
for i = 1:size(battData, 1)
    if battData(i, 4) > ampsNeeded
        possibleBatt(i, :) = battData(i, :);
    end
end

% remove any empty rows
possibleBatt( ~any(possibleBatt, 2), : ) = [];

% select best battery in case of none able to support the required life
possibleBatt = sortrows(possibleBatt, -3);
battChoice = possibleBatt(1, :);

for i = 1:size(possibleBatt, 1)
    if possibleBatt(i, 3) < battLife
        possibleBatt(i, :) = zeros(1, size(battData, 2));
    end
end

% remove any empty rows
possibleBatt( ~any(possibleBatt, 2), : ) = [];

% if there was a battery with enough life, assign it
if ~isempty(possibleBatt)
    battChoice  = possibleBatt(1, :);
else
    disp(strcat('Max life--', num2str(battChoice(1, 3)/ampsNeeded/1000)))
end

% get the name of the motor chosen
propFile = fopen(propCSV);
motorNames = textscan(propFile, '%s%*[^\n]', 'Delimiter', ',', ...
    'HeaderLines', 1);
fclose(propFile);

% get the name of the battery chosen
batFile = fopen(battCSV);
batteryNames = textscan(batFile, '%s%*[^\n]', 'Delimiter', ',', ...
    'HeaderLines', 1);
fclose(batFile);

%--OUTPUT
% Propeller name; Motor name; Battery name
choices = [strcat(int2str(propChoice(1, 1)), 'x', int2str(propChoice(1, 2)));
           motorNames{1, 1}(motChoice(1, 1));
           batteryNames{1, 1}(battChoice(1, 1))]
weights = [];
force = [];
end