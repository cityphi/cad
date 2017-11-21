function [ weights, dimensions ] = thrusterShaft( inForces, weights, material )
%THRUSTERSHAFT Thruster arm optimization.
%   [W, D] = ARM(F, W, M) returns the reaction forces at the worst
%   pitch for the connector and the optimized dimensions of the arm. 
%
%   F [ locX locY locZ Fx Fy Fz Mx My Mz ] - thrust force
%   W [ weight locX locY locZ ] -  weight of components held by the arm
%   M [ density Sut Suc Sy E brittle ] - information of the material

safetyFactor = 5;

% r
dimensions = [ 0.003 ];





end

