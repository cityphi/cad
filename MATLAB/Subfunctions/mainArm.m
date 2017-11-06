%%%% ALL OF INPUT MUST BE JUST HALF THE ARM %%%%
clear; clc;

% ---INPUTS
% pitch angle of airship
aPitch = 0;

% Weights of components [ weigth locX locY locZ ]
weights = [1.33 0 0.642 0; 4.46 0 0.684 0];

% Input Forces [ locX locY locZ Fx Fy Fz Mx My Mz ] 
inForce = [ 0 0.802 0 0 0 -4.56 0 0 0 ];

% Material [density ???..]
material = [1550 0];

% ---TEST
% add all the subfolders to the path
addpath(genpath(pwd));

arm(inForce, weights, material)
