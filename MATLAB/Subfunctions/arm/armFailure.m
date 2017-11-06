function [ n ] = armFailure( forces, dimensions, material )
%ARMFAILURE finds the safety factor of the arm
%   forces is [ locX locY locZ Fx Fy Fz Mx My Mz ] acting on the arm
%   dimensions is [ri thickness width]
%   material is ???

% THIS FUNCTION IS NOT DONE AND ONLY A PLACE HOLDER

ri  = dimensions(1);
h   = dimensions(2);
w   = dimensions(3);

n = forces(7)*(h*w)*100;

end

