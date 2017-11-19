function [weights, dimensions] = arm(inForces, weights, material)
%ARM Thruster arm optimization.
%   [R, D] = ARM(F, W, M) returns the reaction forces at the worst
%   pitch for the connector and the optimized dimensions of the arm. 
%
%   F [ locX locY locZ Fx Fy Fz Mx My Mz ] - thrust force
%   W [ weight locX locY locZ ] - weight of components held by the arm
%   M [ density Sut Suc Sy E brittle ] - information of the material

safetyFactor = 5; % hard coded value for the safety factor

% find the pitch to do analysis of the arm
aPitch = armWorstCase(inForces, weights, material);

% dimensions of the arm [ri thickness width]
dimensions = [ 0.637 0.005 0.01 ];

% expand the weights array to allow the arm weight to be added and changed
weights = [weights; zeros(1, 4)];

% looping variables
maxIterations = 100; iterations = 0; loop = 1;

while loop && iterations < maxIterations
    iterations = iterations + 1;
    
    % analysis of the arm
    weights(end, :) = armWeight(dimensions, material(1));
    [~, halfReactions] = armForces(weights, inForces, aPitch);
    stressTensor = armTensor(halfReactions, dimensions);
    n = cauchy(stressTensor, material);
    
    % safety factor check and iteration    
    if n < safetyFactor
        dimensions(2) = dimensions(2) + 0.001;
        dimensions(3) = dimensions(3) + 0.001;
    else
        loop = 0;
    end
end
end