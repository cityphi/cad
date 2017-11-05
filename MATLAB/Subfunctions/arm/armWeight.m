function [ weight ] = armWeight(inRadius, thickness, width, density)
%ARMWEIGHT gives the weight and CM of the arm based on dimension
%   Detailed explanation goes here
ri = inRadius;
h = thickness;
ro = ri + h;
k = width;
rho = density;
g = 9.81;

mag = k*pi()*(ro^2 - ri^2)/4*rho*g;
locX = 0;
locY = 4*(ro^3 - ri^3)/(3*pi()*(ro^2 - ri^2));
locZ = -locY;

% Weight [ mag locX locY locZ ]
weight = [mag locX locY locZ];
end

