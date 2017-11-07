function [ result ] = gondolaMotorForces( )
% Test for forces acting on gondola driving motor
result = 'Pass';


%---Scenario 1
forces = [ 0 0.409 -0.409 0 0 -7.66 0 0 0;
    0 0.642 0 0 0 -1.33 0 0 0;
    0 0.684 0 0 0 -4.46 0 0 0;
    0 0.802 0 0 0 -4.56 0 0 0 ];

reaction = [ 0 0 -0.637 1 1 1 1 1 1 ];

output = forceSolver(forces, reaction);
end