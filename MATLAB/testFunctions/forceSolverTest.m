function [ result ] = forceSolverTest( )
%FORCESOLVERTEST Tests the Force Sovler function
%   scenarios and results are built into this function to test if the
%   function is working. Copy the code and add scenarios as they come up

result = 'Pass';

%---Scenario 1
forces = [ 0 0.409 -0.409 0 0 -7.66 0 0 0;
    0 0.642 0 0 0 -1.33 0 0 0;
    0 0.684 0 0 0 -4.46 0 0 0;
    0 0.802 0 0 0 -4.56 0 0 0 ];

reaction = [ 0 0 -0.637 1 1 1 1 1 1 ];

expected = [0 0 -0.6370 0 0 18.0100 10.6946 0 0 ];
output = forceSolver(forces, reaction);

if  isequal(round(output, 4), round(expected, 4)) == 0
    result = 'Fail';
end

%---Scenario 2
forces = [ 0 0.05 -0.0003 0 0 -0.981 0 0 0;
    0 0.08 0 0 0 -4.5 0 0 0];

reaction = [ 0 0 -0.00006 1 1 1 1 1 1 ];

expected = [0 0 -0.00006 0 0 5.481 0.4090 0 0 ];
output = forceSolver(forces, reaction);

if  isequal(round(output, 4), round(expected, 4)) == 0
    result = 'Fail';
end
end