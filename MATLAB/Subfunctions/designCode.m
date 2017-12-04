function designCode( requirements, l, FR )
%DESIGNCODE Summary of this function goes here
%   Detailed explanation goes here
clc

% M [ density Sut Suc Sy E brittle ] - information of the material
carbon       = [1550 600*10^6 570*10^6 0        109*10^9   1]; % need Sy
aluminum6061 = [2700 310*10^6 0        276*10^6 68.9*10^9  0]; % matweb
nylon6       = [1130 69*10^6  44*10^6  63*10^6  2.33*10^9  1]; % matweb unrenforced
rhoA = 1.225;

% split the inputs to be more readable
reqSpeed = requirements(1); %m/s
reqTime = requirements(2)/60; %h
reqWeight = requirements(3);
scenario = 1;

% file
battCSV = 'batteryData.csv';
propCSV = 'propellerMotorData.csv';
battData = csvread(battCSV, 1, 1);
propData = csvread(propCSV, 1, 1);

battMasses = battData(:, 2);
motMasses = propData(:, 9)+propData(:, 12);

switch scenario
	% case 1-guarantee Weight
	case 1
		massLimitBatt = 0;
		massLimitMot = 0;
		while 1;
            %---ENVELOPE
            [vol, envMass, airshipRad, CD] = envelope(l, FR);
            %---THRUSTER
            dragValues = [CD rhoA vol];
            
			%propeller (reqSpeed, dragValues, maxAmps, maxMass)
			[propChoice, motChoice, motBadness] = propeller(reqSpeed, dragValues, massLimitMot);
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

			if weightBadness == 0
				break
			else
				if motBadness > battBadness
                    if battChoice(1) ~= 1
                        massLimitBatt = battMasses(battChoice(1) - 1);
                    else
                        if motChoice(1) ~= 1
                            massLimitMot = motMasses(motChoice(1) - 1);
                        end
                    end
                else
                    if motChoice(1) ~= 1
                        massLimitMot = motMasses(motChoice(1) - 1);
                    else
                        if battChoice(1) ~= 1
                            massLimitBatt = battMasses(battChoice(1) - 1);
                        end
                    end
                end
                if battChoice(1) == 1 && motChoice(1) == 1 
                    disp('~~~~~COULD NOT ACHIEVE WEIGHT~~~~')
                    break
                end
            end
        end
    case 2
        massLimitBatt = 0;
		while 1;
			%propeller (reqSpeed, dragValues, maxAmps, maxMass)
			[propChoice, motChoice, motBadness] = propeller(reqSpeed, dragValues, 0, 0);
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

			if abs(weightBadness - battBadness) < 0.1
				break
			else
				massLimitBatt = battMass*(1 - weightBadness*0.1);
            end
        end
        
end

%---LOG
finalLog(speed, time, carryingMass)
end