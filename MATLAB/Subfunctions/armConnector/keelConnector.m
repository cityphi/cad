function [ n ] = keelConnector( inForces, weights, material )
%KEELCONNECTOR Summary of this function goes here
%   Detailed explanation goes here

n= 0;
spacerWidth = 0.06;

reactions = [ -spacerWidth/2 0  0.05 1 0 1 0 0 0;
               spacerWidth/2 0 -0.05 1 0 1 0 0 0];
           
aPitch = 90;
[force, hf] = armForces(weights, inForces, aPitch);
force(1:3) = [0 0 0.04];
force(4:end) = -force(4:end); % change the coordinates
% disp(force)
bottomForces = forceSolver(force, reactions);
end

