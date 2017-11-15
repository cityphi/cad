function [ worstCase ] = armWorstCase( inForces, weights, material )
%ARMFINDWORSTCASE Used to find the worst case based on loading
%   Should not be used when parameterizing, but should be run before to get
%   the data then it can be hard coded into the final.
%   inForces is [ locX locY locZ Fx Fy Fz Mx My Mz ] (thrust force)
%   weights is [ weigth locX locY locZ ] of any non-arm components acting
%   material is [density Sut Suc] of the material

% dimensions of the arm [ri thickness width]
h = 0.005;
k = 0.01;
dimensions = [ 0.637 h k ];

% add the weight of the arm based on dimensions
weights(end+1, :) = armWeight(dimensions, material);

% set the number of points in x-z to take
points = 5;
pointsCount = points - 1;

% iterations to find the lowest safety factor
data = zeros(points^2, 4);
i = 1;
for aPitch = 0:5:90
    for z = -h/2:h/pointsCount:h/2
        for x = -k/2:k/pointsCount:k/2
            % find the safety factor at current conditions
            [~, halfReactions] = armForces(weights, inForces, aPitch);
            stressTensor = armFailure(halfReactions, dimensions, [x,z]);
            n = cauchy(stressTensor, material(2), material(3));
            
            % store data
            data(i, :) = [aPitch x z n];
            i = i + 1;
        end
    end
end

% find and return the worst case value
[~, ind] = min(data(:, 4));
worstCase = data(ind, :);

% graph the cross-section fo worst case
aPitch = data(ind, 1);
[~, halfReactions] = armForces(weights, inForces, aPitch);
armGraphCrossSection(halfReactions, dimensions, material);
end