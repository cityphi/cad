% DELETE THIS FILE FOR FINAL
% USED TO TEST THE FUNCTIONS
clear; clc;

% gets all the subfolders
addpath(genpath(pwd));

% copy this for the different tests that care created
forceSolverTestResult = forceSolverTest();
disp(strcat('Force Solver --', forceSolverTestResult));

