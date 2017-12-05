function designCode( requirements, scenario, l, FR, scenarioGondola, handles )
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

% optimization
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
    [vol, envMass, airshipRad, CD, CV] = envelope(l, FR);
    
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
    if carryingMass < 0
    	carryingMass = 0;
    end
    
    %---GONDOLA
    gondolaAnalysis(FTmax/totalMass, scenarioGondola, carryingMass);
    
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
                            fprintf('~~WARNING: Criteria NOT met\n');
                            fprintf('No battery or mtotor combination could achieve the desired weight.\n');
                            fpritnf('Try reducing the desired weight or increasing the volume of ariship.\n');
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
                            fprintf('~~WARNING: Criteria NOT met\n');
                            fprintf('No battery or mtotor combination could achieve the desired weight.\n');
                            fprintf('Try reducing the desired weight or increasing the volume of ariship.\n');
                            break
                        end
                    end
                end
            end
        
        %SPEED
        case 2
        	% need atleast 200g of carrying capacity
            if carryingMass < 0.2
            	% find the weight of the battery currently
                indexBatt = find(battMasses == battChoice(2));

                % only run if the battery is not already at the smallest size
                if indexBatt ~= 1
                	% set the max mass for the battery choice
                    massLimitBatt = battMasses(indexBatt - 1);
                    possibleBatt = battMassVolts;
                    voltsCondition = battMassVolts(:, 2) < motChoice(4);
                    possibleBatt(voltsCondition, :) = [];

                    % check that 
                    if massLimitBatt <= min(possibleBatt(:, 1))
                        fprintf('~~WARNING: Criteria NOT met\n');
                        fprintf('Could not meet the minimun carrying capacity of 200g.\n');
                    	fprintf('Try reducing the required speed to get a motor with running at a lower voltage.\n');
                    	fprintf('Increasing the size of the blimp will also help this.\n')
                        break
                    end
                else
                    fprintf('~~WARNING: Criteria NOT met\n');
                    fprintf('Could not meet the minimun carrying capacity of 200g.\n');
                    fprintf('Try increasing the size of the blimp or changing the required speed.\n');
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
                        fprintf('~~WARNING: Criteria NOT met\n');
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
                    disp('~~~~~BAD')
                    break
                end
            end
    end
end
%---PLOTS
axes(handles.axes1);
D = convlength(propChoice(1), 'in', 'm');
P = convlength(propChoice(2), 'in', 'm');
n = motChoice(6)/60;
Vp = 0:0.1:round(speed+3);
Tp = 0.20477*(pi*D^2)/4*(D/P)^1.5*((P * n)^2 - Vp*P * n)*2;
dragp = 2.420294 * CD * rhoA * vol^(2/3) * Vp.^1.86;
plot(Vp, Tp, Vp, dragp);
title('Drag and Thrust with changing velocity')
xlabel('Velocity of airship (m/2)');
ylabel('Force (N)');
legend('Thrust','Drag')

axes(handles.axes2);
gondolaMass(1) = gondolaMass(1) + carryingMass;
pitches = pitchPlot(fixedMass, gondolaMass, CV, airshipRad);

%---LOG
finalLog(speed, time, carryingMass, pitches)

fprintf('\n~~Design code finished. Solidworks and Log files have been updated.\n');

end