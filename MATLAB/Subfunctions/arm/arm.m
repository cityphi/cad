function [ armReactions ] = arm( inForces, weights, material )
%ARM function performs all the actions needed to optimize the arm
%   inForces is [ locX locY locZ Fx Fy Fz Mx My Mz ] (thrust force)
%   weights is [ weigth locX locY locZ ] of any non-arm components acting
%   material is [density modulus ..] whatever properties needed of material

loop = 1; % looping variable for the function
aPitch = 0; % unsure how want to do this yet
safetyFactor = 1.5; 

% dimensions of the arm [ri thickness width]
dimensions = [ 0.637 0.005 0.01 ];

% expand the weights array to allow the arm weight to be added and changed
weights = [weights; zeros(1, 4)];

while loop
    % analysis of the arm
    weights(end, :) = armWeight(dimensions, material);
    [armReactions, halfReactions] = armForces(weights, inForces, aPitch);
    n = armFailure(halfReactions, dimensions, material);
    
    % safety factor check and iteration    
    if n < safetyFactor
        dimensions(2) = dimensions(2) + 0.001;
        dimensions(3) = dimensions(3) + 0.002;
    else
        loop = 0;
    end
end
end

