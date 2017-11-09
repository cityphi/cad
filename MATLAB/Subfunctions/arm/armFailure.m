function [ tensor ] = armFailure( forces, dimensions )
%ARMFAILURE finds the safety factor of the arm
%   forces is [ locX locY locZ Fx Fy Fz Mx My Mz ] acting on the arm
%   dimensions is [ri thickness width]
%   aPitch is the angle that the blimp is currently pitched at 

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
e   = rbar - r; % difference from centre to neutral axis

% area of the x-z cross-section
A   = h*k;
% distance from neutral axis to surface (max stress)
ci  = r - ri;

% for the torsion calcualtions, need to know the largest dimension
if h > k
    b = h; c = k;
else
    b = k; c = h;
end

% assume that the max occurs from torsion and stress at corner
Sx  = 0;
Sy  = -Mx*ci/(e*A*ri) - 6*Mz/(k^2*h) + Fy/A; % two plane stress
Sz  = 0;
txy = 0;
txz = -My/(b*c^2)*(3+1.8*c/b); % torsional sheer
tyz = 0;

% layout of the cauchy stress tensor
tensor = [ Sx  txy txz;
           txy Sy  tyz;
           txz tyz Sz ];
end

