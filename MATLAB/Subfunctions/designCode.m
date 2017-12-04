function designCode( requirements, scenario, l, FR )
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

% file
battCSV = 'batteryData.csv';
propCSV = 'propellerMotorData.csv';
battData = csvread(battCSV, 1, 1);
propData = csvread(propCSV, 1, 1);

battMasses = sort(unique(battData(:, 2)), 1);
[uniqueVolts, ~, count] = unique(battData(:, 5));
battMassVolts = zeros(max(count), 2);
battVolts = [battData(:, 2) battData(:, 5)];
for i = 1:max(count)
    massVolts = battVolts(battVolts(:, 2) == uniqueVolts(i), :);
    battMassVolts(i, :) = min(massVolts);
end
motMasses = sort(unique(propData(:, 9) + propData(:, 12)), 1);
motPowers = sort(unique(propData(:, 5)), 1);
massLimitBatt = 0;
massLimitMot = 0;
powerLimitMot = 0;

while 1;
    %---ENVELOPE
    [vol, envMass, airshipRad, CD] = envelope(l, FR);
    
    %---THRUSTER
    dragValues = [CD rhoA vol];

    %propeller (reqSpeed, dragValues, maxAmps, maxMass)
    [propChoice, motChoice, motBadness] = propeller(reqSpeed, dragValues, massLimitMot, powerLimitMot);
    %battery(reqTime, minAmps, minVolts, maxMass)
    [battChoice, battBadness] = battery(reqTime, motChoice(5)/motChoice(4), motChoice(4), massLimitBatt);

    % returns useful data and writes to files
    [thrusterMass, battMass, FTmax, propRadius, time, speed] = battMotPropData(propChoice, motChoice, battChoice, dragValues);

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
    carryingMass = vol*rhoA - totalMass;
    weightBadness = (reqWeight - carryingMass*1000)/reqWeight;
    if weightBadness < 0
        weightBadness = 0;
    end
    
    %---GONDOLA
    gondolaAnalysis(FTmax/totalMass, 0, 0.2); %TEMPORARY!#@$**&@#&
    
    %---OPTIMIZING
    switch scenario
        %WEIGHT
        case 1
            if weightBadness == 0
				break
            else
                indexBatt = find(battMasses == battChoice(2));
                indexMot = find(motMasses == (motChoice(9) + motChoice(12)));
                if motBadness > battBadness
                    if indexBatt ~= 1
                        massLimitBatt = battMasses(indexBatt-1);
                    else
                        if indexMot ~= 1
                            massLimitMot = motMasses(indexMot-1);
                        else
                            disp('~~~~~BAD')
                            break
                        end
                    end
                else
                    if indexMot ~= 1
                        massLimitMot = motMasses(indexMot-1);
                    else
                        if indexBatt ~= 1
                            massLimitBatt = battMasses(indexBatt-1);
                        else
                            disp('~~~~~BAD')
                            break
                        end
                    end
                end
            end
        
        %SPEED
        case 2
            if carryingMass < 0.2
                indexBatt = find(battMasses == battChoice(2));
                if indexBatt ~= 1
                    massLimitBatt = battMasses(indexBatt-1);
                    possibleBatt = battMassVolts;
                    voltsCondition = battMassVolts(:, 2) < motChoice(4);
                    possibleBatt(voltsCondition, :) = [];
                    if massLimitBatt <= min(possibleBatt(:, 1))
                        disp('~~~~~BAD: Couldn''t get a small enough battery to get caryring to 200g')
                        break
                    end
                else
                    disp('~~~~~BAD: Couldn''get a small enough battery to get caryring to 200g')
                    break
                end
            else
                if weightBadness <= battBadness
                    break
                else
                    indexBatt = find(battMasses == battChoice(2));
                    if indexBatt ~= 1
                        massLimitBatt = battMasses(indexBatt-1);
                    else
                        disp('~~~~~BAD')
                        break
                    end
                end
            end
            
        %TIME     
        case 3
            if battBadness <= 0
                break
            else
                indexPower = find(motPowers == motChoice(5));
                if indexPower ~= 1
                    powerLimitMot = motPowers(indexPower-1);
                else
                    disp('~~~~~')
                    break
                end
            end
    end
end
disp('~~~SOLVED')
%---LOG
finalLog(speed, time, carryingMass)
end