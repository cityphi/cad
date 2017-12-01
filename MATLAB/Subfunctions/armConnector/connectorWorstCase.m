function [ output_args ] = connectorWorstCase( input_args )
%CONNECTORWORSTCASE DOES NOT WORK JUST DIDN'T want to delete
% loop to find the worst angle for each failure case
minAngle = -90;
maxAngle = 90;
data = zeros(maxAngle - minAngle + 1, 3);
i = 1;

for aPitch = minAngle:1:maxAngle
    a = aPitch*pi()/180;
    forces(end, :) = centreMass(weight, a);
    translatedForces = -forceSolver(forces, reaction);
    
    % safety factor for stresses
    stressTensor = connectorTensor(translatedForces, dimensions);
    SF(1) = cauchy(stressTensor, material);
    
    % safety factor for buckling
    Pcr = (1.2)*pi()^2*material(5)* dimensions(2)^3/(12*dimensions(3));
    SF(2) = abs(Pcr/sum(translatedForces(:, 6)));

    % store data
    data(i, :) = [aPitch SF];
    i = i + 1;
end

[worst, row] = min(data(:, 2:3));
[~, col] = min(worst);

pitches = data(row, 1);

%00000000000 KEEL CONNECTOR
% checking at different pitch angles
minAngle = -60; maxAngle = 90;
data = zeros(maxAngle-minAngle+1, 2);
i = 0;

% checking for worst case scenario of the base of connector
for aPitch = minAngle:1:maxAngle
    i = i + 1;
    % change the reaction assumptions based on the pitch angle
    if aPitch < 0
        reactions(:, 4) = [1; 0];
        force = armForces(weights, inForces, aPitch);
        force = [0 0 0.04 -force(4:end)]; % change the coordinates
        bottomForces = forceSolver(force, reactions);
        analysisForces = bottomForces(1, :);
    else
        reactions(:, 4) = [0; 1];
        force = armForces(weights, inForces, aPitch);
        force = [0 0 0.04 -force(4:end)]; % change the coordinates
        bottomForces = forceSolver(force, reactions);
        analysisForces = bottomForces(2, :);
    end
    % build a stress tensor and use cauchy to solve for safety factor
    stressTensor = keelTensor(analysisForces, dimensions);
    data(i, :) = [aPitch cauchy(stressTensor, material)];
end

end

