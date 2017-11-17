function [ weight ] = armWeight( dimensions, rho )
%ARMWEIGHT Weight and centre of mass of arm.
%   W = ARMWEIGHT(D, p) returns a vector with the weight and the
%   location that the point mass is acting. The coordinate system is
%   relative to the centre of volume of the airship.
% 
%   D [ innerRadius thickness width ] - dimensions of the arm
%   p [ density ] - the density of the arm material

% give readable names for equations from dimension array
ri  = dimensions(1);
h   = dimensions(2);
k   = dimensions(3);

% set other variables to be used
ro = ri + h;
g = 9.81;

% solve for the weight of the arm and centre of mass
mag = k*pi()*(ro^2 - ri^2)/4*rho*g;
locX = 0;
locY = 4*(ro^3 - ri^3)/(3*pi()*(ro^2 - ri^2));
locZ = -locY;

% build the array to return
weight = [ mag, locX, locY, locZ ];
end