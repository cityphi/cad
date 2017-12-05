function [battChoice, badness] = battery( reqTime, minAmps, minVolts, maxMass )

% file
battCSV = 'batteryData.csv';
battData = csvread(battCSV, 1, 1);
battData(:, ~any(battData, 1)) = [];

%--DATA LOADING
% AMPS
% remove batteries which can't output enough amps
ampsCondition = battData(:, 4) < minAmps;
battData(ampsCondition, :) = [];

% MASS
% only load in batteries that are under the mass limit

if maxMass
    massCondition = battData(:, 2) > maxMass;
    battData(massCondition, :) = [];
end

% VOLTS
% remove batteries without enough cells
if minVolts
	voltsCondition = battData(:, 5) < minVolts;
	battData(voltsCondition, :) = [];
end

% end the function if battery data didn't meet inputs
if isempty(battData)
    error('BatteryData.InvalidInputs');%, 'No matching BATTERY based on inputs\n\nTry re-running with different inputs\n\nIf problem persists there might be an issue with the csvs of the program.');
end
    
%--LIFE
possibleTime = reqTime;
while 1
    battLife = minAmps * possibleTime * 1000;
    possibleBatt = battData;
    
	% remove any batteries with life that doesn't meet requirement
	possibleBatt(possibleBatt(:, 3) < battLife, :) = [];

	% check if a battery met the specification
    if ~isempty(possibleBatt)
	    break
    end
    if possibleTime == reqTime;
        possibleTime = 0.1/60;
        if possibleTime <= 0
            possibleTime = 0.1/60;
        end
        fprintf(['Reduced life to: ' num2str(possibleTime*60)]);
    else
        possibleTime = possibleTime - 2/60;
        if possibleTime <= 0
            possibleTime = 0.1/60;
        end
        fprintf([' -- ' num2str(possibleTime*60)]);
    end
end
fprintf('\n');

%--OUTPUT
% sort and return the best battery and the badness
badness = (reqTime - possibleTime)/reqTime;
possibleBatt = sortrows(possibleBatt, 2);
battChoice = possibleBatt(1, :);
end