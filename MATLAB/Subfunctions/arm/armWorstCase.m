function [ worstCase ] = armWorstCase( inForces, weights, material )
%ARMWORSTCASE Evaluates the worst pitch angle for the arm.
%   a = armWorstCase(F, W, M) returns the worst angle for the stress in the
%   arm. This is run before doing the optimization so optimization is done
%   for only one location.
%   
%   F [ locX locY locZ Fx Fy Fz Mx My Mz ] - thrust force
%   W [ weight locX locY locZ ] - weight of components held by the arm
%   M [ density Sut Suc E brittle ] - information of the material

% dimensions of the arm [ri thickness width]
h = 0.005;
k = 0.01;
dimensions = [ 0.637 h k ];

% add the weight of the arm based on dimensions
weights(end+1, :) = armWeight(dimensions, material(1));

% iterations to find the lowest safety factor
minAngle = -60;
maxAngle = 90;
data = zeros(maxAngle-minAngle, 2);
i = 1;

for aPitch = minAngle:1:maxAngle
    % find the safety factor at current conditions
    [~, halfReactions] = armForces(weights, inForces, aPitch);
    stressTensor = armTensor(halfReactions, dimensions);
    n = cauchy(stressTensor, material);

    % store data
    data(i, :) = [aPitch n];
    i = i + 1;
end
% find and return the worst case pitch
[~, ind] = min(data(:, 2));
worstCase = data(ind, 1:end-1);
end