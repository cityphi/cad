function [ totalWeight, thrust, radius ] = batMotProp( required, dragValues )
%BATMOTPROP Picks a battery, motor, and prop
%   BATMOTPROP does the selection of the main thruster componenets and
%   gives useful information back to the amin program

% split the inputs into redable values
reqSpeed  = required(1);
reqTime   = required(2);
reqWeight = required(3);

% file names
propCSV = 'propellerMotorData.csv';
battCSV = 'batteryData.csv';

% data loading
propData = csvread(propCSV, 1, 1);
battData = csvread(battCSV, 1, 1);

% setup data array unique combinations of pitch and diameter
pitchDiameters = unique(propData(:, 2:3), 'rows');

% data - [P D Vmax Vzero RPM(at start) Power]
data = zeros(size(pitchDiameters, 1), 6);
data(:, 1:2) = sortrows(pitchDiameters,[-1 -2]);

% finding the required parameters for each pitch-diamter combination
Vzero = reqSpeed + 5;
for i = 1:size(data, 1)
    % since it is sorted reduce the speed by 5 to accelerate the process
    Vzero = Vzero - 5;
    
    % looping variables
    maxIterations = 100; iterations = 0; loop = 1;
    
    % increase the max velocity until it has enough force at desired speed
    while loop && iterations < maxIterations
        iterations = iterations + 1;
    
        % equations use m
        D = convlength(data(i, 1), 'in', 'm');
        P = convlength(data(i, 2), 'in', 'm');
        
        % the max rotations is when thrust is 0
        nm = Vzero/(0.2*D+0.74*P);
        
        % approximation of rotation at intersection
        nApprox = (1-0.1*reqSpeed/Vzero)*nm;
        
        % max speed based on the thrust line and drag curve
        Vmax = airshipSpeed(D, P, nApprox, dragValues);
    
        % check if attained a max speed
        if Vmax < reqSpeed
            Vzero = Vzero + 1;
        else
            data(i, 3) = Vmax;
            data(i, 4) = Vzero;
            data(i, end-1) = nm * 60; % convert to RPM at start
            break
        end
    end
end

% calculate the power required from the motor (75% efficient)
cpo = -0.0116 + 0.0957 * data(:, 2)./data(:, 1);
data(:, end) = cpo .* (data(:, 5)/60).^3 .* (data(:, 1)/12).^5 * 0.0043;

%---Match to one of the experimental data sets
possibleMot = zeros(size(propData, 1), size(propData, 2));

% check to see if any experimental data meets the calculated requirements
for i = 1:size(propData, 1)
    index = find(ismember(data(:, 1:2), propData(i, 2:3), 'rows'), 1);
    if data(index, end-1) < propData(i, 6) && ... 
            data(index, end) < propData(i, 5)
        possibleMot(i, :) = propData(i, :);
    end
end

% remove any empty rows and sort the possible data
possibleMot(~any(possibleMot, 2), :) = [];
possibleMot = sortrows(possibleMot, 5);

% store the data of the propeller and motor
propChoice = [possibleMot(1, 2:3) possibleMot(1, 9)];
motChoice = possibleMot(1, :);

%---BATTERY
ampsNeeded = motChoice(:, 5)/motChoice(:, 4);
battLife = ampsNeeded * reqTime * 1000;
possibleBatt = zeros(size(battData, 1), size(battData, 2));

% only include batteries with a high enough discharge rate
for i = 1:size(battData, 1)
    if battData(i, 4) > ampsNeeded
        possibleBatt(i, :) = battData(i, :);
    end
end

% remove any empty rows
possibleBatt( ~any(possibleBatt, 2), : ) = [];

% remove any batteries that don't have the required voltage
possibleBatt(possibleBatt(:, 5) < motChoice(:, 4), :) = [];

% select best battery in case of none able to support the required life
possibleBatt = sortrows(possibleBatt, -3);
battChoice = possibleBatt(1, :);

for i = 1:size(possibleBatt, 1)
    if possibleBatt(i, 3) < battLife
        possibleBatt(i, :) = zeros(1, size(battData, 2));
    end
end

% remove any empty rows
possibleBatt(~any(possibleBatt, 2), :) = [];

% if there was a battery with enough life, assign it
if ~isempty(possibleBatt)
    battChoice  = possibleBatt(1, :);
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

% Propeller name; Motor name; Battery name
names = [[int2str(propChoice(1)) 'x' int2str(propChoice(2))];
         motorNames{1, 1}(motChoice(1));
         batteryNames{1, 1}(battChoice(1))];

%--Log file
% get the top speed with this setup
D = convlength(propChoice(1), 'in', 'm');
P = convlength(propChoice(2), 'in', 'm');
speed = airshipSpeed(D, P, motChoice(6)/60, dragValues);

% setup the values that need to be in the log files
propData = propChoice(3);
motData  = [motChoice(12) motChoice(10) motChoice(5) motChoice(4) speed];
battData = [battChoice(2) battChoice(3) battChoice(5) battChoice(6)];

thrusterLog( names, propData, motData, battData );

%--OUTPUT
% one arms weight of components and thrust
totalWeight = motData(1) + propData(1) + battData(1);
thrust = motChoice(7);
radius = propChoice(1) * 0.5;
end

function topSpeed = airshipSpeed(D, P, n, dragValues)
%AIRSHIPSPEED gives the airships top speed
%   speed = AIRSHIPSPEED(D, P, n) returns the intersect of the
%   thrust curve with the drag curve (top speed)
%   D - Diameter (in)
%   P - Pitch (in)
%   n - RPMs
%   dragValues [CD rho vol] - of the airship

syms V
assume(V, 'real')

CD = dragValues(1);
rho = dragValues(2);
vol = dragValues(3);

% hard-coded drag function
drag = 1.88 * CD * rho * vol^(2/3) * V^1.86;

% thrust equation
T = 0.20477*(pi*D^2)/4*(D/P)^1.5*((P * n)^2 - V*P * n)*2;
    
% max speed based on the thrust line and drag curve
topSpeed = double(vpasolve(T == drag, V, [0, 20]));
end

function thrusterLog( names, propChoice, motChoice, battChoice )
%THRUSTERLOG writes to the log files of the program
%   THRUSTERLOG(names, mot, prop, batt) does not return anything
%   names - [prop mot batt]
%   propChoice - [weight]
%   motChoice - [weight KV power Volts topSpeed]
%   battChoice - [weight mAh Volts discharge]

logFile = 'groupRE3_LOG.txt';
logFolder = fullfile('../Log');
MATLABFolder = fullfile('../MATLAB');

% convert to char
propName = char(names(1));
motName  = char(names(2));
battName = char(names(3));

% value used in a calculation for flight time
amps = motChoice(3)/motChoice(4);

cd(logFolder)
fid = fopen(logFile, 'w+t');
% lines of the file
fprintf(fid, ['Max Speed   = ' num2str(motChoice(5)) ' m/s\n']);
fprintf(fid, ['Flight Time = ' num2str(battChoice(2)*0.06/amps) 'minutes\n']);
fprintf(fid, '\n***Thruster Selection***\n');
fprintf(fid, ['Propeller - APC E ' propName '\n']);
fprintf(fid, ['\tWeight: ' num2str(propChoice(1)) ' g\n']);

fprintf(fid, ['Motor - ' motName '\n']);
fprintf(fid, ['\tWeight: ' num2str(motChoice(1)) ' g\n']);
fprintf(fid, ['\tVolts:  ' num2str(motChoice(4)) ' V\n']);
fprintf(fid, ['\tKV:     ' num2str(motChoice(2)) ' RPM/V\n']);
fprintf(fid, ['\tPower:  ' num2str(motChoice(3)) ' W\n']);

fprintf(fid, ['Battery - ' battName '\n']);
fprintf(fid, ['\tWeight:    ' num2str(battChoice(1)) ' g\n']);
fprintf(fid, ['\tCapacity:  ' num2str(battChoice(2)) ' mAh\n']);
fprintf(fid, ['\tVoltage:   ' num2str(battChoice(3)) ' V\n']);
fprintf(fid, ['\tDischarge: ' num2str(battChoice(4)) ' C\n']);
fclose(fid);
cd(MATLABFolder)

end