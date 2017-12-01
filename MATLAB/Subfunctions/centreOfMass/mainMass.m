%Code to simulate the gondola running down the keel
clear;clc;

% Variables for the program
massFile = 'massLocation.csv'; %file name
points = 1000; %number of points for graph
extension = 50; %extension past CV
keelDist = 27; %roughly an inch
radius = 637; %envelope radius

% Open the csv and set values
mass = csvread(massFile, 1);
distanceStep = (3000 + extension + keelDist)/(points);
data = ones(points+1, 4);

for i = 1:(points+1);
    loc = distanceStep*(i-1); % Actual distance on keel
    CG = centreOfMass(mass, loc, keelDist, radius);
    pitch = atan(CG(1)/CG(2)) * 180/pi; % Use CV and CG to get pitch

    % Fix for if angle greater than -90
    if i > 1
        if (pitch > 0) && (data(i-1,4) < 0);
            pitch = pitch - 180;
        end
    end

    % Record the results from each pass
    data(i,:) = [loc CG(1) CG(2) pitch];
end

% Information to output
scatter(data(:,1), data(:,4), 'f');
max_up = data(1, 4)
max_down = data(points+1, 4)
