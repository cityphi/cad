function [ weight ] = armWeight( dimensions, material)
%ARMWEIGHT gives the weight and CM of the arm based on dimension
%   Detailed explanation goes here

% give readable names for equations from inputs
ri  = dimensions(1);
h   = dimensions(2);
k   = dimensions(3);
rho = material(1);

% set other variables to be used
ro = ri + h;
g = 9.81;

% solve for the weight of the arm and centre of mass
mag = k*pi()*(ro^2 - ri^2)/4*rho*g;
locX = 0;
locY = 4*(ro^3 - ri^3)/(3*pi()*(ro^2 - ri^2));
locZ = -locY;

weight = [ mag, locX, locY, locZ ];
end