function [ solved, totalError ] = forceSolver( forces, reactions )
%FORCESOLVER is a tool to find reaction forces with known input forces
%   sovled = forceSolver( forces, unknown) reaction forces
%   Forces is [ locX locY locZ Fx Fy Fz Mx My Mz ] 
%   Unkown Forces is same format but the forces and moments correspond to
%   their ability to resist
%   Solved is [ locX locY locZ Fx Fy Fz Mx My Mz ] 

% setting up useful values used
numReactions = size(reactions, 1);
numForces    = 6; % constant for the number of forces (Fxyz and Mxyz)
offset       = 3; % number of coordinates (xyz) used to offset matrices

% change the reactions array to use the assumptions made on it
[information, reactions] = reactionEncoder(reactions);

% intermediate array that holds the information for the 6 equations
solver = equationBuilder(reactions, forces);

% simplify the solver array and try to solve it
zeroForces = all(solver == 0);
removedSolver = solver(:, ~zeroForces);
reducedSolver = rref(removedSolver);

% check if the matrix could solve
unsolveable = 0;
for i = 1:numForces
    if sum(reducedSolver(i, 1:end-1) ~= 0) > 1
        unsolveable = 1;
    end
end

% if the program solved - convert from rref format to output format
solved = zeros(numReactions, 9); % output
k = 1;
if unsolveable ~= 1
    % set the forces
    for i = 1:numReactions
        for j = 1:numForces
            if zeroForces((i-1)*numForces + j) == 0
                solved(i, j+offset) = reducedSolver(k, end);
                k = k + 1;
            end
        end
    end
    
    % decode the solved array based on the changes made at the start.
    solved = reactionDecoder(solved, information);
    
    % set the locations
    for i = 1:numReactions
        solved(i, 1:3) = reactions(i, 1:3);
    end 
    
else
    disp('--The matrix could not be solved')
end

%--check
check = equationBuilder(solved, forces);
errors = sum(check(:, 1:end-1), 2) - check(:, end);
percentOff = round(abs(sum(errors)/sum(check(:, end)))*100, 2);
totalError = [transp(errors) percentOff];
end

function [ sysEquations ] = equationBuilder(reactions, forces)
%REACTIONENCODER encodes the reaction array based on the assumptions given
%   This is used to remove the bulky code from the main function making it
%   easier to read. It takes the reactions array and outputs the
%   information needed to decode the array and an reactions array that can
%   be solved.

% % constants used in main to make it easier to understand
numReactions = size(reactions, 1);
numForces    = 6;

% random 3D point to take the moments about
%about = rand(3, 1); 
about = [0 0 0];

forces(:, 1:3) = bsxfun(@minus, forces(:, 1:3), about(1:3));
totalR = transp(forces(:, 1:3));
totalF = transp(forces(:, 4:6));
totalM = [transp(forces(:, 7:9)) -cross(totalR, totalF)];

%  output array that holds the information for the 6 equations
sysEquations = zeros(6, numReactions * numForces + 1);

% ---totals
sysEquations(1, end) = -sum(totalF(1, :));
sysEquations(2, end) = -sum(totalF(2, :));
sysEquations(3, end) = -sum(totalF(3, :));

sysEquations(4, end) = -sum(totalM(1, :));
sysEquations(5, end) = -sum(totalM(2, :));
sysEquations(6, end) = -sum(totalM(3, :));

% ---reaction forces
for i = 1:numReactions
    n = (i-1)*numForces; 
    % input the simple values (forces and moments)
    sysEquations(1, n+1) = reactions(i, 4);
    sysEquations(2, n+2) = reactions(i, 5);
    sysEquations(3, n+3) = reactions(i, 6);
    sysEquations(4, n+4) = reactions(i, 7);
    sysEquations(5, n+5) = reactions(i, 8);
    sysEquations(6, n+6) = reactions(i, 9);
    
    % find the moments generated by the reaction forces
    sysEquations(4, n+3) = -(reactions(i, 2) - about(2)) * reactions(i, 6);
    sysEquations(4, n+2) = -(reactions(i, 3) - about(3)) * reactions(i, 5);
    sysEquations(5, n+3) = -(reactions(i, 1) - about(1)) * reactions(i, 6);
    sysEquations(5, n+1) = -(reactions(i, 3) - about(3)) * reactions(i, 4);
    sysEquations(6, n+2) = -(reactions(i, 1) - about(1)) * reactions(i, 5);
    sysEquations(6, n+1) = -(reactions(i, 2) - about(2)) * reactions(i, 4);
end
end

function [information, reactions] = reactionEncoder(reactions)
%REACTIONENCODER encodes the reaction array based on the assumptions given
%   This is used to remove the bulky code from the main function making it
%   easier to read. It takes the reactions array and outputs the
%   information needed to decode the array and an reactions array that can
%   be solved.

% constants used in main to make it easier to understand
numReactions = size(reactions, 1);
numForces    = 6;
offset       = 3;

% store the information and modify the fields
information  = zeros(numReactions, numForces);
for n = 2:numReactions
    for j = 1:numForces
        pair = 1;
        for i = 1:numReactions
            if reactions(i, j + offset) == n
                information(i, j) = n;
                if pair
                    reactions(i, j + offset) = 1;
                    pair = 0;
                else
                    reactions(i, j + offset) = 0;
                end
            end
        end
    end
end
end

function [solved] = reactionDecoder(solved, information)
%REACTIONDECODER is the decoder for reactionEncoder
%   It takes the information array and the now solved array to build an
%   output based on the assumptions made.

% constants used in main to make it easier to understand
numReactions = size(solved, 1);
numForces    = 6;
offset       = 3;

% split the solved forces into the final array
for n = 2:numReactions
    for j = 1:numForces
        pair = 1;
        for i = 1:numReactions
            if information(i, j) == n
                if pair
                    value = solved(i, j+offset)/information(i, j);
                    pair = 0;
                end
                solved(i, j+offset) = value;
            end
        end
    end
end
end