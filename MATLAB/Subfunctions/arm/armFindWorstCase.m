function [ worstCase ] = armFindWorstCase( inForces, weights, material )
%ARMFINDWORSTCASE Used to find the worst case based on loading
%   Should not be used when parameterizing, but should be run before to get
%   the data then it can be hard coded into the final.
%   inForces is [ locX locY locZ Fx Fy Fz Mx My Mz ] (thrust force)
%   weights is [ weigth locX locY locZ ] of any non-arm components acting
%   material is [density modulus ..] whatever properties needed of material

% dimensions of the arm [ri thickness width]
dimensions = [ 0.637 0.005 0.01 ];

% expand the weights array to allow the arm weight to be added and changed
weights = [weights; zeros(1, 4)];

% setup the data array to hold information
points = 5;
data = zeros(points^2*20, 4);
i = 1;

h = dimensions(2);
k = dimensions(3);
    
weights(end, :) = armWeight(dimensions, material);

% iterations to find the lowest safety factor
for aPitch = 0:5:90
    for z = -h/2:h/(2*points):h/2
        for x = -k/2:k/(2*points):k/2
            [~, halfReactions] = armForces(weights, inForces, aPitch);
            stressTensor = armFailure(halfReactions, dimensions, [x,z]);
            n = cauchy(stressTensor, material(2), material(3));
            data(i, :) = [aPitch x z n];
            i = i + 1;
        end
    end
end

[~, ind] = min(data(:, 4));
worstCase = data(ind, :);
disp(worstCase);

% build a graph data set at the worst case to get the conditions
aPitch = data(ind, 1);
[~, halfReactions] = armForces(weights, inForces, aPitch);

plots = 10;

graph = zeros(plots^2, 3);
i = 1;
for z = -h/2:h/(2*plots):h/2
    for x = -k/2:k/(2*plots):k/2
        stressTensor = armFailure(halfReactions, dimensions, [x,z]);
        n = cauchy(stressTensor, material(2), material(3));
        graph(i, :) = [x z n];
        i = i + 1;
    end
end

scatter3(graph(:, 1), graph(:, 2), graph(:, 3));
            
end

