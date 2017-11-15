function [tensor] = armTensor(forces, dimensions)
%ARMTENSOR Cauchy stress tensor of the arm.
%   tensor = ARMTENSOR(F, D) returns a 3x3 matrix which is used by
%   the cauchy function to find a safety factor for the arm.
%
%   F [ locX locY locZ Fx Fy Fz Mx My Mz ] - thrust force
%   D [innerRadius thickness width] - dimensions of the arm

% split dimensions array for use in equations
ri  = dimensions(1);
h   = dimensions(2);
k   = dimensions(3);

% split the forces array for use in equations
Fx  = forces(4);
Fy  = forces(5);
Fz  = forces(6);
Mx  = forces(7);
My  = forces(8);
Mz  = forces(9);

% find outer radius (ro) centre radius (rbar) and neutral axis radius (r)
ro  = ri + h;
rbar= ri + h/2;
r   = h/log(ro/ri);

% distance from centre to neutral axis
e   = rbar - r; 

% area of the x-z cross-section
A   = h*k;
Iz  = k^3*h/12;

% for the stress calculations
z = h/2 - e; x = k/2;

% for the torsion calcualtions
b = k; c = h;

% assume that max occurs at top right corner
%         k          ^
% -->.--------      z|-->
%    |        |h       x
%     --------
Sx  = 0;
Sy  = Mx*z/(e*A*ri) + Mz*x/Iz + Fy/A; % two plane stress
Sz  = 0;
txy = 0;
txz = 0; 
tyz = My/(b*c^2)*(3+1.8*c/b); % torsional sheer

% cauchy stress tensor
tensor = [ Sx  txy txz;
           txy Sy  tyz;
           txz tyz Sz ];
end

