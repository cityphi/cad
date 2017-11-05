% tests all funcitons using the code in /testFunctions
% !!!Delete this from master when project is done
clear; clc;

% gets all the subfolders
addpath(genpath(pwd));

% ---forceSolver Test
forceSolverTestResult = forceSolverTest();
disp(strcat('Force Solver --', forceSolverTestResult));