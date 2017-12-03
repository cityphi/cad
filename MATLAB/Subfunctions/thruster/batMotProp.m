function [ thrustMass, battMass, thrust, radius, time, speed ] = batMotProp( required, dragValues )
%BATMOTPROP Picks a battery, motor, and prop
%   BATMOTPROP does the selection of the main thruster componenets and
%   gives useful information back to the main program

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
possibleBatt(:, :) = battData(:, :);

% only include batteries with a high enough discharge rate
possibleBatt(possibleBatt(:, 4) < ampsNeeded, :) = [];

% remove any batteries that don't have the required voltage
possibleBatt(possibleBatt(:, 5) < motChoice(:, 4), :) = [];

% select best battery in case of none able to support the required life
possibleBatt = sortrows(possibleBatt, -3);
battChoice = possibleBatt(1, :);

% remove any batteries with life that doesn't meet requirement
possibleBatt(possibleBatt(:, 3) < battLife, :) = [];

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

%--OUTPUT
% LOG file
% setup the values that need to be in the log files
propData = propChoice(3);
motData  = [motChoice(12) motChoice(10) motChoice(5) motChoice(4) motChoice(7)];
battData = [battChoice(2) battChoice(3) battChoice(5) battChoice(6)];

% write to the log file
thrusterLog( names, propData, motData, battData );

% MAIN returns
thrustMass = motData(1) + propData(1);
battMass = battData(1);
thrust = motChoice(7);
radius = convlength(propChoice(1) * 0.5, 'in', 'm');
time = battChoice(2)*0.06/(motChoice(3)/motChoice(4));
% get the top speed with this setup
D = convlength(propChoice(1), 'in', 'm');
P = convlength(propChoice(2), 'in', 'm');
speed = airshipSpeed(D, P, motChoice(6)/60, dragValues);

% write to the solidworks file
thrusterSW(propChoice(1), battChoice(end), battChoice(end-2), battChoice(end-1));
end

function topSpeed = airshipSpeed(D, P, n, dragValues)
%AIRSHIPSPEED gives the airships top speed
%   speed = AIRSHIPSPEED(D, P, n) returns the intersect of the
%   thrust curve with the drag curve (top speed)
%   D - Diameter (in)
%   P - Pitch (in)
%   n - RPMs
%   dragValues [CD rho vol] - of the airship

CD = dragValues(1);
rho = dragValues(2);
vol = dragValues(3);

% hard-coded drag function
drag = @(V) 1.88 * CD * rho * vol^(2/3) * V^1.86;

% thrust equation
T = @(V) 0.20477*(pi*D^2)/4*(D/P)^1.5*((P * n)^2 - V*P * n)*2;
    
% max speed based on the thrust line and drag curve
options = optimset('Display','off');
topSpeed = fsolve(@(V) T(V) - drag(V), 2, options);
end

function thrusterLog( names, propChoice, motChoice, battChoice )
%THRUSTERLOG writes to the log files of the program
%   THRUSTERLOG(names, mot, prop, batt) does not return anything
%   names - [prop mot batt]
%   propChoice - [weight]
%   motChoice - [weight KV power Volts topSpeed thrust]
%   battChoice - [weight mAh Volts discharge]

logFile = 'groupRE3_LOG.txt';
logFolder = fullfile('../Log');
MATLABFolder = fullfile('../MATLAB');

% convert to char
propName = char(names(1));
motName  = char(names(2));
battName = char(names(3));

cd(logFolder)
fid = fopen(logFile, 'a+');
% lines of the file
fprintf(fid, '\n***Thruster Selection***\r\n');
fprintf(fid, ['Propeller - APC E ' propName '\r\n']);
fprintf(fid, ['\tWeight: ' num2str(propChoice(1)) ' g\r\n']);

fprintf(fid, ['Motor - ' motName '\n']);
fprintf(fid, ['\tWeight: ' num2str(motChoice(1)) ' g\r\n']);
fprintf(fid, ['\tVolts:  ' num2str(motChoice(4)) ' V\r\n']);
fprintf(fid, ['\tKV:     ' num2str(motChoice(2)) ' RPM/V\r\n']);
fprintf(fid, ['\tPower:  ' num2str(motChoice(3)) ' W\r\n']);
fprintf(fid, ['\tThrust: ' num2str(motChoice(5)) ' N\r\n']);


fprintf(fid, ['Battery - ' battName '\r\n']);
fprintf(fid, ['\tWeight:    ' num2str(battChoice(1)) ' g\r\n']);
fprintf(fid, ['\tCapacity:  ' num2str(battChoice(2)) ' mAh\r\n']);
fprintf(fid, ['\tVoltage:   ' num2str(battChoice(3)) ' V\r\n']);
fprintf(fid, ['\tDischarge: ' num2str(battChoice(4)) ' C\r\n']);
fclose(fid);
cd(MATLABFolder)

end

function thrusterSW(diameter, battH, battL, battW)
%THRUSTERSW Outputs data to solidworks for the arm
%   THRUSTERSW(diameter, battH, battL, battW) returns nothing

diameter = convlength(diameter, 'in', 'm')*1000;

SWPropFile = '2016-PROPELLER-EQUATIONS.txt';
SWPropCaseFile = '2017-PROPELLER-ENCASEMENT-EQUATIONS.txt';
SWCovFile = '2013-COMPONENT-COVER-EQUATIONS.txt';
SWDoorFile = '2014-COMPONENT-COVER-DOOR-EQUATIONS.txt';
SWBattFile = '5006-BATTERY2-EQUATIONS.txt';
MATLABFolder = fullfile('../MATLAB');
SWFolder = fullfile('../Solidworks/Equations');

% write to the different solidworks files
cd(SWFolder)
fid = fopen(SWPropFile, 'w+t');
fprintf(fid, ['"propdiameter"= ' num2str(diameter) 'mm\n']);
fclose(fid);
fid = fopen(SWPropCaseFile, 'w+t');
fprintf(fid, ['"propdiameter"= ' num2str(diameter) 'mm\n']);
fclose(fid);
fid = fopen(SWCovFile, 'w+t');
fprintf(fid, ['"batteryheighttwo"= ' num2str(battH) 'mm\n']);
fprintf(fid, ['"batterylengthtwo"= ' num2str(battL) 'mm\n']);
fprintf(fid, ['"batterywidthtwo"= ' num2str(battW) 'mm\n']);
fclose(fid);
fid = fopen(SWDoorFile, 'w+t');
fprintf(fid, ['"batteryheighttwo"= ' num2str(battH) 'mm\n']);
fprintf(fid, ['"batterylengthtwo"= ' num2str(battL) 'mm\n']);
fprintf(fid, ['"batterywidthtwo"= ' num2str(battW) 'mm\n']);
fclose(fid);
fid = fopen(SWBattFile, 'w+t');
fprintf(fid, ['"batteryheighttwo"= ' num2str(battH) 'mm\n']);
fprintf(fid, ['"batterylengthtwo"= ' num2str(battL) 'mm\n']);
fprintf(fid, ['"batterywidthtwo"= ' num2str(battW) 'mm\n']);
fclose(fid);
cd ..
cd(MATLABFolder)

disp('Thruster Parameterized in Solidworks');
end