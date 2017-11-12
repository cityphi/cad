function [ tensor ] = armFailure( forces, dimensions, location )
%ARMFAILURE finds the safety factor of the arm
%   forces is [ locX locY locZ Fx Fy Fz Mx My Mz ] acting on the arm
%   dimensions is [ri thickness width]
%   location is [x y] and is the point to evaluate all stresses on face

% split dimensions array for use in equations
ri  = dimensions(1);
h   = dimensions(2);
k   = dimensions(3);
x   = location(1);
z   = location(2);

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
z   = z - e; % modify the height to be 

% area of the x-z cross-section
A   = h*k;
Iz  = k^3*h/12;

% for the torsion calcualtions, need to know the largest dimension
if h > k
    b = h; c = k;
else
    b = k; c = h;
end

% assume that the max occurs from torsion and stress at corner
Sx  = 0;
Sy  = -Mx*z/(e*A*ri) - Mz*x/Iz + Fy/A; % two plane stress
Sz  = 0;
txy = Fz*3/(2*A)*(1-z^2/(h/2)^2);
txz = -My/(b*c^2)*(3+1.8*c/b); % torsional sheer
tyz = Fx*3/(2*A)*(1-x^2/(k/2)^2);

% layout of the cauchy stress tensor
tensor = [ Sx  txy txz;
           txy Sy  tyz;
           txz tyz Sz ];
end

