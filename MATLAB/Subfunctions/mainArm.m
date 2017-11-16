%%%% ALL OF INPUT MUST BE JUST HALF THE ARM %%%%
clear; clc;

% ---INPUTS

% Weights of components [ weigth locX locY locZ ]
weights = [1.33 0 0.642 0; 4.46 0 0.684 0];

% Input Forces [ locX locY locZ Fx Fy Fz Mx My Mz ] 
inForce = [ 0 0.802 0 4.56 0 0 0 0 0 ];

% material [density Sut Suc Sy E brittle]
carbon       = [1550 600*10^6 570*10^6 0        109*10^9   1]; % need Sy
aluminum6061 = [2700 310*10^6 0        276*10^6 68.9*10^9  0]; % matweb

% ---TEST
% add all the subfolders to the path
addpath(genpath(pwd));

% [weights, armDimensions] = arm(inForce, weights, carbon);
% 
% connectorDimensions = connector(inForce, weights, aluminum6061);
% 
% disp(armDimensions)
% disp(connectorDimensions)

weights = [1.33 0 0.642 0; 4.46 0 0.684 0; 1.285 0 0.4078 -0.4078];
keelDimensions = keelConnector(inForce, weights, aluminum6061);