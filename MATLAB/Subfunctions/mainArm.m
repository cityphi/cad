%%%% ALL OF INPUT MUST BE JUST HALF THE ARM %%%%
clear; clc;

% ---INPUTS

% Weights of components [ weigth locX locY locZ ]
weights = [1.33 0 0.642 0; 4.46 0 0.684 0];

% Input Forces [ locX locY locZ Fx Fy Fz Mx My Mz ] 
inForce = [ 0 0.802 0 4.56 0 0 0 0 0 ];

% Material [density Sut Suc E brittle]
carbon   = [1550 600*10^6 570*10^6 109*10^9 1];
aluminum = [2700 124*10^6 60*10^6  71*10^9  0]; % WIKIPEDIA

% ---TEST
% add all the subfolders to the path
addpath(genpath(pwd));

[weights, armDimensions] = arm(inForce, weights, carbon);

connectorDimensions = connector(inForce, weights, aluminum);

disp(armDimensions)
disp(connectorDimensions)